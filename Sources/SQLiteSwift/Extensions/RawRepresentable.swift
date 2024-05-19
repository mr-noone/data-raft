import Foundation

public extension SQLiteBindable where Self: RawRepresentable, RawValue: SQLiteBindable {
    var sqliteValue: SQLiteValue {
        rawValue.sqliteValue
    }
}

public extension SQLiteConvertible where Self: RawRepresentable, RawValue: SQLiteConvertible {
    init?(_ sqliteValue: SQLiteValue) {
        if let value = RawValue(sqliteValue) {
            self.init(rawValue: value)
        } else {
            return nil
        }
    }
}
