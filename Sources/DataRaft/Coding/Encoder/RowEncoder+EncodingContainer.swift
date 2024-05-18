import Foundation
import SQLiteSwift

extension RowEncoder {
    /// A base container used during the encoding process to hold the encoded values.
    ///
    /// This container provides methods for encoding values of different types into SQLite rows.
    /// It serves as the base class for more specialized encoding containers used by `RowEncoder` during the encoding process.
    class EncodingContainer<Output> {
        // MARK: - Properties
        
        /// The encoder associated with this container.
        private(set) weak var encoder: Encoder<Output>!
        
        /// The output representing the encoded SQLite data.
        private(set) var output: Output
        
        /// The coding path of this container.
        let codingPath: [CodingKey]
        
        // MARK: - Inits
        
        /// Initializes the encoding container with the provided encoder, output, and coding path.
        ///
        /// - Parameters:
        ///   - encoder: The encoder associated with this container.
        ///   - output: The output representing the encoded SQLite data.
        ///   - codingPath: The coding path of this container.
        init(encoder: Encoder<Output>, output: Output, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.output = output
            self.codingPath = codingPath
        }
    }
}

// MARK: - Output is [SQLiteRow]

extension RowEncoder.EncodingContainer where Output == [SQLiteRow] {
    /// Appends a SQLite row to the encoded output.
    ///
    /// - Parameter value: The SQLite row to append.
    func append(_ value: Output.Element) throws {
        output.append(value)
    }
}

// MARK: - Output is SQLiteRow

extension RowEncoder.EncodingContainer where Output == SQLiteRow {
    /// Encodes a `nil` value for the given key.
    ///
    /// - Parameter key: The coding key for which to encode the `nil` value.
    func encodeNil(for key: CodingKey) throws {
        output[key.stringValue] = .null
    }
    
    /// Encodes a value for the given key.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    ///   - key: The coding key for which to encode the value.
    func encode<T: SQLiteConvertible>(_ value: T, for key: CodingKey) throws {
        output[key.stringValue] = value.sqliteValue
    }
    
    /// Encodes an optional value for the given key.
    ///
    /// - Parameters:
    ///   - value: The optional value to encode.
    ///   - key: The coding key for which to encode the optional value.
    func encodeIfPresent<T: SQLiteConvertible>(_ value: T?, for key: CodingKey) throws {
        if let value = value {
            try encode(value, for: key)
        } else {
            try encodeNil(for: key)
        }
    }
    
    /// Sets a SQLite value for the given key.
    ///
    /// - Parameters:
    ///   - value: The SQLite value to set.
    ///   - key: The coding key for which to set the SQLite value.
    func set(_ value: SQLiteValue, for key: CodingKey) throws {
        output[key.stringValue] = value
    }
}

// MARK: - Output is SQLiteOutput

extension RowEncoder.EncodingContainer where Output == SQLiteValue {
    /// Encodes a `nil` value.
    ///
    /// This method sets the output to a null SQLite value.
    func encodeNil() throws {
        output = .null
    }
    
    /// Encodes a value.
    ///
    /// - Parameter value: The value to encode.
    /// This method sets the output to the SQLite value of the provided value.
    func encode<T: SQLiteConvertible>(value: T) throws {
        output = value.sqliteValue
    }
}
