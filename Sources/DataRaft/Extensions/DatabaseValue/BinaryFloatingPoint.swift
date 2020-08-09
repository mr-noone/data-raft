import Foundation

public extension DatabaseValueConvertible where Self: BinaryFloatingPoint {
  var databaseValue: DatabaseValue {
    return .double(.init(self))
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.double(value) = databaseValue {
      self.init(value)
    } else {
      return nil
    }
  }
}

extension Float: DatabaseValueConvertible {}
extension Double: DatabaseValueConvertible {}
