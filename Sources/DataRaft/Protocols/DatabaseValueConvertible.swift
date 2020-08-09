import Foundation

public protocol DatabaseValueConvertible {
  var databaseValue: DatabaseValue { get }
  init?(_ databaseValue: DatabaseValue)
}
