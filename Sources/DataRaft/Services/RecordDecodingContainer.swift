import Foundation
import SQLighter

final class RecordDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
  var codingPath: [CodingKey] { fatalError() }
  var allKeys: [Key] { fatalError() }
  
  private let record: Record
  
  init(record: Record) {
    self.record = record
  }
  
  func contains(_ key: Key) -> Bool {
    return record.contains { $0.column.sqlString == key.stringValue }
  }
  
  func decodeNil(forKey key: Key) throws -> Bool {
    return record[key.stringValue] == .null
  }
  
  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
    return try decode(type, for: key)
  }
  
  func decode(_ type: String.Type, forKey key: Key) throws -> String {
    return try decode(type, for: key)
  }
  
  func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
    return try decode(type, for: key)
  }
  
  func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
    return try decode(type, for: key)
  }
  
  func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
    return try decode(type, for: key)
  }
  
  func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
    return try decode(type, for: key)
  }
  
  func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
    return try decode(type, for: key)
  }
  
  func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
    return try decode(type, for: key)
  }
  
  func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
    return try decode(type, for: key)
  }
  
  func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
    return try decode(type, for: key)
  }
  
  func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
    return try decode(type, for: key)
  }
  
  func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
    return try decode(type, for: key)
  }
  
  func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
    return try decode(type, for: key)
  }
  
  func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
    return try decode(type, for: key)
  }
  
  func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
    return try decode(type, for: key)
  }
  
  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    fatalError("nestedContainer(keyedBy:forKey:) has not been implemented")
  }
  
  func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    fatalError("nestedUnkeyedContainer(forKey:) has not been implemented")
  }
  
  func superDecoder() throws -> Decoder {
    fatalError("superEncoder has not been implemented")
  }
  
  func superDecoder(forKey key: Key) throws -> Decoder {
    fatalError("superEncoder(forKey:) has not been implemented")
  }
}

private extension RecordDecodingContainer {
  func decode<T: Decodable>(_ type: T.Type, for key: CodingKey) throws -> T {
    switch type {
    case let type as SQLValueConvertible.Type:
      if let value = record[key.stringValue] {
        if let value = type.init(value) {
          return value as! T
        } else {
          let info = "failed to decode \(value) to \(T.self)"
          throw DecodingError.typeMismatch(T.self, .init(codingPath: [key], debugDescription: info))
        }
      } else {
        let info = "value of type \(T.self) by key \(key.stringValue) not found"
        throw DecodingError.valueNotFound(T.self, .init(codingPath: [key], debugDescription: info))
      }
    default:
      let info = "type \(T.self) must conform to \(SQLValueConvertible.self)"
      throw DecodingError.typeMismatch(type.self, .init(codingPath: [key], debugDescription: info))
    }
  }
}
