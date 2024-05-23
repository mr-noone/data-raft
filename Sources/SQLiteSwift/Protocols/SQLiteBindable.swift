import Foundation

/// The `SQLiteBindable` protocol defines a type that can be bound to a parameter in an SQL statement.
public protocol SQLiteBindable {
    /// Returns the value that can be bound to an SQL parameter.
    var sqliteValue: SQLiteValue { get }
}

extension SQLiteBindable {
    /// Returns the SQL literal representation of the bindable value.
    var sqliteLiteral: String {
        sqliteValue.sqliteLiteral
    }
}
