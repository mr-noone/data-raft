import Foundation
import SQLighter

public protocol CRUDServiceProtocol {
  func batch<T>(closure: @escaping (CRUDServiceProtocol) throws -> (T)) throws -> T
  
  func read<M: Model>(_ id: M.ID) throws -> M?
  func read<M: Model>(_ predicate: Predicate) throws -> M?
  func read<M: Model>(_ predicate: Predicate) throws -> [M]
  func read<M: Model>(_ predicate: Predicate, sortBy descriptors: [SortDescriptor]) throws -> [M]
  func read<M: Model>(_ predicate: Predicate, limit: UInt, offset: UInt) throws -> [M]
  func read<M: Model>(_ predicate: Predicate, sortBy descriptors: [SortDescriptor], limit: UInt, offset: UInt) throws -> [M]
  
  func count<M: Model>(_ predicate: Predicate, type: M.Type) throws -> Int
  
  func exists<M: Model>(_ id: M.ID, type: M.Type) throws -> Bool
  func exists<M: Model>(_ predicate: Predicate, type: M.Type) throws -> Bool
  
  func create<M: Model>(_ model: M) throws
  func create<M: Model>(_ models: [M]) throws
  
  func update<M: Model>(_ model: M) throws
  func update<M: Model>(_ models: [M]) throws
  
  func delete<M: Model>(_ id: M.ID, type: M.Type) throws
  func delete<M: Model>(_ model: M) throws
  func delete<M: Model>(_ models: [M]) throws
}

public final class CRUDService {
  private let connection: Connection
  private let coder: RecordCoder
  
  public init(db connection: Connection, coder: RecordCoder = RecordCoder()) {
    self.connection = connection
    self.coder = coder
  }
}

extension CRUDService: CRUDServiceProtocol {
  public func batch<T>(closure: @escaping (CRUDServiceProtocol) throws -> (T)) throws -> T {
    return try connection.perform(in: .deferred) {
      return try closure(self)
    }
  }
  
  public func read<M>(_ id: M.ID) throws -> M? where M : Model {
    return try read(M.idKey == id, limit: 1, offset: 0).first
  }
  
  public func read<M>(_ predicate: Predicate) throws -> M? where M : Model {
    return try read(predicate).first
  }
  
  public func read<M>(_ predicate: Predicate) throws -> [M] where M : Model {
    return try connection.perform(in: .deferred) {
      let query = SQL.select(from: M.table).where(predicate).sqlQuery()
      let records: [Record] = try connection.execute(sql: query.sql, args: query.args)
      return try records.map { try coder.decode(M.self, from: $0) }
    }
  }
  
  public func read<M>(_ predicate: Predicate, sortBy descriptors: [SortDescriptor]) throws -> [M] where M : Model {
    return try connection.perform(in: .deferred) {
      var sortQuery: OrderByQuery & SQLConvertible = SQL.select(from: M.table).where(predicate)
      descriptors.forEach { sortQuery = $0.apply(to: sortQuery) }
      
      let query = sortQuery.sqlQuery()
      let records: [Record] = try connection.execute(sql: query.sql, args: query.args)
      return try records.map { try coder.decode(M.self, from: $0) }
    }
  }
  
  public func read<M>(_ predicate: Predicate, limit: UInt, offset: UInt) throws -> [M] where M : Model {
    return try connection.perform(in: .deferred) {
      let query = SQL.select(from: M.table).where(predicate).limit(limit, offset: offset).sqlQuery()
      let records: [Record] = try connection.execute(sql: query.sql, args: query.args)
      return try records.map { try coder.decode(M.self, from: $0) }
    }
  }
  
  public func read<M>(_ predicate: Predicate, sortBy descriptors: [SortDescriptor], limit: UInt, offset: UInt) throws -> [M] where M : Model {
    return try connection.perform(in: .deferred) {
      var sortQuery: OrderByQuery & LimitQuery & SQLConvertible = SQL.select(from: M.table).where(predicate)
      descriptors.forEach { sortQuery = $0.apply(to: sortQuery) }
      
      let query = sortQuery.limit(limit, offset: offset).sqlQuery()
      let records: [Record] = try connection.execute(sql: query.sql, args: query.args)
      return try records.map { try coder.decode(M.self, from: $0) }
    }
  }
  
  public func count<M>(_ predicate: Predicate, type: M.Type) throws -> Int where M : Model {
    return try connection.perform(in: .deferred) {
      let query = SQL.count(from: type.table).where(predicate).sqlQuery()
      return try connection.execute(sql: query.sql, args: query.args) ?? 0
    }
  }
  
  public func exists<M>(_ id: M.ID, type: M.Type) throws -> Bool where M : Model {
    return try exists(M.idKey == id, type: type)
  }
  
  public func exists<M>(_ predicate: Predicate, type: M.Type) throws -> Bool where M : Model {
    return try connection.perform(in: .deferred) {
      let query = SQL.exists(in: M.table).where(predicate).sqlQuery()
      return try connection.execute(sql: query.sql, args: query.args) ?? false
    }
  }
  
  public func create<M>(_ model: M) throws where M : Model {
    try create([model])
  }
  
  public func create<M>(_ models: [M]) throws where M : Model {
    try connection.perform(in: .deferred) {
      let records = try models.map {
        try coder.encode($0)
      }
      
      if let first = records.first {
        let columns = first.columns.map { $0.sqlString }
        let sql = SQL.insert(into: M.table).column(columns).sqlQuery()
        let args = records.map { Arguments(record: $0) }
        try connection.execute(sql: sql.sql, args: args)
      }
    }
  }
  
  public func update<M>(_ model: M) throws where M : Model {
    try update([model])
  }
  
  public func update<M>(_ models: [M]) throws where M : Model {
    try connection.perform(in: .deferred) {
      let records = try models.map {
        try coder.encode($0)
      }
      
      if let first = records.first {
        let columns = first.columns.map { $0.sqlString }
        let sql = SQL.update(table: M.table).column(columns).where(M.idKey == .none).sqlQuery()
        let args = records.map { Arguments(record: $0) + Arguments(array: [$0[M.idKey] ?? .null]) }
        try connection.execute(sql: sql.sql, args: args)
      }
    }
  }
  
  public func delete<M>(_ id: M.ID, type: M.Type) throws where M : Model {
    try connection.perform(in: .deferred) {
      let sql = SQL.delete(from: type.table).where(type.idKey == id).sqlQuery()
      try connection.execute(sql: sql.sql, args: [sql.args])
    }
  }
  
  public func delete<M>(_ model: M) throws where M : Model {
    try delete([model])
  }
  
  public func delete<M>(_ models: [M]) throws where M : Model {
    try connection.perform(in: .deferred) {
      let predicate: Predicate
      if models.count == 1 {
        predicate = M.idKey == models.first!.id
      } else {
        predicate = M.idKey ~= models.map { $0.id }
      }
      
      let sql = SQL.delete(from: M.table).where(predicate).sqlQuery()
      try connection.execute(sql: sql.sql, args: [sql.args])
    }
  }
}
