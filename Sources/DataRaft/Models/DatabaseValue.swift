import Foundation

public enum DatabaseValue {
  case null
  case int(Int64)
  case double(Double)
  case text(String)
  case data(Data)
}
