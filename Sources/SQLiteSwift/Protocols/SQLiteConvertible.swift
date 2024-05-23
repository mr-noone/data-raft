import Foundation

/// The `SQLiteConvertible` protocol inherits from `SQLiteBindable`
/// and defines a type that can be converted from an SQL value.
public protocol SQLiteConvertible: SQLiteBindable {
    /// Initializes an instance of the type from an SQL value.
    ///
    /// - Parameter sqliteValue: The SQL value.
    init?(_ sqliteValue: SQLiteValue)
}
