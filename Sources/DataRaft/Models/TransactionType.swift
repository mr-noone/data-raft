import Foundation

public enum TransactionType {
  case deferred
  case immediate
  case exclusive
}

extension TransactionType: CustomStringConvertible {
  public var description: String {
    switch self {
    case .deferred:  return "DEFERRED"
    case .immediate: return "IMMEDIATE"
    case .exclusive: return "EXCLUSIVE"
    }
  }
}
