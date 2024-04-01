import Foundation
import SQLiteC

/// Represents the data type of a column in the result set of the prepared SQL statement.
public enum SQLiteType: Int32 {
    /// The data type of an integer column.
    case int
    /// The data type of a real (floating point) column.
    case real
    /// The data type of a text (string) column.
    case text
    /// The data type of a blob (binary large object) column.
    case blob
    /// The data type of a NULL column.
    case null
    
    /// Returns the raw SQLite data type value corresponding to the column type.
    public var rawValue: Int32 {
        switch self {
        case .int:  return SQLITE_INTEGER
        case .real: return SQLITE_FLOAT
        case .text: return SQLITE_TEXT
        case .blob: return SQLITE_BLOB
        case .null: return SQLITE_NULL
        }
    }
    
    /// Initializes a `SQLiteType` enum case from its raw value.
    ///
    /// - Parameter rawValue: The raw value representing the column type.
    public init?(rawValue: Int32) {
        switch rawValue {
        case SQLITE_INTEGER:    self = .int
        case SQLITE_FLOAT:      self = .real
        case SQLITE_TEXT:       self = .text
        case SQLITE_BLOB:       self = .blob
        case SQLITE_NULL:       self = .null
        default:                return nil
        }
    }
}
