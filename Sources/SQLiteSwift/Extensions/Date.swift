import Foundation

/// A protocol extension that allows `Date` to be converted to and from SQLite values.
extension Date: SQLiteConvertible {
    /// Converts a `Date` instance to an SQLite text value using the ISO8601 date formatter.
    public var sqliteValue: SQLiteValue {
        .text(ISO8601DateFormatter().string(from: self))
    }
    
    /// Initializes a `Date` instance from an SQLite value.
    ///
    /// - Parameter sqliteValue: The SQLite value to convert to a `Date`.
    /// - Returns: A `Date` instance if conversion succeeds, or `nil` if the value cannot be converted.
    public init?(_ sqliteValue: SQLiteValue) {
        switch sqliteValue {
        case .int(let value):
            self.init(timeIntervalSince1970: TimeInterval(value))
        case .real(let value):
            self.init(timeIntervalSince1970: value)
        case .text(let value):
            if let date = ISO8601DateFormatter().date(from: value) {
                self = date
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
