import Foundation

public protocol MigratorProtocol {
  func add(_ migration: Migration.Type) -> Self
  func migrate() throws
}

public class Migrator: MigratorProtocol {
  // MARK: - Properties
  
  private let database: Database
  private var migrations: [Migration.Type] = []
  
  public init(db database: Database) {
    self.database = database
  }
  
  // MARK: - MigratorProtocol
  
  @discardableResult
  public func add(_ migration: Migration.Type) -> Self {
    migrations.append(migration)
    return self
  }
  
  public func migrate() throws {
    let version = try database.perform { connection in
      try connection.getPragma(.userVersion) ?? 0
    }
    
    try migrations.filter {
      $0.version > version
    }.sorted {
      $0.version < $1.version
    }.forEach { migration in
      try database.perform(in: .exclusive) { connection in
        try migration.SQLs.forEach { try connection.execute(sql: $0, args: []) }
        try connection.setPragma(.userVersion, value: migration.version)
      }
    }
  }
}
