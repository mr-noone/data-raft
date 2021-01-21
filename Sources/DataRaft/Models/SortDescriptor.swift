import Foundation

public struct SortDescriptor {
  public let column: SQLColumn
  public let ascending: Bool?
  public let nullsFirst: Bool?
  
  public init(by column: SQLColumn, ascending: Bool? = nil, nullsFirst: Bool? = nil) {
    self.column = column
    self.ascending = ascending
    self.nullsFirst = nullsFirst
  }
  
  func apply(to query: OrderByQuery) -> OrderByQuery & LimitQuery & SQLConvertible {
    var sortQuery = query.order(by: column)
    
    switch ascending {
    case true: sortQuery = sortQuery.ascending()
    case false: sortQuery = sortQuery.descending()
    default: break
    }
    
    switch nullsFirst {
    case true: sortQuery = sortQuery.nullsFirst()
    case false: sortQuery = sortQuery.nullsLast()
    default: break
    }
    
    return sortQuery
  }
}
