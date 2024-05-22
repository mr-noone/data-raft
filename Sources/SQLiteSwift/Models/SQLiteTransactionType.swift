import Foundation

/// An enumeration representing different types of SQLite transactions.
///
/// For more detailed information about SQLite transactions, refer to the
/// [SQLite documentation](https://www.sqlite.org/lang_transaction.html).
public enum SQLiteTransactionType: String, CustomStringConvertible {
    /// A deferred transaction.
    case deferred = "DEFERRED"
    
    /// An immediate transaction.
    case immediate = "IMMEDIATE"
    
    /// An exclusive transaction.
    case exclusive = "EXCLUSIVE"
    
    /// A textual representation of the transaction type.
    public var description: String {
        rawValue
    }
}
