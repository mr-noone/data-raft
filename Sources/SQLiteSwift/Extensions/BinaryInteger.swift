import Foundation

/// An extension of `SQLiteBindable` for types conforming to `BinaryInteger`.
public extension SQLiteBindable where Self: BinaryInteger {
    /// Converts the conforming type to an SQLite integer value.
    var sqliteValue: SQLiteValue {
        .int(.init(self))
    }
}

/// An extension of `SQLiteConvertible` for types conforming to `BinaryInteger`.
public extension SQLiteConvertible where Self: BinaryInteger {
    /// Initializes a value of the conforming type from an SQLite integer value.
    ///
    /// - Parameter sqliteValue: The SQLite value to convert to the conforming type.
    /// - Returns: An instance of the conforming type if conversion succeeds, or `nil` if the value cannot be converted.
    init?(_ sqliteValue: SQLiteValue) {
        switch sqliteValue {
        case .int(let value):
            self.init(value)
        default:
            return nil
        }
    }
}

extension Int: SQLiteConvertible {}
extension Int8: SQLiteConvertible {}
extension Int16: SQLiteConvertible {}
extension Int32: SQLiteConvertible {}
extension Int64: SQLiteConvertible {}

extension UInt: SQLiteConvertible {}
extension UInt8: SQLiteConvertible {}
extension UInt16: SQLiteConvertible {}
extension UInt32: SQLiteConvertible {}
extension UInt64: SQLiteConvertible {}
