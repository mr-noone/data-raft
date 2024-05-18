import Foundation
import SQLiteSwift

extension RowEncoder {
    /// A container used for encoding unkeyed collections of SQLite rows.
    ///
    /// This container provides methods for encoding unkeyed collections of SQLite rows.
    /// It is used internally by `RowEncoder` during the encoding process.
    final class UnkeyedContainer: EncodingContainer<[SQLiteRow]>, UnkeyedEncodingContainer {
        // MARK: - Properties
        
        /// The number of elements encoded in the container.
        var count: Int {
            output.count
        }
        
        /// The current coding key for the container.
        var currentKey: CodingKey {
            RowCodingKey(intValue: count)
        }
        
        // MARK: - Inits
        
        /// Initializes the unkeyed container with the provided encoder and coding path.
        ///
        /// - Parameters:
        ///   - encoder: The encoder associated with this container.
        ///   - codingPath: The coding path to track during encoding.
        init(encoder: Encoder<[SQLiteRow]>, codingPath: [CodingKey]) {
            super.init(encoder: encoder, output: [], codingPath: codingPath)
        }
        
        // MARK: - Encoding methods
        
        /// Encodes a `nil` value into the container.
        ///
        /// This method does not perform any encoding.
        func encodeNil() throws {
        }
        
        /// Encodes a value into the container.
        ///
        /// - Parameter value: The value to encode.
        /// - Throws: An error if the value cannot be encoded.
        func encode<T>(_ value: T) throws where T : Encodable {
            switch value {
            case let value as Optional<any Encodable>:
                switch value {
                case .some(let value):
                    let encoder = encoder.encoder(
                        SQLiteRow.self,
                        for: currentKey
                    )
                    try value.encode(to: encoder)
                    try append(encoder.output ?? [])
                case .none:
                    break
                }
            }
        }
        
        /// Returns a nested keyed encoding container for encoding nested values.
        ///
        /// - Parameter keyType: The type of keys for the nested container.
        /// - Returns: A keyed encoding container nested within this container.
        func nestedContainer<NestedKey: CodingKey>(
            keyedBy keyType: NestedKey.Type
        ) -> KeyedEncodingContainer<NestedKey> {
            fatalError("Nested encoding containers are not supported.")
        }
        
        /// Returns a nested unkeyed encoding container for encoding nested values.
        ///
        /// - Returns: An unkeyed encoding container nested within this container.
        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            fatalError("Nested encoding containers are not supported.")
        }
        
        /// Returns a super encoder to encode a value indirectly.
        ///
        /// - Returns: A super encoder that encodes values through this container's encoder.
        func superEncoder() -> Swift.Encoder {
            encoder
        }
    }
}
