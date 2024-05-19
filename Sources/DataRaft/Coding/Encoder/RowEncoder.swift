import Foundation
import SQLiteSwift

/// An object that encodes instances of a data type as SQLite rows.
///
/// `RowEncoder` provides functionality for encoding Swift values conforming to the `Encodable`
/// protocol into SQLite rows. This class is particularly useful when working with SQLite databases and needing
/// to encode Swift objects into a format that can be stored in the database.
///
/// To use `RowEncoder`, create an instance of the class and then call its `encode` method, passing
/// the value you want to encode. The method returns an array of `SQLiteRow` instances representing the encoded data.
///
/// Example usage:
/// ```swift
/// let encoder = RowEncoder(userInfo: [:])
/// do {
///     let rows = try encoder.encode(myObject)
///     // Use the encoded SQLite rows as needed
/// } catch {
///     print("Error encoding: \(error)")
/// }
/// ```
///
/// - Note: This class is intended to be used with values conforming to the `Encodable` protocol.
///         It does not handle decoding SQLite rows back into Swift objects.
public final class RowEncoder {
    // MARK: - Properties
    
    /// A dictionary containing user-defined information for the encoding process.
    public var userInfo: [CodingUserInfoKey : Any]
    
    // MARK: - Inits
    
    /// Initializes a new instance of `RowEncoder`.
    ///
    /// - Parameter userInfo: A dictionary containing user-defined information for the encoding process.
    public init(userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    /// Encodes the given value into a SQLite row.
    ///
    /// - Parameter value: The value to encode.
    /// - Returns: An `SQLiteRow` instance representing the encoded data.
    /// - Throws: An error if the encoding process fails.
    public func encode<T: Encodable>(_ value: T) throws -> SQLiteRow {
        let encoder = Encoder<SQLiteRow>(codingPath: [], userInfo: userInfo)
        try value.encode(to: encoder)
        return encoder.output ?? []
    }
    
    /// Encodes the given value into SQLite rows.
    ///
    /// - Parameter value: The value to encode.
    /// - Returns: An array of `SQLiteRow` instances representing the encoded data.
    /// - Throws: An error if the encoding process fails.
    public func encode<T: Encodable>(_ value: T) throws -> [SQLiteRow] {
        let encoder = Encoder<[SQLiteRow]>(codingPath: [], userInfo: userInfo)
        try value.encode(to: encoder)
        return encoder.output ?? []
    }
}

#if canImport(Combine)
import Combine

// MARK: - TopLevelEncoder

extension RowEncoder: TopLevelEncoder {
    /// The type of encoded output produced by this encoder.
    public typealias Output = [SQLiteRow]
}
#endif
