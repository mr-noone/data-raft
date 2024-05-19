import Foundation
import SQLighter

final class RecordEncoder: Encoder {
  var codingPath: [CodingKey] { fatalError() }
  var userInfo: [CodingUserInfoKey : Any] { fatalError() }
  
  private(set) var record = Record()
  
  func encodeNil(for key: CodingKey) {
    record[key.stringValue] = .null
  }
  
  func encode<T: Encodable>(_ value: T, for key: CodingKey) throws {
    switch value {
    case let value as SQLValueConvertible:
      record[key.stringValue] = value.sqlValue
    default:
      let info = "value of type \(T.self) must conform to \(SQLValueConvertible.self)"
      throw EncodingError.invalidValue(value, .init(codingPath: [key], debugDescription: info))
    }
  }
  
  func encodeIfPresent<T: Encodable>(_ value: T?, for key: CodingKey) throws {
    if let value = value {
      try encode(value, for: key)
    } else {
      encodeNil(for: key)
    }
  }
  
  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return .init(RecordEncodingContainer(encoder: self))
  }
  
  func unkeyedContainer() -> UnkeyedEncodingContainer {
    fatalError("unkeyedContainer has not been implemented")
  }
  
  func singleValueContainer() -> SingleValueEncodingContainer {
    fatalError("singleValueContainer has not been implemented")
  }
}
