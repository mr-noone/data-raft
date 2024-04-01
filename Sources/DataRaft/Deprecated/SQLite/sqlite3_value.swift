import Foundation
import CSQLite

func sqlite3_value_data(_ value: OpaquePointer!) -> Data {
  return Data(
    bytes: sqlite3_value_blob(value),
    count: Int(sqlite3_value_bytes(value)))
}

func sqlite3_value_string(_ value: OpaquePointer!) -> String {
  return String(cString: sqlite3_value_text(value))
}
