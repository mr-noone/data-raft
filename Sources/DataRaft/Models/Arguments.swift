import Foundation

public struct Arguments: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, Sequence, IteratorProtocol {
  public typealias Element = (index: Index, value: DatabaseValue)
  
  public enum Index {
    case index(Int32)
    case name(String)
    
    var index: Int32! {
      switch self {
      case .index(let index): return index
      default: return nil
      }
    }
    
    var name: String! {
      switch self {
      case .name(let name): return name
      default: return nil
      }
    }
    
    init(index: Int) {
      self = .index(Int32(index + 1))
    }
    
    init(name: String) {
      self = .name(":\(name)")
    }
  }
  
  private var values: [Element] = []
  private var cursor: Int = 0
  
  public init(arrayLiteral elements: DatabaseValueConvertible?...) {
    values = elements.enumerated().map { (.init(index: $0.offset), $0.element?.databaseValue ?? .null) }
  }
  
  public init(array elements: [DatabaseValueConvertible?]) {
    values = elements.enumerated().map { (.init(index: $0.offset), $0.element?.databaseValue ?? .null) }
  }
  
  public init(dictionaryLiteral elements: (String, DatabaseValueConvertible?)...) {
    values = elements.map { (.init(name: $0), $1?.databaseValue ?? .null) }
  }
  
  init(record: Record) {
    values = record.map { (.init(name: $0.name), $0.value) }
  }
  
  public func makeIterator() -> Arguments {
    return self
  }
  
  mutating public func next() -> Element? {
    if cursor < values.count {
      return values[cursor++]
    } else {
      return nil
    }
  }
}
