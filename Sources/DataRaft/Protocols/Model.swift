import Foundation

public protocol Model: Codable {
  associatedtype ID: Codable & DatabaseValueConvertible
  static var tableName: String { get }
  static var idKey: String { get }
  var id: ID { get }
}

public extension Model {
  static var tableName: String {
    return String(describing: Self.self)
  }
  
  static var idKey: String {
    return "id"
  }
}
