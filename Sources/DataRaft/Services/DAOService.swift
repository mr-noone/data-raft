import Foundation

public protocol DAOServiceProtocol {
  func batch<T>(closure: @escaping (DAOServiceProtocol) throws -> (T)) throws -> T
  
  func read<M: Model>(_ id: M.ID) throws -> M?
  func read<M: Model>(_ request: DAORequest<M>) throws -> M?
  func read<M: Model>(_ request: DAORequest<M>) throws -> [M]
  
  func exists<M: Model>(_ id: M.ID, type: M.Type) throws -> Bool
  func exists<M: Model>(_ request: DAORequest<M>, type: M.Type) throws -> Bool
  
  func create<M: Model>(_ model: M) throws
  func create<M: Model>(_ models: [M]) throws
  
  func update<M: Model>(_ model: M) throws
  func update<M: Model>(_ models: [M]) throws
  
  func delete<M: Model>(_ id: M.ID, type: M.Type) throws
  func delete<M: Model>(_ model: M) throws
  func delete<M: Model>(_ models: [M]) throws
}

public class DAOService: DAOServiceProtocol {
  // MARK: - Properties
  
  private let database: Database
  private let coder: RecordCoder
  
  // MARK: - Inits
  
  public init(db database: Database, coder: RecordCoder = RecordCoder()) {
    self.database = database
    self.coder = coder
  }
  
  // MARK: - DAOServiceProtocol
  
  public func batch<T>(closure: @escaping (DAOServiceProtocol) throws -> (T)) throws -> T {
    return try database.perform(in: .deferred) { _ in
      return try closure(self)
    }
  }
  
  public func read<M: Model>(_ id: M.ID) throws -> M? {
    return try read(.by(id: id))
  }
  
  public func read<M: Model>(_ request: DAORequest<M>) throws -> M? {
    return try read(request).first
  }
  
  public func read<M: Model>(_ request: DAORequest<M>) throws -> [M] {
    return try database.perform(in: .deferred) { connection in
      let records: [Record] = try connection.execute(sql: request.sql, args: request.args)
      return try records.map { try self.coder.decode(M.self, from: $0) }
    }
  }
  
  public func exists<M: Model>(_ id: M.ID, type: M.Type) throws -> Bool {
    return try exists(.by(id: id), type: type)
  }
  
  public func exists<M: Model>(_ request: DAORequest<M>, type: M.Type) throws -> Bool {
    return try database.perform(in: .deferred) { connection in
      let sql = "SELECT EXISTS (\(request.sql))"
      return try connection.execute(sql: sql, args: request.args) ?? false
    }
  }
  
  public func create<M: Model>(_ model: M) throws {
    try create([model])
  }
  
  public func create<M: Model>(_ models: [M]) throws {
    try database.perform(in: .deferred) { connection in
      let records = try models.map {
        try self.coder.encode($0)
      }
      
      if let first = records.first {
        let columns = first.names.joined(separator: ", ")
        let indexes = first.indexes.map { $0.name! }.joined(separator: ", ")
        let sql = "INSERT INTO \(M.tableName) (\(columns)) VALUES (\(indexes))"
        
        let args = records.map { Arguments(record: $0) }
        try connection.execute(sql: sql, args: args)
      }
    }
  }
  
  public func update<M: Model>(_ model: M) throws {
    try update([model])
  }
  
  public func update<M: Model>(_ models: [M]) throws {
    try database.perform(in: .deferred) { connection in
      let records = try models.map {
        try self.coder.encode($0)
      }
      
      if let first = records.first {
        let zip = Swift.zip(first.names, first.indexes)
        let set = zip.filter { $0.0 != M.idKey }.map { "\($0.0)=\($0.1.name!)" }.joined(separator: ", ")
        let `where` = zip.first { $0.0 == M.idKey }.map { "\($0.0)=\($0.1.name!)" }!
        let sql = "UPDATE \(M.tableName) SET \(set) WHERE \(`where`)"
        
        let args = records.map { Arguments(record: $0) }
        try connection.execute(sql: sql, args: args)
      }
    }
  }
  
  public func delete<M: Model>(_ id: M.ID, type: M.Type) throws {
    try database.perform(in: .deferred) { connection in
      let sql = "DELETE FROM \(type.tableName) WHERE \(type.idKey) = ?"
      try connection.execute(sql: sql, args: [[id]])
    }
  }
  
  public func delete<M: Model>(_ model: M) throws {
    try delete([model])
  }
  
  public func delete<M: Model>(_ models: [M]) throws {
    try database.perform(in: .deferred) { connection in
      let ids = models.map { "\($0.id)" }
      let prd = Array(repeating: "?", count: ids.count).joined(separator: ", ")
      let sql = "DELETE FROM \(M.tableName) WHERE \(M.idKey) IN (\(prd))"
      try connection.execute(sql: sql, args: [Arguments(array: ids)])
    }
  }
}
