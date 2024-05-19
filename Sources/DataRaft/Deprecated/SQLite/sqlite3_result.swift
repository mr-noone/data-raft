import Foundation
import CSQLite

func sqlite3_result_string(_ ctx: OpaquePointer!, _ string: String) {
  sqlite3_result_text(ctx, string, -1, SQLITE_TRANSIENT)
}

func sqlite3_result_data(_ ctx: OpaquePointer!, _ data: Data) {
  data.withUnsafeBytes {
    sqlite3_result_blob(ctx, $0.baseAddress, Int32($0.count), SQLITE_TRANSIENT)
  }
}
