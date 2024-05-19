import Foundation

/// A protocol extension that allows `Bool` values to be converted to and from SQLite values.
extension Bool: SQLiteConvertible {
    /// Converts a `Bool` value to an SQLite integer value.
    public var sqliteValue: SQLiteValue {
        .int(self ? 1 : 0)
    }
    
    /// Initializes a `Bool` value from an SQLite value.
    ///
    /// - Parameter sqliteValue: The SQLite value to convert to a `Bool`.
    /// - Returns: A `Bool` value if conversion succeeds, or `nil` if the value cannot be converted.
    public init?(_ sqliteValue: SQLiteValue) {
        switch sqliteValue {
        case .int(let value) where 0...1 ~= value:
            self = value == 1
        default:
            return nil
        }
    }
}
