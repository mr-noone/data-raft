import Foundation

/// Represents different synchronous modes available for an SQLite database.
///
/// For more details, refer to [Synchronous Pragma](https://www.sqlite.org/pragma.html#pragma_synchronous).
public enum SQLiteSynchronous: UInt8, SQLiteConvertible {
    /// Synchronous mode off.
    case off = 0
    
    /// Normal synchronous mode.
    case normal = 1
    
    /// Full synchronous mode.
    case full = 2
    
    /// Extra synchronous mode.
    case extra = 3
}
