import Foundation

/// A protocol extension that allows `UUID` to be converted to and from SQLite values.
extension UUID: SQLiteConvertible {
    /// Converts a `UUID` instance to an SQLite text value.
    public var sqliteValue: SQLiteValue {
        .text(uuidString)
    }
    
    /// Initializes a `UUID` instance from an SQLite value.
    ///
    /// - Parameter sqliteValue: The SQLite value to convert to a `UUID`.
    /// - Returns: A `UUID` instance if conversion succeeds, or `nil` if the value cannot be converted.
    public init?(_ sqliteValue: SQLiteValue) {
        switch sqliteValue {
        case .text(let value):
            self.init(uuidString: value)
        default:
            return nil
        }
    }
}
