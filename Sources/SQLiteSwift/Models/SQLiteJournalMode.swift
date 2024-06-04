import Foundation

/// Represents the journal modes available for an SQLite database.
///
/// For more details, refer to [Journal Mode Pragma](https://www.sqlite.org/pragma.html#pragma_journal_mode).
public enum SQLiteJournalMode: String, SQLiteConvertible {
    /// DELETE journal mode.
    case delete = "DELETE"
    
    /// TRUNCATE journal mode.
    case truncate = "TRUNCATE"
    
    /// PERSIST journal mode.
    case persist = "PERSIST"
    
    /// MEMORY journal mode.
    case memory = "MEMORY"
    
    /// Write-Ahead Logging (WAL) journal mode.
    case wal = "WAL"
    
    /// OFF journal mode.
    case off = "OFF"
}
