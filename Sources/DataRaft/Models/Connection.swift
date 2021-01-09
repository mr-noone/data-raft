import Foundation
import CSQLite
import SQLighter

public final class Connection: Pointer {
  public typealias TraceCallback = (String) -> ()
  private let connection: OpaquePointer
  private let center: ObserverCenter?
  private let queue: DispatchQueue
  private let queueKey = DispatchSpecificKey<Void>()
  private var isCommit = false
  
  public var trace: TraceCallback?
  public var busyTimeout: Int32 = 0 {
    didSet { sqlite3_busy_timeout(connection, busyTimeout) }
  }
  
  public var journalMode: JournalMode {
    get { try! get(pragma: .journalMode) ?? .off }
    set { try! set(pragma: .journalMode, value: newValue) }
  }
  
  public var foreignKeys: ForeignKeys {
    get { try! get(pragma: .foreignKeys) ?? .off }
    set { try! set(pragma: .foreignKeys, value: newValue) }
  }
  
  private init(connection: OpaquePointer, observer center: ObserverCenter?) throws {
    self.connection = connection
    self.center = center
    
    queue = DispatchQueue(label: String(describing: Self.self))
    queue.setSpecific(key: queueKey, value: ())
    
    configureTrace()
    configureUpdateHook()
    configureCommitHook()
    configureRollbackHook()
  }
  
  convenience init(path: String?, observer center: ObserverCenter?) throws {
    try self.init(connection: Self.open(path: path), observer: center)
  }
  
  public convenience init(path: String?) throws {
    let center: ObserverCenter?
    if let path = path {
      center = try ObserverCenter.center(for: path)
    } else {
      center = nil
    }
    
    try self.init(
      connection: Self.open(path: path),
      observer: center
    )
  }
  
  deinit {
    sqlite3_close_v2(connection)
  }
}

public extension Connection {
  func isExplicitTransaction() -> Bool {
    return sqlite3_get_autocommit(connection) == 0
  }
  
  func beginTransaction(_ type: TransactionType = .deferred) throws {
    try execute(sql: "BEGIN \(type) TRANSACTION", args: [])
  }
  
  func commitTransaction() throws {
    try execute(sql: "COMMIT TRANSACTION", args: [])
  }
  
  func rollbackTransaction() throws {
    try execute(sql: "ROLLBACK TRANSACTION", args: [])
  }
  
  func get<T: SQLValueConvertible>(pragma: Pragma) throws -> T? {
    return try execute(sql: "PRAGMA \(pragma)", args: [])
  }
  
  @discardableResult
  func set<T: SQLValueConvertible>(pragma: Pragma, value: T) throws -> T? {
    return try execute(sql: "PRAGMA \(pragma) = \(value.sqlLiteral)", args: [])
  }
  
  @discardableResult
  func execute<T: SQLValueConvertible>(sql: String, args: Arguments) throws -> T? {
    return try T(execute(sql: sql, args: [args]).first?.first?.value ?? .null)
  }
  
  @discardableResult
  func execute<T: SQLValueConvertible>(sql: String, args: Arguments) throws -> [T] {
    return try execute(sql: sql, args: [args]).compactMap { $0.first?.value }.compactMap { T($0) }
  }
  
  @discardableResult
  func execute(sql: String, args: Arguments) throws -> Record? {
    return try execute(sql: sql, args: [args]).first
  }
  
  @discardableResult
  func execute(sql: String, args: Arguments) throws -> [Record] {
    return try execute(sql: sql, args: [args])
  }
  
  @discardableResult
  func execute(sql: String, args: [Arguments]) throws -> [Record] {
    return try perform { [self] in
      let statement = try Statement(db: connection, sql: sql)
      var result = [Record]()
      var index = 0
      
      repeat {
        try statement.bind(args: args[ifExists: index])
        try statement.step(result: &result)
        try statement.reset()
      } while ++index < args.count
      
      if isCommit {
        isCommit = false
        center?.didCommit()
      }
      
      return result
    }
  }
  
  func perform<T>(_ closure: () throws -> (T)) rethrows -> T {
    switch DispatchQueue.getSpecific(key: queueKey) {
    case .none: return try queue.sync(execute: closure)
    case .some: return try closure()
    }
  }
  
  func perform<T>(in transaction: TransactionType, closure: () throws -> (T)) rethrows -> T {
    if isExplicitTransaction() {
      return try perform(closure)
    } else {
      return try perform {
        do {
          try beginTransaction()
          let result = try closure()
          try commitTransaction()
          return result
        } catch {
          try rollbackTransaction()
          throw error
        }
      }
    }
  }
}

private extension Connection {
  static func open(path: String?) throws -> OpaquePointer {
    if let path = path, !path.isEmpty {
      try FileManager.default.createDirectory(
        at: URL(fileURLWithPath: path).deletingLastPathComponent(),
        withIntermediateDirectories: true,
        attributes: nil
      )
    }
    
    var connection: OpaquePointer! = nil
    let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_NOMUTEX
    let status = sqlite3_open_v2(path, &connection, flags, nil)
    
    if status == SQLITE_OK, let connection = connection {
      return connection
    } else {
      let error = Error(connection)
      sqlite3_close_v2(connection)
      throw error
    }
  }
  
  func configureTrace() {
    sqlite3_trace_v2(connection, UInt32(SQLITE_TRACE_STMT), { _, connection, stmt, _ in
      guard
        let connection = *connection as Connection?,
        let trace = connection.trace,
        let stmt = OpaquePointer(stmt),
        let sql = sqlite3_expanded_sql(stmt)
      else {
        return SQLITE_OK
      }
      
      trace(String(cString: sql))
      return SQLITE_OK
    }, *self)
  }
  
  func configureUpdateHook() {
    guard let center = center else { return }
    sqlite3_update_hook(connection, { center, kind, db, tableName, rowID in
      guard
        let center = *center as ObserverCenter?,
        let event = ObserverEvent(kind: kind, db: db, table: tableName, rowID: rowID)
      else { return }
      center.didUpdate(event)
    }, *center)
  }
  
  func configureCommitHook() {
    sqlite3_commit_hook(connection, { connection -> Int32 in
      guard
        let connection = *connection as Connection?
      else {
        return SQLITE_OK
      }
      
      do {
        connection.isCommit = true
        try connection.center?.willCommit()
        return SQLITE_OK
      } catch {
        return SQLITE_ERROR
      }
    }, *self)
  }
  
  func configureRollbackHook() {
    sqlite3_rollback_hook(connection, { connection in
      guard
        let connection = *connection as Connection?
      else { return }
      connection.isCommit = false
      connection.center?.didRollback()
    }, *self)
  }
}
