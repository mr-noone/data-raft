import Foundation

public class RecordCoder {
  public init() {}
  
  public func decode<T: Decodable>(_ type: T.Type, from record: Record) throws -> T {
    let decoder = RecordDecoder(record: record)
    return try T(from: decoder)
  }
  
  public func encode<T: Encodable>(_ value: T) throws -> Record {
    let encoder = RecordEncoder()
    try value.encode(to: encoder)
    return encoder.record
  }
}

private class RecordDecoder: Decoder {
  var codingPath: [CodingKey] {
    fatalError(" has not been implemented")
  }
  
  var userInfo: [CodingUserInfoKey : Any] {
    fatalError("codingPath has not been implemented")
  }
  
  private let record: Record
  
  init(record: Record) {
    self.record = record
  }
  
  func decode<T: DatabaseValueConvertible>(for key: CodingKey) throws -> T {
    if let value = record[key.stringValue] {
      if let value = T(value) {
        return value
      } else {
        let info = "failed to decode \(value) to \(T.self)"
        throw DecodingError.typeMismatch(T.self, .init(codingPath: [key], debugDescription: info))
      }
    } else {
      let info = "value of type \(T.self) by key \(key.stringValue) not found"
      throw DecodingError.valueNotFound(T.self, .init(codingPath: [key], debugDescription: info))
    }
  }
  
  func decode<T: Decodable>(_ type: T.Type, for key: CodingKey) throws -> T {
    switch type {
    case let type as DatabaseValueConvertible.Type:
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
      let info = "type \(T.self) must conform to \(DatabaseValueConvertible.self)"
      throw DecodingError.typeMismatch(type.self, .init(codingPath: [key], debugDescription: info))
    }
  }
  
  func decodeIfPresent<T: DatabaseValueConvertible>(for key: CodingKey) throws -> T? {
    if let value = record[key.stringValue] {
      if case DatabaseValue.null = value {
        return nil
      } else if let value = T(value) {
        return value
      } else {
        let info = "failed to decode \(value) to \(T.self)"
        throw DecodingError.typeMismatch(T.self, .init(codingPath: [key], debugDescription: info))
      }
    } else {
      let info = "key \(key.stringValue) not found"
      throw DecodingError.keyNotFound(key, .init(codingPath: [], debugDescription: info))
    }
  }
  
  func decodeIfPresent<T: Decodable>(_ type: T.Type, for key: CodingKey) throws -> T? {
    switch type {
    case let type as DatabaseValueConvertible.Type:
      if let value = record[key.stringValue] {
        if case DatabaseValue.null = value {
          return nil
        } else if let value = type.init(value) {
          return value as? T
        } else {
          let info = "failed to decode \(value) to \(T.self)"
          throw DecodingError.typeMismatch(T.self, .init(codingPath: [key], debugDescription: info))
        }
      } else {
        let info = "key \(key.stringValue) not found"
        throw DecodingError.keyNotFound(key, .init(codingPath: [], debugDescription: info))
      }
    default:
      let info = "type \(T.self) must conform to \(DatabaseValueConvertible.self)"
      throw DecodingError.typeMismatch(type.self, .init(codingPath: [key], debugDescription: info))
    }
  }
  
  func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
    return .init(RecordKeyedDecodingContainer<Key>(decoder: self))
  }
  
  func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    fatalError("unkeyedContainer has not been implemented")
  }
  
  func singleValueContainer() throws -> SingleValueDecodingContainer {
    fatalError("singleValueContainer has not been implemented")
  }
}

private class RecordEncoder: Encoder {
  var codingPath: [CodingKey] {
    fatalError("codingPath has not been implemented")
  }
  
  var userInfo: [CodingUserInfoKey : Any] {
    fatalError("userInfo has not been implemented")
  }
  
  private(set) var record = Record()
  
  func encodeNil(for key: CodingKey) {
    record[key.stringValue] = .null
  }
  
  func encode(_ value: DatabaseValueConvertible, for key: CodingKey) {
    record[key.stringValue] = value.databaseValue
  }
  
  func encode<T: Encodable>(_ value: T, for key: CodingKey) throws {
    switch value {
    case let value as DatabaseValueConvertible:
      record[key.stringValue] = value.databaseValue
    default:
      let info = "value of type \(T.self) must conform to \(DatabaseValueConvertible.self)"
      throw EncodingError.invalidValue(value, .init(codingPath: [key], debugDescription: info))
    }
  }
  
