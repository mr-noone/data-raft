import Foundation
import SQLiteC

extension Connection {
    /// The `Location` enum represents different locations for a SQLite database.
    /// You can specify the location of the SQLite database using the options provided by this enum.
    public enum Location {
        /// A database located at a given file path or URI.
        ///
        /// For more details, refer to [Uniform Resource Identifiers](https://www.sqlite.org/uri.html).
        /// - Parameter path: The path or URI to the database file.
        case file(path: String)
        
        /// An in-memory database.
        ///
        /// In-memory databases are temporary and exist only in RAM. They are not persisted to disk.
        /// For more details, refer to [In-Memory Databases](https://www.sqlite.org/inmemorydb.html).
        case inMemory
        
        /// A temporary database on disk.
        ///
        /// Temporary databases are created on disk but are not intended for persistent storage.
        /// They are deleted automatically when the connection is closed.
        /// For more details, refer to [Temporary Databases](https://www.sqlite.org/inmemorydb.html).
        case temporary
        
        /// Returns the path to the database.
        var path: String {
            switch self {
            case .file(let path): return path
            case .inMemory: return ":memory:"
            case .temporary: return ""
            }
        }
    }
}
