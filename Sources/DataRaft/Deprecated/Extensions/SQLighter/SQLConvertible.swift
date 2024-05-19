import Foundation
import SQLighter

public extension SQLConvertible {
  func execute(on connection: Connection) throws {
    let query = sqlQuery()
    try connection.execute(sql: query.sql, args: [query.args])
  }
}
