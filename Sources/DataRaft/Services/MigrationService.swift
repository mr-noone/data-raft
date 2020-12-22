import Foundation

public protocol MigrationServiceProtocol {
  func add(_ migration: Migration.Type) -> Self
  func migrate() throws
}

public final class MigrationService: MigrationServiceProtocol {
  private let connection: Connection
  private var migrations: [Migration.Type] = []
  
  public init(_ connection: Connection) {
    self.connection = connection
  }
  
  @discardableResult
  public func add(_ migration: Migration.Type) -> Self {
    migrations.append(migration)
    return self
  }
  
  public func migrate() throws {
    let version = try connection.get(pragma: .userVersion) ?? 0
    try migrations.filter {
      $0.version > version
    }.sorted {
      $0.version < $1.version
    }.forEach { migration in
      try connection.perform(in: .exclusive) {
        try migration.migrate(connection)
        try connection.set(pragma: .userVersion, value: migration.version)
      }
    }
  }
}
