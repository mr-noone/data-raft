import Foundation
import SQLiteSwift

extension RowDecoder {
    /// A unkeyed decoding container used for decoding multiple values from SQLite rows.
    ///
    /// This container provides functionality for decoding multiple values of various types from SQLite rows.
    /// It is used internally by `RowDecoder` during the decoding process.
    final class UnkeyedContainer: UnkeyedDecodingContainer {
        // MARK: - Properties
        
        /// The decoder associated with this container.
        let decoder: Decoder
        
        /// The path of coding keys taken to get to this point in decoding.
        let codingPath: [CodingKey]
        
        /// The current decoding index of the container (i.e. the index of the next
        /// element to be decoded.) Incremented after every successful decode call.
        private(set) var currentIndex: Int = 0
        
        /// The coding key representing the current index.
        var currentKey: CodingKey {
            RowCodingKey(intValue: currentIndex)
        }
        
        /// The number of elements contained within this container.
        ///
        /// If the number of elements is unknown, the value is `nil`.
        var count: Int? {
            switch decoder.data {
            case let data as [SQLiteRow]:
                return data.count
            case let data as SQLiteRow:
                return data.count
            default:
                return nil
            }
        }
        
        /// A Boolean value indicating whether there are no more elements left to be decoded in the container.
        var isAtEnd: Bool {
            guard let count = self.count else {
                return true
            }
            return currentIndex >= count
        }
        
        // MARK: - Inits
        
        /// Initializes the unkeyed container with the provided decoder and coding path.
        ///
        /// - Parameters:
        ///   - decoder: The decoder associated with this container.
        ///   - codingPath: The coding path of this container.
        init(decoder: Decoder, codingPath: [CodingKey]) {
            self.decoder = decoder
            self.codingPath = codingPath
        }
        
        // MARK: - Decoding methods
        
        /// Decodes a null value.
        ///
        /// If the value is not null, does not increment currentIndex.
        ///
        /// - Returns: `true` if the value is null; otherwise, `false`.
        /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not of the expected type.
        func decodeNil() throws -> Bool {
            switch decoder.data {
            case let data as SQLiteRow:
                defer {
                    if data[currentIndex].value == .null {
                        currentIndex += 1
                    }
                }
                return data[currentIndex].value == .null
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
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or if there are no more values to decode.
        func decode(_ type: Bool.Type) throws -> Bool {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: String.Type) throws -> String {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: Double.Type) throws -> Double {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: Float.Type) throws -> Float {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: Int.Type) throws -> Int {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: Int8.Type) throws -> Int8 {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: Int16.Type) throws -> Int16 {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: Int32.Type) throws -> Int32 {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: Int64.Type) throws -> Int64 {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: UInt.Type) throws -> UInt {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            return try decoder.decode(type, for: currentKey)
        }
        
        /// Decodes a value of the given type.
        ///
        /// - Parameter type: The type of value to decode.
        /// - Returns: A value of the requested type, if present for the given key and convertible to the requested type.
        /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            try checkIsAtEnd(type)
            defer { currentIndex += 1 }
            switch type {
            case let type as SQLiteConvertible.Type:
                return try decoder.decode(type, for: currentKey) as! T
            default:
                return try T(from: decoder.decoder(for: currentKey))
            }
        }
        
        /// Decodes a nested container keyed by the given type.
        ///
        /// - Parameter type: The key type to use for the container.
        /// - Returns: A keyed decoding container view into `self`.
        /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
        func nestedContainer<NestedKey: CodingKey>(
            keyedBy type: NestedKey.Type
        ) throws -> KeyedDecodingContainer<NestedKey> {
            let info = "Nested containers are not supported in unkeyed containers."
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: info
            )
            throw Error.notImplemented(context)
        }

        /// Decodes an unkeyed nested container.
        ///
        /// - Returns: An unkeyed decoding container view into `self`.
        /// - Throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let info = "Nested unkeyed containers are not supported in unkeyed containers."
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: info
            )
            throw Error.notImplemented(context)
        }

        /// Decodes a nested container and Returns a `Decoder` instance for decoding `super` from that container.
        ///
        /// - Returns: A new `Decoder` to pass to `super.init(from:)`.
        /// - Throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or if there are no more values to decode.
        func superDecoder() throws -> Swift.Decoder {
            try checkIsAtEnd(Any.self)
            return decoder
        }
        
        // MARK: - Private methods
        
        /// Checks whether the container is at the end.
        ///
        /// - Parameter type: The type to use in the error message if the container is at the end.
        /// - Throws: `DecodingError.valueNotFound` if the container is at the end.
        @inline(__always)
        private func checkIsAtEnd<T>(_ type: T.Type) throws {
            guard !isAtEnd else {
                let info = "Unkeyed container is at end."
                let context = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: info
                )
                throw DecodingError.valueNotFound(type, context)
            }
        }
    }
}
