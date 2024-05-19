import Foundation
import SQLiteSwift

extension RowEncoder {
    /// A container used for encoding single values to SQLite.
    ///
    /// This container provides methods for encoding single values of various types to SQLite format.
    /// It is used internally by `RowEncoder` during the encoding process.
    final class SingleValueContainer: EncodingContainer<SQLiteValue>, SingleValueEncodingContainer {
        // MARK: - Inits
        
        /// Initializes the single value container with the provided encoder and coding path.
        ///
        /// - Parameters:
        ///   - encoder: The encoder associated with this container.
        ///   - codingPath: The coding path to track during encoding.
        init(encoder: Encoder<SQLiteValue>, codingPath: [CodingKey]) {
            super.init(encoder: encoder, output: .null, codingPath: codingPath)
        }
        
        // MARK: - Encoding methods
        
        /// Encodes a Boolean value to SQLite format.
        ///
        /// - Parameter value: The Boolean value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Bool) throws {
            try encode(value: value)
        }
        
        /// Encodes a string value to SQLite format.
        ///
        /// - Parameter value: The string value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: String) throws {
            try encode(value: value)
        }
        
        /// Encodes a Double value to SQLite format.
        ///
        /// - Parameter value: The Double value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Double) throws {
            try encode(value: value)
        }
        
        /// Encodes a Float value to SQLite format.
        ///
        /// - Parameter value: The Float value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Float) throws {
            try encode(value: value)
        }
        
        /// Encodes an integer value to SQLite format.
        ///
        /// - Parameter value: The integer value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int) throws {
            try encode(value: value)
        }
        
        /// Encodes an Int8 value to SQLite format.
        ///
        /// - Parameter value: The Int8 value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int8) throws {
            try encode(value: value)
        }
        
        /// Encodes an Int16 value to SQLite format.
        ///
        /// - Parameter value: The Int16 value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int16) throws {
            try encode(value: value)
        }
        
        /// Encodes an Int32 value to SQLite format.
        ///
        /// - Parameter value: The Int32 value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int32) throws {
            try encode(value: value)
        }
        
        /// Encodes an Int64 value to SQLite format.
        ///
        /// - Parameter value: The Int64 value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: Int64) throws {
            try encode(value: value)
        }
        
        /// Encodes an unsigned integer value to SQLite format.
        ///
        /// - Parameter value: The unsigned integer value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt) throws {
            try encode(value: value)
        }
        
        /// Encodes a UInt8 value to SQLite format.
        ///
        /// - Parameter value: The UInt8 value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt8) throws {
            try encode(value: value)
        }
        
        /// Encodes a UInt16 value to SQLite format.
        ///
        /// - Parameter value: The UInt16 value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt16) throws {
            try encode(value: value)
        }
        
        /// Encodes a UInt32 value to SQLite format.
        ///
        /// - Parameter value: The UInt32 value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt32) throws {
            try encode(value: value)
        }
        
        /// Encodes a UInt64 value to SQLite format.
        ///
        /// - Parameter value: The UInt64 value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode(_ value: UInt64) throws {
            try encode(value: value)
        }
        
        /// Encodes a value conforming to `Encodable` to SQLite format.
        ///
        /// - Parameter value: The value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode<T>(_ value: T) throws where T: Encodable {
            switch value {
            case let value as SQLiteConvertible:
                try encode(value: value)
            default:
                try value.encode(to: encoder)
            }
        }
    }
}
