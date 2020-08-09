import Foundation

public struct DAORequest<M: Model> {
  let sql: String
  let args: Arguments
  
  public init(sql: String, args: Arguments = []) {
    self.sql = sql
    self.args = args
  }
  
  public init(where: String, args: Arguments = []) {
    self.sql = "SELECT * FROM \(M.tableName) WHERE \(`where`)"
    self.args = args
  }
  
  public static func all() -> Self {
    return .init(sql: "SELECT * FROM \(M.tableName)")
  }
  
  public static func by(id: M.ID) -> Self {
    return .init(where: "\(M.idKey)=?", args: [id])
  }
  
  public static func by(rowID: Int64) -> Self {
    return .init(where: "rowid=?", args: [rowID])
  }
  
  public static func by(rowID ids: [Int64]) -> Self {
    let prd = Array(repeating: "?", count: ids.count).joined(separator: ", ")
    let `where` = "rowid IN (\(prd))"
    return .init(where: `where`, args: Arguments(array: ids))
  }
}
