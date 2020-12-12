import Foundation

public protocol Migration {
  static var version: Int { get }
  static func migrate(_ connection: Connection) throws
}
