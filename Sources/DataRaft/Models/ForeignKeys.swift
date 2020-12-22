import Foundation
import SQLighter

public enum ForeignKeys: String, SQLValueConvertible {
  case on   = "ON"
  case off  = "OFF"
}
