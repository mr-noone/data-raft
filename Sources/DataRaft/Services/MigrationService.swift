import Foundation
import SQLiteSwift

/// A service for managing database migrations.
///
/// The `MigrationService` class allows you to manage database migrations by organizing
/// and executing SQL scripts to update the database schema to a newer version.
/// It keeps track of applied migrations and ensures that each migration is applied only once.
///
/// Example usage:
/// ```swift
/// // Create a MigrationService instance
/// let migrationService = MigrationService()
///
/// // Define migrations
/// let migration1 = Migration(version: 1, byResource: "migration_1", extension: "sql")!
/// let migration2 = Migration(version: 2, byResource: "migration_2", extension: "sql")!
/// let migration3 = Migration(version: 3, byResource: "migration_3", extension: "sql")!
///
/// do {
///     // Add migrations to the service
///     try migrationService.add(migration1)
///     try migrationService.add(migration2)
///     try migrationService.add(migration3)
///
///     // Perform database migration
///     try migrationService.migrate()
///
///     print("Database migration completed successfully.")
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
public final class MigrationService: DatabaseService {
    /// An error type representing issues encountered during migration operations.
    public enum Error: Swift.Error {
        /// An error indicating that a migration with
        /// the same version or script URL already exists in the service.
        case duplicateMigration(version: Int32, url: URL)
        
        /// An error indicating that a migration failed to execute.
        case migrationFailed(version: Int32, url: URL, error: Swift.Error)
    }
    
    // MARK: - Properties
    
    private var migrations = Set<Migration>()
    
    // MARK: - Inits
    
    /// Adds a migration to the service.
    ///
    /// This method adds the specified migration to the set of migrations managed by the service.
    ///
    /// - Parameter migration: The migration to be added.
    /// - Throws: `Error.duplicateMigration` if a migration with the same version or script URL already exists in the service.
    public func add(_ migration: Migration) throws {
        guard !migrations.contains(where: {
            $0.version == migration.version || $0.scriptURL == migration.scriptURL
        }) else {
            throw Error.duplicateMigration(
                version: migration.version,
                url: migration.scriptURL
            )
        }
        migrations.insert(migration)
    }
    
    /// Executes pending migrations.
    ///
    /// This method executes pending migrations by comparing the current database version
    /// with the version of each migration.
    /// It applies migrations with versions higher than the current database version in ascending order.
    ///
    /// - Throws: `Error.migrationFailed` if there is an issue executing the migrations.
    public func migrate() throws {
        try perform(in: .exclusive) { connection in
            let version = connection.userVersion
            try migrations.filter {
                $0.version > version
            }.sorted {
                $0.version < $1.version
            }.forEach {
                do {
                    let script = try SQLScript(contentsOf: $0.scriptURL)
                    try connection.execute(sql: script)
                } catch {
                    throw Error.migrationFailed(
                        version: $0.version,
                        url: $0.scriptURL,
                        error: error
                    )
                }
                connection.userVersion = $0.version
            }
        }
    }
}
