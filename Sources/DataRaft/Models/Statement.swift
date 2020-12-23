import Foundation
import CSQLite
import SQLighter

final class Statement {
  private let statement: OpaquePointer
  private let connection: OpaquePointer
  
  init(db connection: OpaquePointer, sql: String) throws {
    var statement: OpaquePointer! = nil
    let status = sqlite3_prepare_v2(connection, sql, -1, &statement, nil)
    
    if status == SQLITE_OK, let statement = statement {
      self.statement = statement
      self.connection = connection
    } else {
      sqlite3_finalize(statement)
      throw Error(connection)
    }
  }
  
  deinit {
    sqlite3_finalize(statement)
  }
  
  func bind(args: Arguments?) throws {
    guard let args = args else { return }
    
    var status: Int32
    var index: Int32
    
    for arg in args.enumerated() {
      index = Int32(arg.offset + 1)
      
      switch arg.element {
      case .null:             status = sqlite3_bind_null(statement, index)
      case .int(let value):   status = sqlite3_bind_int64(statement, index, value)
      case .real(let value):  status = sqlite3_bind_double(statement, index, value)
      case .text(let value):  status = sqlite3_bind_string(statement, index, value)
      case .data(let value):  status = sqlite3_bind_data(statement, index, value)
      }
      
      if status != SQLITE_OK {
        throw Error(connection)
      }
    }
  }
  
  func step(result: inout [Record]) throws {
    var status: Int32
    repeat {
      status = sqlite3_step(statement)
      switch status {
      case SQLITE_ROW:
        let record = (0..<sqlite3_column_count(statement)).reduce(Record()) { record, index in
          let type = sqlite3_column_type(statement, index)
          let name = sqlite3_column_name(statement, index)
          let value: SQLValue
          
          switch type {
          case SQLITE_INTEGER: value = .int(sqlite3_column_int64(statement, index))
          case SQLITE_FLOAT:   value = .real(sqlite3_column_double(statement, index))
          case SQLITE_TEXT:    value = .text(sqlite3_column_string(statement, index))
          case SQLITE_BLOB:    value = .data(sqlite3_column_data(statement, index))
          default:             value = .null
          }
          
          return record.appending(value, for: String(cString: name!))
        }
        
        result.append(record)
      case SQLITE_DONE:
        return
      default:
        throw Error(connection)
      }
    } while status != SQLITE_DONE
  }
  
  func reset() throws {
    if sqlite3_reset(statement) != SQLITE_OK {
      throw Error(connection)
    }
  }
}
