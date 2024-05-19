import Foundation

/// An extension of types conforming to `BinaryFloatingPoint` to conform to the `SQLiteBindable` protocol.
public extension SQLiteBindable where Self: BinaryFloatingPoint {
    /// Converts the `BinaryFloatingPoint` value to an SQLite real value.
    var sqliteValue: SQLiteValue {
        .real(.init(self))
    }
}

/// An extension of types conforming to `BinaryFloatingPoint` to conform to the `SQLiteConvertible` protocol.
public extension SQLiteConvertible where Self: BinaryFloatingPoint {
    /// Initializes a `BinaryFloatingPoint` value from an SQLite value.
    ///
    /// - Parameter sqliteValue: The SQLite value representing the floating-point data.
    /// - Returns: A `BinaryFloatingPoint` value if conversion succeeds, or `nil` if the value cannot be converted.
    init?(_ sqliteValue: SQLiteValue) {
        switch sqliteValue {
        case .int(let value):
            self.init(value)
        case .real(let value):
            self.init(value)
        default:
            return nil
        }
    }
}

extension Float: SQLiteConvertible {}
extension Double: SQLiteConvertible {}
