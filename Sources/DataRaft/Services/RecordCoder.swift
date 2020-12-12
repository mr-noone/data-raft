import Foundation

public final class RecordCoder {
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
