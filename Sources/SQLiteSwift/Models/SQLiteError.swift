import Foundation
import SQLiteC

/// A structure representing an error that occurs during SQLite operations.
///
/// For more details, refer to [Result and Error Codes](https://www.sqlite.org/rescode.html).
public struct SQLiteError: Error {
    // MARK: - Properties
    
    /// The error code associated with the SQLite error.
    public let code: Int32
    
    /// A message describing the SQLite error.
    public let mesg: String
    
    // MARK: - Initializers
    
    /// Initializes a `SQLiteError` instance using the error information from an SQLite connection.
    ///
    /// - Parameter connection: An opaque pointer to the SQLite connection.
    init(_ connection: OpaquePointer) {
        code = sqlite3_extended_errcode(connection)
        mesg = String(cString: sqlite3_errmsg(connection))
    }
    
    /// Initializes a `SQLiteError` instance with the provided error code and message.
    ///
    /// - Parameters:
    ///   - code: The error code.
    ///   - mesg: The error message.
    init(code: Int32, mesg: String) {
        self.code = code
        self.mesg = mesg
    }
}
