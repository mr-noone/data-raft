import Foundation
import SQLighter

public enum JournalMode: String, SQLValueConvertible {
  case delete   = "DELETE"
  case truncate = "TRUNCATE"
  case persist  = "PERSIST"
  case memory   = "MEMORY"
  case wal      = "WAL"
  case off      = "OFF"
}
