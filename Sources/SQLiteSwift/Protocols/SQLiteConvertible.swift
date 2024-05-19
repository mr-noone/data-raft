import Foundation

/// The `SQLiteConvertible` protocol inherits from `SQLiteBindable`
/// and defines a type that can be converted from an SQL value.
public protocol SQLiteConvertible: SQLiteBindable {
    /// Initializes an instance of the type from an SQL value.
    ///
    /// - Parameter sqliteValue: The SQL value.
    init?(_ sqliteValue: SQLiteValue)
}

extension SQLiteConvertible {
    /// Returns a string literal representation of the SQLite convertible value.
    var sqliteLiteral: String {
        sqliteValue.sqliteLiteral
    }
}
