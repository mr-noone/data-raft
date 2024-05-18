import Foundation
import SQLiteSwift

extension RowEncoder {
    /// An encoder used for encoding values into SQLite rows.
    ///
    /// This encoder provides functionality for encoding values of various types into SQLite rows.
    /// It is used internally by `RowEncoder` during the encoding process.
    final class Encoder<Output>: Swift.Encoder {
        // MARK: - Properties
        
        /// The path of coding keys taken to reach this point in encoding.
        let codingPath: [CodingKey]
        
        /// A dictionary containing contextual information for the encoding process.
        let userInfo: [CodingUserInfoKey : Any]
        
        /// The output representing the encoded SQLite rows.
        var output: Output? {
            container?.output
        }
        
        /// The container used for encoding values.
        ///
        /// The container tracks the encoding process and holds the encoded output.
        private var container: EncodingContainer<Output>?
        
        // MARK: - Inits
        
        /// Initializes the encoder with the provided coding path and user information dictionary.
        ///
        /// - Parameters:
        ///   - codingPath: The path of coding keys taken to reach this point in encoding.
        ///   - userInfo: A dictionary containing contextual information for the encoding process.
        init(
            codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey: Any]
        ) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        // MARK: - Encoding methods
        
        /// Returns a new encoder instance for encoding a value of the given type keyed by the given key.
        ///
        /// - Parameters:
        ///   - type: The type of value to encode.
        ///   - key: The key representing the value.
        /// - Returns: A new encoder instance.
        func encoder<T>(_ type: T.Type, for key: CodingKey) -> Encoder<T> {
            Encoder<T>(codingPath: codingPath + [key], userInfo: userInfo)
        }
        
        // MARK: - Container methods
        
        /// Returns a new keyed encoding container instance for encoding values by keys.
        ///
        /// - Parameter type: The key type for the container.
        /// - Returns: A new keyed encoding container.
        func container<Key: CodingKey>(
            keyedBy type: Key.Type
        ) -> KeyedEncodingContainer<Key> {
            switch self {
            case let self as Encoder<SQLiteRow>:
                if let container = container as? KeyedContainer<Key> {
                    return KeyedEncodingContainer(container)
                }
                container = KeyedContainer<Key>(
                    encoder: self,
                    codingPath: codingPath
                ) as? EncodingContainer<Output>
                return container(keyedBy: type)
            default:
                preconditionFailure("""
                \n====
                Expected output of type \(SQLiteRow.self), but found \(Output.self) instead.
                Ensure that the correct container type is being used for the encoding process.
                ====
                """)

            }
        }
        
        /// Returns a new unkeyed encoding container instance for encoding a sequence of values.
        ///
        /// - Returns: A new unkeyed encoding container.
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            switch self {
            case let self as Encoder<[SQLiteRow]>:
                if let container = container as? UnkeyedContainer {
                    return container
                }
                container = UnkeyedContainer(
                    encoder: self,
                    codingPath: codingPath
                ) as? EncodingContainer<Output>
                return unkeyedContainer()
            default:
                preconditionFailure("""
                \n====
                Expected output of type \([SQLiteRow].self), but found \(Output.self) instead.
                Ensure that the correct container type is being used for the encoding process.
                ====
                """)
            }
        }
        
        /// Returns a new single value encoding container instance for encoding a single non-keyed value.
        ///
        /// - Returns: A new single value encoding container.
        func singleValueContainer() -> SingleValueEncodingContainer {
            switch self {
            case let self as Encoder<SQLiteValue>:
                if let container = container as? SingleValueContainer {
                    return container
                }
                container = SingleValueContainer(
                    encoder: self,
                    codingPath: codingPath
                ) as? EncodingContainer<Output>
                return singleValueContainer()
            default:
                preconditionFailure("""
                \n====
                Expected output of type \(SQLiteValue.self), but found \(Output.self) instead.
                Ensure that the correct container type is being used for the encoding process.
                ====
                """)
            }
        }
    }
}
