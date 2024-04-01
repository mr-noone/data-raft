import Foundation

/// A type representing SQLite pragmas.
///
/// `SQLitePragma` provides a convenient way to work with SQLite pragmas, which
/// are special commands used to control various aspects of the SQLite database engine.
public struct SQLitePragma: RawRepresentable, CustomStringConvertible, ExpressibleByStringLiteral {
    /// The raw string value of the pragma.
    public var rawValue: String
    
    /// A textual representation of the pragma.
    public var description: String {
        rawValue
    }
    
    /// Represents the `journal_mode` pragma.
    ///
    /// This pragma is used to query or set the journal mode for the database connection.
    public static let journalMode: SQLitePragma = "journal_mode"
    
    /// Represents the `user_version` pragma.
    ///
    /// This pragma is typically used to query or set the user version number
    /// associated with the database file.
    public static let userVersion: SQLitePragma = "user_version"
    
    /// Represents the `foreign_keys` pragma.
    ///
    /// This pragma is used to enable or disable foreign key constraint enforcement.
    public static let foreignKeys: SQLitePragma = "foreign_keys"
    
    /// Initializes a `SQLitePragma` instance with the provided raw value.
    ///
    /// - Parameter rawValue: The raw string value of the pragma.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Initializes a `SQLitePragma` instance with the provided string literal.
    ///
    /// - Parameter value: The string literal representing the pragma.
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
