import Foundation
import SQLighter
import CSQLite

public struct FunctionArguments {
  public typealias Element = SQLValue
  
  // MARK: - Properties
  
  private let argc: Int32
  private let argv: UnsafeMutablePointer<OpaquePointer?>?
  
  // MARK: - Inits
  
  init(argc: Int32, argv: UnsafeMutablePointer<OpaquePointer?>?) {
    self.argc = argc
    self.argv = argv
  }
  
  // MARK: - Methods
  
  private subscript(index: Int) -> SQLValue {
    guard Int(argc) > index else { fatalError("\(index) out of bounds") }
    let arg = argv.unsafelyUnwrapped[index]
    switch sqlite3_value_type(arg) {
    case SQLITE_INTEGER: return .int(sqlite3_value_int64(arg))
    case SQLITE_FLOAT:   return .real(sqlite3_value_double(arg))
    case SQLITE_TEXT:    return .text(sqlite3_value_string(arg))
    case SQLITE_BLOB:    return .data(sqlite3_value_data(arg))
    default:             return .null
    }
  }
  
  public subscript<T: SQLValueConvertible>(index: Int) -> T? {
    return T(self[index])
  }
}
