import Foundation
import CSQLite

public struct Error: Swift.Error {
  public let status: Int32
  public let reason: String
  
  init(_ connection: OpaquePointer) {
    self.status = sqlite3_extended_errcode(connection)
    self.reason = String(cString: sqlite3_errmsg(connection))
  }
  
  init(status: Int32, reason: String) {
    self.status = status
    self.reason = reason
  }
}
