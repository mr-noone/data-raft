import Foundation
import CSQLite

func sqlite3_column_data(_ stmt: OpaquePointer!, _ iCol: Int32) -> Data {
  return Data(
    bytes: sqlite3_column_blob(stmt, iCol),
    count: Int(sqlite3_column_bytes(stmt, iCol))
  )
}

func sqlite3_column_string(_ stmt: OpaquePointer!, _ iCol: Int32) -> String {
  return String(cString: sqlite3_column_text(stmt, iCol))
}
