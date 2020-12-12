import Foundation
import SQLighter

public protocol Model: Codable {
  associatedtype ID: Codable & SQLValueConvertible
  static var table: String { get }
  static var idKey: String { get }
  var id: ID { get }
}

public extension Model {
  static var table: String { String(describing: Self.self) }
  static var idKey: String { "id" }
}
