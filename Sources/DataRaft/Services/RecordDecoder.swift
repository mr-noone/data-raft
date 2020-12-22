import Foundation

final class RecordDecoder: Decoder {
  var codingPath: [CodingKey] { fatalError() }
  var userInfo: [CodingUserInfoKey : Any] { fatalError() }
  
  private let record: Record
  
  init(record: Record) {
    self.record = record
  }
  
  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    return .init(RecordDecodingContainer(record: record))
  }
  
  func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    fatalError("unkeyedContainer has not been implemented")
  }
  
  func singleValueContainer() throws -> SingleValueDecodingContainer {
    fatalError("singleValueContainer has not been implemented")
  }
}
