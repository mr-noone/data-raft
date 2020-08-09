import Foundation

enum JournalMode: String, DatabaseValueConvertible {
  case delete   = "DELETE"
  case truncate = "TRUNCATE"
  case persist  = "PERSIST"
  case memory   = "MEMORY"
  case wal      = "WAL"
  case off      = "OFF"
}

extension JournalMode: CustomStringConvertible {
  var description: String {
    return rawValue
  }
}
