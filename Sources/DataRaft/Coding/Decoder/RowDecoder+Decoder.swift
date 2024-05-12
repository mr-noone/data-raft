import Foundation
import SQLiteSwift

extension RowDecoder {
    /// A decoder that decodes values from SQLite rows.
    final class Decoder: Swift.Decoder {
        // MARK: - Properties
        
        /// The path of coding keys taken to get to this point in decoding.
        let codingPath: [CodingKey]
        
        /// A dictionary you use to customize the decoding process by providing contextual information.
        let userInfo: [CodingUserInfoKey : Any]
        
        /// The data being decoded.
        let data: Any
        
        // MARK: - Inits
        
        /// Initializes a new decoder with the given coding path, user information, and data to decode.
        ///
        /// - Parameters:
        ///   - codingPath: The path of coding keys taken to get to this point in decoding.
        ///   - userInfo: A dictionary you use to customize the decoding process by providing contextual information.
        ///   - data: The data being decoded.
        init(
            codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey : Any],
            data: Any
        ) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
        }
        
        // MARK: - Decoding methods
        
        /// Returns a new decoder instance for decoding nested values keyed by the given coding key.
        ///
        /// This method is used to create a new decoder instance for decoding nested values associated with the given coding key.
        ///
        /// - Parameter key: The coding key representing the nested value to be decoded.
        /// - Returns: A new decoder instance for decoding the nested value.
        /// - Throws: `DecodingError.keyNotFound` if no data is associated with the given key.
        func decoder(for key: CodingKey) throws -> Decoder {
            switch (data, key.intValue) {
            case let (data as [SQLiteRow], index?):
                return Decoder(
                    codingPath: codingPath + [key],
                    userInfo: userInfo,
                    data: data[index]
                )
            case let (data as SQLiteRow, index?):
                return Decoder(
                    codingPath: codingPath + [key],
                    userInfo: userInfo,
                    data: data[index]
                )
            case let (data as SQLiteRow, _):
                guard let index = data.index(for: key.stringValue) else {
                    let info = "No value associated with key \(key)."
                    let context = DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: info
                    )
                    throw DecodingError.keyNotFound(key, context)
                }
                return Decoder(
                    codingPath: codingPath + [key],
                    userInfo: userInfo,
                    data: data[index]
                )
            default:
                fatalError()
            }
        }
        
        /// Decodes a single value of the given type from the SQLite row element.
        ///
        /// This method performs the actual decoding operation by extracting the value
        /// from the SQLite row element and attempting to convert it to the requested type.
        ///
        /// - Parameter type: The type to decode as.
        /// - Returns: A value of the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode<T: SQLiteConvertible>(_ type: T.Type) throws -> T {
            guard let data = data as? SQLiteRow.Element else {
                let dataType = Swift.type(of: data)
                let info = "Expected data of type \(SQLiteRow.Element.self), but found \(dataType) instead."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.typeMismatch(type, context)
            }
            
            guard data.value != .null else {
                let info = "Encountered a null value when decoding \(T.self)."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.valueNotFound(type, context)
            }
            
            guard let result = T(data.value) else {
                let info = "Failed to decode \(T.self) from \(data)."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.typeMismatch(type, context)
            }
            
            return result
        }

        /// Decodes a single value of the given type from the SQLite row for the specified key.
        ///
        /// This method performs the actual decoding operation by extracting the value from
        /// the SQLite row element associated with the given key and attempting to convert it to the requested type.
        ///
        /// - Parameters:
        ///   - type: The type to decode as.
        ///   - key: The key that represents the value in the SQLite row.
        /// - Returns: A value of the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        /// - Throws: `DecodingError.keyNotFound` if no value is associated with the given key.
        func decode<T: SQLiteConvertible>(_ type: T.Type, for key: CodingKey) throws -> T {
            guard let data = data as? SQLiteRow else {
                let dataType = Swift.type(of: data)
                let info = "Expected data of type \(SQLiteRow.self), but found \(dataType) instead."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.typeMismatch(type, context)
            }
            
            let value: SQLiteRow.Value
            if let index = key.intValue {
                value = data[index].value
            } else if let v = data[key.stringValue] {
                value = v
            } else {
                let info = "No value associated with key \(key)."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.keyNotFound(key, context)
            }
            
            guard value != .null else {
                let info = "Encountered a null value when decoding \(T.self)."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.valueNotFound(type, context)
            }
            
            guard let result = T(value) else {
                let info = "Failed to decode \(T.self) from \(value)."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.typeMismatch(type, context)
            }
            
            return result
        }
        
        // MARK: - Container methods
        
        /// Returns a keyed decoding container view into this decoder for decoding nested values keyed by the given key type.
        ///
        /// This method is used to obtain a keyed decoding container view into this decoder for decoding nested values associated with keys of the specified type.
        ///
        /// - Parameter type: The key type to use for the container.
        /// - Returns: A keyed decoding container view into this decoder.
        /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        func container<Key: CodingKey>(
            keyedBy type: Key.Type
        ) throws -> KeyedDecodingContainer<Key> {
            if data is SQLiteRow {
                let container = KeyedContainer<Key>(
                    decoder: self,
                    codingPath: codingPath
                )
                return KeyedDecodingContainer(container)
            } else {
                let dataType = Swift.type(of: data)
                let info = "Expected to decode \(SQLiteRow.self), but found \(dataType) instead."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.typeMismatch(SQLiteRow.self, context)
            }
        }
        
        /// Returns the data stored in this decoder as represented in a container appropriate for holding values with no keys.
        ///
        /// This method is used to obtain an unkeyed container view into this decoder for decoding nested values that are not associated with keys.
        ///
        /// - Returns: An unkeyed container view into this decoder.
        /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            if data is SQLiteRow || data is [SQLiteRow] {
                return UnkeyedContainer(decoder: self, codingPath: codingPath)
            } else {
                let dataType = Swift.type(of: data)
                let info = "Expected to decode \([SQLiteRow].self), but found \(dataType) instead."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.typeMismatch([SQLiteRow].self, context)
            }
        }
        
        /// Returns the data stored in this decoder as represented in a container appropriate for holding a single primitive value.
        ///
        /// This method is used to obtain a single value container view into this decoder for decoding a single primitive value.
        ///
        /// - Returns: A single value container view into this decoder.
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            SingleValueContainer(decoder: self, codingPath: codingPath)
        }
    }
}