  func encodeIfPresent(_ value: DatabaseValueConvertible?, for key: CodingKey) {
    record[key.stringValue] = value?.databaseValue ?? .null
  }
  
  func encodeIfPresent<T: Encodable>(_ value: T?, for key: CodingKey) throws {
    if let value = value {
      try encode(value, for: key)
    } else {
      record[key.stringValue] = .null
    }
  }
  
  func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
    return .init(RecordKeyedEncodingContainer<Key>(encoder: self))
  }
  
  func unkeyedContainer() -> UnkeyedEncodingContainer {
    fatalError("unkeyedContainer has not been implemented")
  }
  
  func singleValueContainer() -> SingleValueEncodingContainer {
    fatalError("singleValueContainer has not been implemented")
  }
}

private class RecordKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
  var codingPath: [CodingKey] {
    fatalError("codingPath has not been implemented")
  }
  
  var allKeys: [Key] {
    fatalError("allKeys has not been implemented")
  }
  
  private let decoder: RecordDecoder
  
  init(decoder: RecordDecoder) {
    self.decoder = decoder
  }
  
  func contains(_ key: Key) -> Bool {
    fatalError("contains(_:) has not been implemented")
  }
  
  func decodeNil(forKey key: Key) throws -> Bool {
    fatalError("decodeNil(forKey:) has not been implemented")
  }
  
  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { try decoder.decode(for: key) }
  func decode(_ type: String.Type, forKey key: Key) throws -> String { try decoder.decode(for: key) }
  func decode(_ type: Double.Type, forKey key: Key) throws -> Double { try decoder.decode(for: key) }
  func decode(_ type: Float.Type, forKey key: Key) throws -> Float { try decoder.decode(for: key) }
  func decode(_ type: Int.Type, forKey key: Key) throws -> Int { try decoder.decode(for: key) }
  func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { try decoder.decode(for: key) }
  func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { try decoder.decode(for: key) }
  func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { try decoder.decode(for: key) }
  func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { try decoder.decode(for: key) }
  func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { try decoder.decode(for: key) }
  func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { try decoder.decode(for: key) }
  func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { try decoder.decode(for: key) }
  func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { try decoder.decode(for: key) }
  func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { try decoder.decode(for: key) }
  
  func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? { try decoder.decodeIfPresent(for: key) }
  func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? { try decoder.decodeIfPresent(for: key) }
  
  func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
    try decoder.decode(type, for: key)
  }
  
  func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
    try decoder.decodeIfPresent(type, for: key)
  }
  
  func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
    fatalError("nestedContainer(keyedBy:forKey:) has not been implemented")
  }
  
  func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    fatalError("nestedUnkeyedContainer(forKey:) has not been implemented")
  }
  
  func superDecoder() throws -> Swift.Decoder {
    fatalError("superEncoder has not been implemented")
  }
  
  func superDecoder(forKey key: Key) throws -> Swift.Decoder {
    fatalError("superEncoder(forKey:) has not been implemented")
  }
}

private class RecordKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
  var codingPath: [CodingKey] {
    fatalError("codingPath has not been implemented")
  }
  
  let encoder: RecordEncoder
  
  init(encoder: RecordEncoder) {
    self.encoder = encoder
  }
  
  func encodeNil(forKey key: Key) throws { encoder.encodeNil(for: key) }
  func encode(_ value: Bool, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: String, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: Double, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: Float, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: Int, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: Int8, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: Int16, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: Int32, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: Int64, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: UInt, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: UInt8, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: UInt16, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: UInt32, forKey key: Key) throws { encoder.encode(value, for: key) }
  func encode(_ value: UInt64, forKey key: Key) throws { encoder.encode(value, for: key) }
  
  func encodeIfPresent(_ value: Bool?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: String?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: Double?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: Float?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: Int?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: Int8?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: Int16?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: Int32?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: Int64?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: UInt?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws { encoder.encodeIfPresent(value, for: key) }
  
  func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encodeIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
    fatalError("nestedContainer(keyedBy:forKey:) has not been implemented")
  }
  
  func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    fatalError("nestedUnkeyedContainer(forKey:) has not been implemented")
  }
  
  func superEncoder() -> Swift.Encoder {
    fatalError("superEncoder has not been implemented")
  }
  
  func superEncoder(forKey key: Key) -> Swift.Encoder {
    fatalError("superEncoder(forKey:) has not been implemented")
  }
}
