import Foundation
import SQLiteSwift

extension RowDecoder {
    /// A keyed decoding container view into the data stored in a SQLite row.
    ///
    /// `KeyedContainer` provides functionality for decoding values of different types from a SQLite row,
    /// using keys conforming to the `CodingKey` protocol. This class is used internally by `RowDecoder`
    /// when decoding key-value pairs from a SQLite row.
    ///
    /// Nested containers are not supported by this container.
    final class KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        // MARK: - Properties
        
        /// The decoder associated with this container.
        let decoder: Decoder
        
        /// The path of coding keys taken to get to this point in decoding.
        let codingPath: [CodingKey]
        
        /// All the keys the `Decoder` has for this container.
        ///
        /// Different keyed containers from the same `Decoder` may return different
        /// keys here; it is possible to encode with multiple key types which are
        /// not convertible to one another. This should report all keys present
        /// which are convertible to the requested type.
        private(set) lazy var allKeys: [Key] = {
            (decoder.data as? SQLiteRow)?.columns.compactMap {
                Key(stringValue: $0)
            } ?? []
        }()
        
        // MARK: - Inits
        
        /// Initializes the keyed container with the provided decoder and coding path.
        ///
        /// - Parameters:
        ///   - decoder: The decoder associated with this container.
        ///   - codingPath: The coding path of this container.
        init(decoder: Decoder, codingPath: [CodingKey]) {
            self.decoder = decoder
            self.codingPath = codingPath
        }
        
        // MARK: - Decoding methods
        
        /// Returns a Boolean value indicating whether the decoder contains a value associated with the given key.
        ///
        /// The value associated with `key` may be a null value as appropriate for the data format.
        ///
        /// - Parameter key: The key to search for.
        /// - Returns: Whether the `Decoder` has an entry for the given key.
        func contains(_ key: Key) -> Bool {
            allKeys.contains { $0.stringValue == key.stringValue }
        }

        /// Decodes a null value for the given key.
        ///
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: Whether the encountered value was null.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not of the expected type.
        func decodeNil(forKey key: Key) throws -> Bool {
            guard contains(key) else {
                let info = "No value associated with key \(key)."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.keyNotFound(key, context)
            }
            
            switch decoder.data {
            case let data as SQLiteRow:
                return data[key.stringValue] == .null
            default:
                let dataType = Swift.type(of: decoder.data)
                let info = "Expected to decode \(SQLiteRow.self), but found \(dataType) instead."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.typeMismatch(SQLiteRow.self, context)
            }
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            try decoder.decode(type, for: key)
        }
        
        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try decoder.decode(type, for: key)
        }

        /// Decodes a value of the given type for the given key.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Parameter key: The key that the decoded value is associated with.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            switch type {
            case let type as SQLiteConvertible.Type:
                try decoder.decode(type, for: key) as! T
            default:
                try T(from: decoder.decoder(for: key))
            }
        }
        
        /// Returns the data stored for the given key as represented in a container keyed by the given key type.
        ///
        /// - Parameter type: The key type to use for the container.
        /// - Parameter key: The key that the nested container is associated with.
        /// - Returns: A keyed decoding container view into `self`.
        /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        func nestedContainer<NestedKey: CodingKey>(
            keyedBy type: NestedKey.Type,
            forKey key: Key
        ) throws -> KeyedDecodingContainer<NestedKey> {
            let info = "Nested containers are not supported in keyed containers."
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: info
            )
            throw Error.notImplemented(context)
        }

        /// Returns the data stored for the given key as represented in an unkeyed container.
        ///
        /// - Parameter key: The key that the nested container is associated with.
        /// - Returns: An unkeyed decoding container view into `self`.
        /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            let info = "Nested unkeyed containers are not supported in keyed containers."
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: info
            )
            throw Error.notImplemented(context)
        }

        /// Returns a `Decoder` instance for decoding `super` from the container associated with the default `super` key.
        ///
        /// Equivalent to calling `superDecoder(forKey:)` with `Key(stringValue: "super", intValue: 0)`.
        ///
        /// - Returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the default `super` key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the default `super` key.
        func superDecoder() throws -> Swift.Decoder {
            decoder
        }

        /// Returns a `Decoder` instance for decoding `super` from the container associated with the given key.
        ///
        /// - Parameter key: The key to decode `super` for.
        /// - Returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - Throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
        /// - Throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
        func superDecoder(forKey key: Key) throws -> Swift.Decoder {
            decoder
        }
    }
}
