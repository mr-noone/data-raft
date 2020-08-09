import Foundation

extension UUID: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue {
    return .text(uuidString)
  }
  
  public init?(_ databaseValue: DatabaseValue) {
    switch databaseValue {
    case .text(let string): self.init(uuidString: string)
    default: return nil
    }
  }
}
