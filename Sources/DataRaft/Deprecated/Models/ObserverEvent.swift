import Foundation
import CSQLite

public struct ObserverEvent {
  public enum Kind: RawRepresentable {
    case insert
    case update
    case delete
    
    public var rawValue: Int32 {
      switch self {
      case .insert: return SQLITE_INSERT
      case .update: return SQLITE_UPDATE
      case .delete: return SQLITE_DELETE
      }
    }
    
    public init?(rawValue: Int32) {
      switch rawValue {
      case SQLITE_INSERT: self = .insert
      case SQLITE_UPDATE: self = .update
      case SQLITE_DELETE: self = .delete
      default: return nil
      }
    }
  }
  
  public let kind: Kind
  public let db: String
  public let table: String
  public let rowID: Int64
  
  init(kind: Kind, db: String, table: String, rowID: Int64) {
    self.kind = kind
    self.db = db
    self.table = table
    self.rowID = rowID
  }
  
  init?(kind: Int32, db: UnsafePointer<Int8>!, table: UnsafePointer<Int8>!, rowID: Int64) {
    guard let kind = Kind(rawValue: kind) else { return nil }
    self.kind = kind
    self.db = String(cString: db)
    self.table = String(cString: table)
    self.rowID = rowID
  }
}
