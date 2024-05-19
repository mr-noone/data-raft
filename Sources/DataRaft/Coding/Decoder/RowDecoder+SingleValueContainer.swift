import Foundation
import SQLiteSwift

extension RowDecoder {
    /// A single value decoding container used for decoding values from SQLite rows.
    ///
    /// This container provides functionality for decoding single values of various types from SQLite rows.
    /// It is used internally by `RowDecoder` during the decoding process.
    final class SingleValueContainer: SingleValueDecodingContainer {
        // MARK: - Properties
        
        /// The decoder associated with this container.
        let decoder: Decoder
        
        /// The path of coding keys taken to get to this point in encoding.
        let codingPath: [CodingKey]
        
        // MARK: - Inits
        
        /// Initializes a single value container with a given decoder and coding path.
        ///
        /// - Parameters:
        ///   - decoder: The decoder to use for decoding values.
        ///   - codingPath: The coding path of the container.
        init(decoder: Decoder, codingPath: [CodingKey]) {
            self.decoder = decoder
            self.codingPath = codingPath
        }
        
        // MARK: - Decoding Methods
        
        /// Decodes a nil value.
        ///
        /// - Returns: `true` if the value is nil; otherwise, `false`.
        func decodeNil() -> Bool {
            switch decoder.data {
            case let data as SQLiteRow.Element:
                return data.value == .null
            default:
                return false
            }
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: Bool.Type) throws -> Bool {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: String.Type) throws -> String {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: Double.Type) throws -> Double {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: Float.Type) throws -> Float {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: Int.Type) throws -> Int {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: Int8.Type) throws -> Int8 {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: Int16.Type) throws -> Int16 {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: Int32.Type) throws -> Int32 {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: Int64.Type) throws -> Int64 {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: UInt.Type) throws -> UInt {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decoder.decode(type)
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            switch type {
            case let type as SQLiteConvertible.Type:
                try decoder.decode(type) as! T
            default:
                try T(from: decoder)
            }
        }
    }
}
