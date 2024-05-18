import Foundation
import SQLiteSwift

extension RowEncoder {
    /// A keyed container used during the encoding process to encode values associated with specific keys into SQLite rows.
    final class KeyedContainer<Key: CodingKey>: EncodingContainer<SQLiteRow>, KeyedEncodingContainerProtocol {
        // MARK: - Inits
        
        /// Initializes a keyed container with the provided encoder, output, and coding path.
        ///
        /// - Parameters:
        ///   - encoder: The encoder associated with this keyed container.
        ///   - codingPath: The path of coding keys taken to get to this point in encoding.
        init(encoder: Encoder<SQLiteRow>, codingPath: [CodingKey]) {
            super.init(encoder: encoder, output: [], codingPath: codingPath)
        }
        
        // MARK: - Methods
        
        /// Encodes a `nil` value for the given key.
        ///
        /// - Parameter key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeNil(forKey key: Key) throws {
            try encodeNil(for: key)
        }
        
        /// Encodes a Boolean value for the given key.
        ///
        /// - Parameters:
        ///   - value: The Boolean value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Bool, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a string value for the given key.
        ///
        /// - Parameters:
        ///   - value: The string value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: String, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a Double value for the given key.
        ///
        /// - Parameters:
        ///   - value: The Double value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Double, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a Float value for the given key.
        ///
        /// - Parameters:
        ///   - value: The Float value to encode.
        ///   - key: The key to encoded for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Float, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes an Int value for the given key.
        ///
        /// - Parameters:
        ///   - value: The Int value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes an Int8 value for the given key.
        ///
        /// - Parameters:
        ///   - value: The Int8 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int8, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes an Int16 value for the given key.
        ///
        /// - Parameters:
        ///   - value: The Int16 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int16, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes an Int32 value for the given key.
        ///
        /// - Parameters:
        ///   - value: The Int32 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int32, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes an Int64 value for the given key.
        ///
        /// - Parameters:
        ///   - value: The Int64 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int64, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a UInt value for the given key.
        ///
        /// - Parameters:
        ///   - value: The UInt value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a UInt8 value for the given key.
        ///
        /// - Parameters:
        ///   - value: The UInt8 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt8, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a UInt16 value for the given key.
        ///
        /// - Parameters:
        ///   - value: The UInt16 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt16, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a UInt32 value for the given key.
        ///
        /// - Parameters:
        ///   - value: The UInt32 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt32, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a UInt64 value for the given key.
        ///
        /// - Parameters:
        ///   - value: The UInt64 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt64, forKey key: Key) throws {
            try encode(value, for: key)
        }
        
        /// Encodes a value for the given key, which conforms to the `Encodable` protocol.
        ///
        /// - Parameters:
        ///   - value: The value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            switch value {
            case let value as SQLiteConvertible:
                try encode(value, for: key)
            default:
                let encoder = encoder.encoder(SQLiteValue.self, for: key)
                try value.encode(to: encoder)
                try set(encoder.output ?? .null, for: key)
            }
        }
        
        /// Encodes a Boolean value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional Boolean value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes a string value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional string value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: String?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes a Double value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional Double value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes a Float value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional Float value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes an Int value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional Int value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes an Int8 value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional Int8 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes an Int16 value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional Int16 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes an Int32 value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional Int32 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes an Int64 value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional Int64 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes a UInt value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional UInt value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes a UInt8 value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional UInt8 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes a UInt16 value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional UInt16 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes a UInt32 value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional UInt32 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes a UInt64 value if it is present for the given key.
        ///
        /// - Parameters:
        ///   - value: The optional UInt64 value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
            try encodeIfPresent(value, for: key)
        }
        
        /// Encodes an optional value for the given key if it is present.
        ///
        /// - Parameters:
        ///   - value: The optional value to encode.
        ///   - key: The key to encode for.
        /// - Throws: An error if the value cannot be encoded.
        func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
            switch value {
            case .some(let value):
                try encode(value, forKey: key)
            case .none:
                try encodeNil(forKey: key)
            }
        }
        
        /// Returns a new keyed encoding container nested within the current container for the given key.
        ///
        /// - Parameters:
        ///   - keyType: The key type for the nested container.
        ///   - key: The key that represents the nested container.
        /// - Returns: A new keyed encoding container nested within the current container.
        func nestedContainer<NestedKey: CodingKey>(
            keyedBy keyType: NestedKey.Type,
            forKey key: Key
        ) -> KeyedEncodingContainer<NestedKey> {
            fatalError("Nested encoding containers are not supported.")
        }
        
        /// Returns a new unkeyed encoding container nested within the current container for the given key.
        ///
        /// - Parameter key: The key that represents the nested container.
        /// - Returns: A new unkeyed encoding container nested within the current container.
        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            fatalError("Nested encoding containers are not supported.")
        }
        
        /// Returns a new encoder to encode a value at the current coding path.
        ///
        /// - Returns: A new encoder.
        func superEncoder() -> Swift.Encoder {
            encoder
        }
        
        /// Returns a new encoder to encode a value at the given coding path.
        ///
        /// - Parameter key: The key representing the value to encode.
        /// - Returns: A new encoder.
        func superEncoder(forKey key: Key) -> Swift.Encoder {
            encoder
        }
    }
}
