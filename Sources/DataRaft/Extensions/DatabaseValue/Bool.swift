import Foundation

extension Bool: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue {
    return .int(self ? 1 : 0)
  }
  
  public init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.int(value) = databaseValue {
      self = value == 1
    } else {
      return nil
    }
  }
}
