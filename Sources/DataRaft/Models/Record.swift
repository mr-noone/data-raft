import Foundation
import SQLighter

public struct Record: Sequence, IteratorProtocol {
  public typealias Column = SQLColumn
  public typealias Value = SQLValue
  public typealias Element = (column: Column, value: Value)
  
  private var values: [Element] = []
  private var cursor: Int = 0
  
  public var columns: [Column] {
    values.map { $0.column }
  }
  
  public var first: Element? {
    values.first
  }
  
  public subscript(column: Column) -> Value? {
    get {
      values.first { $0.column.sqlString == column.sqlString }?.value
    }
    set {
      let predicate: (Element) -> Bool = {
        $0.column.sqlString == column.sqlString
      }
      
      if let value = newValue {
        if let index = values.firstIndex(where: predicate) {
          values[index].value = value
        } else {
          values.append((column, value))
        }
      } else {
        values.removeAll(where: predicate)
      }
    }
  }
  
  public func appending(_ value: Value, for column: Column) -> Record {
    var row = self
    row[column] = value
    return row
  }
  
  public func makeIterator() -> Record {
    return self
  }
  
  public mutating func next() -> (column: Column, value: Value)? {
    if cursor < values.count {
      return values[cursor++]
    } else {
      return nil
    }
  }
}
