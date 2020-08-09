import Foundation

public enum Pragma: String {
  case journalMode = "journal_mode"
  case userVersion = "user_version"
  case foreignKeys = "foreign_keys"
}

extension Pragma: CustomStringConvertible {
  public var description: String {
    return rawValue
  }
}
