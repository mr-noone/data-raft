import Foundation

public extension DatabaseValueConvertible where Self: StringProtocol {
  var databaseValue: DatabaseValue {
    return .text(String(self))
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.text(value) = databaseValue {
      self.init(value)
    } else {
      return nil
    }
  }
}

extension String: DatabaseValueConvertible {}
