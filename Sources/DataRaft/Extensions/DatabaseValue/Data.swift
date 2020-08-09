import Foundation

extension Data: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue {
    return .data(self)
  }
  
  public init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.data(value) = databaseValue {
      self = value
    } else {
      return nil
    }
  }
}
