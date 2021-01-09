import Foundation
import SQLighter
import CSQLite

final class Function: Pointer, Hashable {
  // MARK: - Properties
  
  let name: String
  let argc: Int32
  let closure: Connection.DatabaseFunction
  
  // MARK: - Inits
  
  init(name: String, argc: Int32, closure: @escaping Connection.DatabaseFunction) {
    self.name = name
    self.argc = argc
    self.closure = closure
  }
  
  // MARK: - Methods
  
  func install(in connection: OpaquePointer) throws {
    let status = sqlite3_create_function(connection, name.cString(using: .utf8), argc, SQLITE_UTF8, *self, { (ctx, argc, argv) in
      Unmanaged<Function>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue().invoke(ctx, argc, argv)
    }, nil, nil)
    
    if status != SQLITE_OK {
      throw Error(connection)
    }
  }
  
  func uninstall(in connection: OpaquePointer) throws {
    let status = sqlite3_create_function(connection, name.cString(using: .utf8), argc, SQLITE_UTF8, nil, nil, nil, nil)
    if status != SQLITE_OK {
      throw Error(connection)
    }
  }
  
  private func invoke(_ ctx: OpaquePointer?, _ argc: Int32, _ argv: UnsafeMutablePointer<OpaquePointer?>?) {
    do {
      switch try closure(.init(argc: argc, argv: argv))?.sqlValue ?? .null {
      case .null:             sqlite3_result_null(ctx)
      case .int(let value):   sqlite3_result_int64(ctx, value)
      case .real(let value):  sqlite3_result_double(ctx, value)
      case .text(let value):  sqlite3_result_string(ctx, value)
      case .data(let value):  sqlite3_result_data(ctx, value)
      }
    } catch {
      let message = error.localizedDescription
      sqlite3_result_error(ctx, message, Int32(message.count))
    }
  }
  
  // MARK: - Hashable
  
  static func == (lhs: Function, rhs: Function) -> Bool {
    return lhs.name == rhs.name && lhs.argc == rhs.argc
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(argc)
  }
}
