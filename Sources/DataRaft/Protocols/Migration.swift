import Foundation

public protocol Migration {
  static var version: Int { get }
  static var SQLs: [String] { get }
}
