import Foundation

extension Date: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue {
    return .text(DateFormatter.iso8601.string(from: self))
  }
  
  public init?(_ databaseValue: DatabaseValue) {
    guard
      case let DatabaseValue.text(value) = databaseValue,
      let date = DateFormatter.iso8601.date(from: value)
    else {
      return nil
    }
    self = date
  }
}
