import Foundation

public struct Record: Sequence, IteratorProtocol {
  public typealias Name = String
  public typealias Value = DatabaseValue
  public typealias Element = (name: Name, value: Value)
  
  private var values: [Element] = []
  private var cursor: Int = 0
  
  public var names: [String] {
    values.map { $0.name }
  }
  
  public var indexes: [Arguments.Index] {
    values.map { .init(name: $0.name) }
  }
  
  public var first: Element? {
    values.first
  }
  
  public subscript(name: Name) -> Value? {
    get {
      return values.first { $0.name == name }?.value
    }
    set {
      if let value = newValue {
        if let index = values.firstIndex(where: { $0.name == name }) {
          values[index].value = value
        } else {
          values.append((name, value))
        }
      } else {
        values.removeAll { $0.name == name }
      }
    }
  }
  
  public func appending(_ value: Value, for name: Name) -> Record {
    var record = self
    record[name] = value
    return record
  }
  
  public func makeIterator() -> Record {
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
