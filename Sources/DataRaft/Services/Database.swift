import Foundation

public class Database {
  // MARK: - Properties
  
  private let mainConnection: Connection
  private let observConnection: Connection
  private var observers = [ObserverBox]()
  
  private lazy var didUpdate: Connection.DidUpdateCallback = { [unowned self] event in
    self.observers.compactMap { $0.unbox }.filter {
      $0.observes(event: event)
    }.forEach {
      $0.connectionDidChange(self.observConnection, event: event)
    }
  }
  
  private lazy var willCommit: Connection.WillCommitCallback = { [unowned self] in
    try self.observers.compactMap { $0.unbox }.forEach { try $0.connectionWillCommit(self.observConnection) }
  }
  
  private lazy var didCommit: Connection.DidCommitCallback = { [unowned self] in
    self.observers.compactMap { $0.unbox }.forEach { $0.connectionDidCommit(self.observConnection) }
  }
  
  private lazy var didRollback: Connection.DidRollbackCallback = { [unowned self] in
    self.observers.compactMap { $0.unbox }.forEach { $0.connectionDidRollback(self.observConnection) }
  }
  
  // MARK: - Inits
  
  public init(path: String, config: DatabaseConfig) throws {
    mainConnection = try Connection(path: path)
    observConnection = try Connection(path: path)
    
    mainConnection.trace = config.trace
    mainConnection.busyTimeout = config.busyTimeout
    observConnection.trace = config.trace
    observConnection.busyTimeout = config.busyTimeout
    
    mainConnection.didUpdate = didUpdate
    mainConnection.willCommit = willCommit
    mainConnection.didCommit = didCommit
    mainConnection.didRollback = didRollback
    
    try mainConnection.setPragma(.journalMode, value: JournalMode.wal)
    try mainConnection.setPragma(.foreignKeys, value: "ON")
  }
}

// MARK: - Public

public extension Database {
  func add(_ observer: TransactionObserver, extent: ObservationExtent) {
    switch extent {
    case .observerLifetime: observers.append(.init(weak: observer))
    case .databaseLifetime: observers.append(.init(strong: observer))
    }
  }
  
  func perform<T>(closure: @escaping (Connection) throws -> (T)) throws -> T {
    return try mainConnection.perform { [connection = mainConnection] in
      try closure(connection)
    }
  }
  
  func perform<T>(in transaction: TransactionType, closure: @escaping (Connection) throws -> (T)) throws -> T {
    if mainConnection.isExplicitTransaction() {
      return try perform(closure: closure)
    } else {
      return try mainConnection.perform { [connection = mainConnection] in
        do {
          try connection.beginTransaction()
          let result = try closure(connection)
          try connection.commitTransaction()
          return result
        } catch {
          try connection.rollbackTransaction()
          throw error
        }
      }
    }
  }
}
