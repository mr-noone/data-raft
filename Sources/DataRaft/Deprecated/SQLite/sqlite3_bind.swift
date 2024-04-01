import Foundation
import CSQLite

let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)

@discardableResult
func sqlite3_bind_string(_ stmt: OpaquePointer!, _ index: Int32, _ string: String) -> Int32 {
  return sqlite3_bind_text(stmt, index, string, -1, SQLITE_TRANSIENT)
}

@discardableResult
func sqlite3_bind_data(_ stmt: OpaquePointer!, _ index: Int32, _ data: Data) -> Int32 {
  return data.withUnsafeBytes {
    sqlite3_bind_blob(stmt, index, $0.baseAddress, Int32($0.count), SQLITE_TRANSIENT)
  }
}
