import Foundation
import CSQLite

public class Connection {
  public typealias TraceCallback = (String) -> ()
  public typealias DidUpdateCallback = (ObserverEvent) -> ()
  public typealias WillCommitCallback = () throws -> ()
  public typealias DidCommitCallback = () -> ()
  public typealias DidRollbackCallback = () -> ()
  
  // MARK: - Properties
  
  private let connection: OpaquePointer
  private let queue: DispatchQueue
  private let queueKey = DispatchSpecificKey<Void>()
  private var isCommit = false
  
  var trace: TraceCallback?
  var didUpdate: DidUpdateCallback?
  var willCommit: WillCommitCallback?
  var didCommit: DidCommitCallback?
  var didRollback: DidRollbackCallback?
  
  var busyTimeout: Int32 = 5000 {
    didSet { sqlite3_busy_timeout(connection, busyTimeout) }
  }
  
  // MARK: - Inits
  
  init(path: String) throws {
    connection = try Self.open(path: path)
    queue = DispatchQueue(label: String(describing: Self.self))
    queue.setSpecific(key: queueKey, value: ())
    
    configureTrace()
    configureUpdateHook()
    configureCommitHook()
    configureRollbackHook()
  }
}

// MARK: - Public

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
  
  func getPragma<T: DatabaseValueConvertible>(_ pragma: Pragma) throws -> T? {
    return try execute(sql: "PRAGMA \(pragma)", args: [])
  }
  
  @discardableResult
  func setPragma<T: DatabaseValueConvertible>(_ pragma: Pragma, value: T) throws -> T? {
    return try execute(sql: "PRAGMA \(pragma) = \(value)", args: [])
  }
  
  func execute<T: DatabaseValueConvertible>(sql: String, args: Arguments) throws -> T? {
    return try T(execute(sql: sql, args: args) ?? .null)
  }
  
  func execute<T: DatabaseValueConvertible>(sql: String, args: Arguments) throws -> [T] {
    return try execute(sql: sql, args: args).compactMap { T($0) }
  }
  
  func execute(sql: String, args: Arguments) throws -> DatabaseValue? {
    return try execute(sql: sql, args: args)?.first?.value
  }
  
  func execute(sql: String, args: Arguments) throws -> [DatabaseValue] {
    return try execute(sql: sql, args: args).compactMap { $0.first?.value }
  }
  
  func execute(sql: String, args: Arguments) throws -> Record? {
    return try execute(sql: sql, args: [args]).first
  }
  
  func execute(sql: String, args: Arguments) throws -> [Record] {
    return try execute(sql: sql, args: [args])
  }
  
  @discardableResult
  func execute(sql: String, args: [Arguments]) throws -> [Record] {
    return try perform {
      let statement = try self.prepare(sql: sql)
      
      defer {
        self.finalize(stmt: statement)
      }
      
      var result = [Record]()
      var index = 0
      
      repeat {
        try self.bind(stmt: statement, args: args[ifExists: index])
        try self.step(stmt: statement, result: &result)
        try self.reset(stmt: statement)
      } while ++index < args.count
      
      if self.isCommit {
        self.isCommit = false
        self.didCommit?()
      }
      
      return result
    }
  }
  
  func perform<T>(_ closure: @escaping () throws -> (T)) throws -> T {
    if DispatchQueue.getSpecific(key: queueKey) != nil {
      return try closure()
    } else {
      let semaphore = DispatchSemaphore(value: 0)
      var anError: Swift.Error? = nil
      var result: T! = nil
      
      queue.async {
        do {
          result = try closure()
        } catch {
          anError = error
        }
        semaphore.signal()
      }
      
      semaphore.wait()
      if let error = anError {
        throw error
      } else {
        return result
      }
    }
  }
}

// MARK: - Private

private extension Connection {
  static func open(path: String) throws -> OpaquePointer {
    try FileManager.default.createDirectory(
      at: URL(fileURLWithPath: path).deletingLastPathComponent(),
      withIntermediateDirectories: true,
      attributes: nil
    )
    
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
        let stmt = OpaquePointer(stmt),
        let sql = sqlite3_expanded_sql(stmt),
        let connection = *connection as Connection?
      else {
        return SQLITE_OK
      }
      
      connection.trace?(String(cString: sql))
      return SQLITE_OK
    }, *self)
  }
  
  func configureUpdateHook() {
    sqlite3_update_hook(connection, { connection, kind, db, tableName, rowID in
      guard
        let connection = *connection as Connection?,
        let event = ObserverEvent(kind: kind, db: db, table: tableName, rowID: rowID)
      else { return }
      connection.didUpdate?(event)
    }, *self)
  }
  
  func configureCommitHook() {
    sqlite3_commit_hook(connection, { connection -> Int32 in
      guard let connection = *connection as Connection? else {
        return SQLITE_OK
      }
      
      do {
        connection.isCommit = true
        try connection.willCommit?()
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
      connection.didRollback?()
    }, *self)
  }
  
  func prepare(sql: String) throws -> OpaquePointer {
    var statement: OpaquePointer! = nil
    let status = sqlite3_prepare_v2(connection, sql, -1, &statement, nil)
    
    if status == SQLITE_OK, let statement = statement {
      return statement
    } else {
      sqlite3_finalize(statement)
      throw Error(connection)
    }
  }
  
  func bind(stmt: OpaquePointer, args: Arguments?) throws {
    guard let args = args else { return }
    
    var status: Int32
    var index: Int32
    
    for arg in args {
      switch arg.index {
      case .name(let name):
        index = sqlite3_bind_parameter_index(stmt, name)
      case .index(let idx):
        index = idx
      }
      
      switch arg.value {
      case .null:              status = sqlite3_bind_null(stmt, index)
      case .int(let value):    status = sqlite3_bind_int64(stmt, index, value)
      case .double(let value): status = sqlite3_bind_double(stmt, index, value)
      case .text(let value):   status = sqlite3_bind_string(stmt, index, value)
      case .data(let value):   status = sqlite3_bind_data(stmt, index, value)
      }
      
      if status != SQLITE_OK {
        throw Error(connection)
      }
    }
  }
  
  func step(stmt: OpaquePointer, result: inout [Record]) throws {
    var status: Int32
    repeat {
      status = sqlite3_step(stmt)
      switch status {
      case SQLITE_ROW:
        let record = (0..<sqlite3_column_count(stmt)).reduce(Record()) { record, index in
          let type = sqlite3_column_type(stmt, index)
          let name = sqlite3_column_name(stmt, index)
          let value: DatabaseValue
          
          switch type {
          case SQLITE_INTEGER: value = .int(sqlite3_column_int64(stmt, index))
          case SQLITE_FLOAT:   value = .double(sqlite3_column_double(stmt, index))
          case SQLITE_TEXT:    value = .text(sqlite3_column_string(stmt, index))
          case SQLITE_BLOB:    value = .data(sqlite3_column_data(stmt, index))
          default:             value = .null
          }
          
          return record.appending(value, for: .init(cString: name!))
        }
        
        result.append(record)
      case SQLITE_DONE:
        return
      default:
        throw Error(connection)
      }
    } while status != SQLITE_DONE
  }
  
  func reset(stmt: OpaquePointer) throws {
    let status = sqlite3_reset(stmt)
    if status != SQLITE_OK {
      throw Error(connection)
    }
  }
  
  func finalize(stmt: OpaquePointer) {
    sqlite3_finalize(stmt)
  }
}
