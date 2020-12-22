import Foundation
import SQLighter

final class RecordEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
  var codingPath: [CodingKey] { fatalError() }
  
  private let encoder: RecordEncoder
  
  init(encoder: RecordEncoder) {
    self.encoder = encoder
  }
  
  func encodeNil(forKey key: Key) throws {
    encoder.encodeNil(for: key)
  }
  
  func encode(_ value: Bool, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: String, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: Double, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: Float, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: Int, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: Int8, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: Int16, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: Int32, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: Int64, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: UInt, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: UInt8, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: UInt16, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: UInt32, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode(_ value: UInt64, forKey key: Key) throws {
    try encoder.encode(value, for: key)
  }
  
  func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
    try encoder.encode(value, for: key)
  }
  
  func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: String?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
    try encoder.encodeIfPresent(value, for: key)
  }
  
  func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
    fatalError("nestedContainer(keyedBy:forKey:) has not been implemented")
  }
  
  func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    fatalError("nestedUnkeyedContainer(forKey:) has not been implemented")
  }
  
  func superEncoder() -> Encoder {
    fatalError("superEncoder has not been implemented")
  }
  
  func superEncoder(forKey key: Key) -> Encoder {
    fatalError("superEncoder(forKey:) has not been implemented")
  }
}
