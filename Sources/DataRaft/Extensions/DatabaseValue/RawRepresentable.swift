import Foundation

extension DatabaseValueConvertible where Self: RawRepresentable, RawValue: DatabaseValueConvertible {
  var databaseValue: DatabaseValue {
    return rawValue.databaseValue
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if let value = RawValue(databaseValue) {
      self.init(rawValue: value)
    } else {
      return nil
    }
  }
}
