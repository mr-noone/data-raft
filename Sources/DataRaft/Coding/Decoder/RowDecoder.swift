import Foundation
import SQLiteSwift

/// An object that decodes instances of a data type from SQLite rows.
///
/// `RowDecoder` provides functionality for decoding SQLite rows into Swift values conforming to the `Decodable`
/// protocol. This class is particularly useful when working with SQLite databases and needing to retrieve Swift
/// objects from data stored in the database.
///
/// To use `RowDecoder`, create an instance of the class and then call its `decode` method, passing
/// the type of the value you want to decode and the SQLite row(s) containing the encoded data.
///
/// Example usage:
/// ```swift
/// let decoder = RowDecoder(userInfo: [:])
/// do {
///     let myObject = try decoder.decode(MyObjectType.self, from: mySQLiteRow)
///     // Use the decoded Swift object as needed
/// } catch {
///     print("Error decoding: \(error)")
/// }
/// ```
///
/// - Note: This class is intended to be used with types conforming to the `Decodable` protocol.
public final class RowDecoder {
    /// An error type specific to RowDecoder.
    public enum Error: Swift.Error {
        /// Error indicating that a certain feature is not implemented.
        case notImplemented(DecodingError.Context)
    }
    
    // MARK: - Properties
    
    /// A dictionary containing user-defined information for the decoding process.
    public var userInfo: [CodingUserInfoKey : Any]
    
    // MARK: - Inits
    
    /// Initializes a new instance of `RowDecoder`.
    ///
    /// - Parameter userInfo: A dictionary containing user-defined information to pass to the decoding process.
    public init(userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    /// Decodes a single SQLite row into a value of the specified type.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - row: The SQLite row containing the encoded data.
    /// - Returns: A value of the specified type.
    /// - Throws: An error if the decoding process fails.
    public func decode<T: Decodable>(_ type: T.Type, from row: SQLiteRow) throws -> T {
        let decoder = Decoder(codingPath: [], userInfo: userInfo, data: row)
        return try T(from: decoder)
    }
    
    /// Decodes an array of SQLite rows into a value of the specified type.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - rows: An array of SQLite rows containing the encoded data.
    /// - Returns: A value of the specified type.
    /// - Throws: An error if the decoding process fails.
    public func decode<T: Decodable>(_ type: T.Type, from rows: [SQLiteRow]) throws -> T {
        let decoder = Decoder(codingPath: [], userInfo: userInfo, data: rows)
        return try T(from: decoder)
    }
}

#if canImport(Combine)
import Combine

// MARK: - TopLevelDecoder

extension RowDecoder: TopLevelDecoder {
    /// The input type supported by the decoder, which is an array of SQLiteRow instances.
    public typealias Input = [SQLiteRow]
}
#endif
