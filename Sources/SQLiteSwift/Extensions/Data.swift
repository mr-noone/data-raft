import Foundation

/// An extension of `Data` to conform to the `SQLiteConvertible` protocol.
extension Data: SQLiteConvertible {
    /// Converts the `Data` object to an SQLite blob value.
    public var sqliteValue: SQLiteValue {
        .blob(self)
    }
    
    /// Initializes a `Data` object from an SQLite blob value.
    ///
    /// - Parameter sqliteValue: The SQLite value representing the blob data.
    /// - Returns: A `Data` object if conversion succeeds, or `nil` if the value cannot be converted.
    public init?(_ sqliteValue: SQLiteValue) {
        switch sqliteValue {
        case .blob(let value):
            self = value
        default:
            return nil
        }
    }
}
