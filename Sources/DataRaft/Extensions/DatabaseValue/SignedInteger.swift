import Foundation

public extension DatabaseValueConvertible where Self: SignedInteger {
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

extension Int: DatabaseValueConvertible {}
extension Int8: DatabaseValueConvertible {}
extension Int16: DatabaseValueConvertible {}
extension Int32: DatabaseValueConvertible {}
extension Int64: DatabaseValueConvertible {}
