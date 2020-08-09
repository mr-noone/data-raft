import Foundation

public extension DatabaseValueConvertible where Self: UnsignedInteger {
  var databaseValue: DatabaseValue {
    return .int(.init(self))
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.int(value) = databaseValue {
      self.init(value)
    } else {
      return nil
    }
  }
}

extension UInt: DatabaseValueConvertible {}
extension UInt8: DatabaseValueConvertible {}
extension UInt16: DatabaseValueConvertible {}
extension UInt32: DatabaseValueConvertible {}
extension UInt64: DatabaseValueConvertible {}
