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

extension Data {
    /// A hexadecimal representation of the data.
    ///
    /// This property returns a hexadecimal string representation of the data.
    ///
    /// Example:
    /// ```swift
    /// let data = Data([0x48, 0x65, 0x6C, 0x6C, 0x6F])
    /// print(data.hex) // Output: "48656C6C6F"
    /// ```
    var hex: String {
        map { String(format: "%02hhX", $0) }.joined()
    }
}
