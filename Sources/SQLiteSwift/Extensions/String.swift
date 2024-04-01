import Foundation

/// An extension of the `String` type to conform to the `SQLiteConvertible` protocol,
/// allowing strings to be converted to and from SQLite values.
extension String: SQLiteConvertible {
    /// Converts the string to an SQLite value.
    public var sqliteValue: SQLiteValue {
        .text(self)
    }
    
    /// Initializes a string from an SQLite value.
    ///
    /// - Parameter sqliteValue: The SQLite value representing the string.
    /// - Returns: A `String` if conversion succeeds, or `nil` if the value cannot be converted.
    public init?(_ sqliteValue: SQLiteValue) {
        switch sqliteValue {
        case .text(let value):
            self = value
        default:
            return nil
        }
    }
}
