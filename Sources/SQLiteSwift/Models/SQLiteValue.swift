import Foundation

/// Represents a value that can be stored in an SQLite database.
public enum SQLiteValue: Equatable {
    /// Represents an integer value.
    /// - Parameter value: The integer value.
    case int(Int64)
    
    /// Represents a real (floating point) value.
    /// - Parameter value: The real value.
    case real(Double)
    
    /// Represents a text (string) value.
    /// - Parameter value: The text value.
    case text(String)
    
    /// Represents a blob (binary data) value.
    /// - Parameter value: The blob value.
    case blob(Data)
    
    /// Represents a NULL value.
    case null
}

extension SQLiteValue: CustomStringConvertible {
    /// A string representation of the SQLite value.
    public var description: String {
        sqliteLiteral
    }
}

extension SQLiteValue {
    /// Returns a string literal representation of the SQLite value.
    var sqliteLiteral: String {
        switch self {
        case .null:           return "NULL"
        case .int(let int):   return "\(int)"
        case .real(let real): return "\(real)"
        case .text(let text): return "'\(text)'"
        case .blob(let data): return "X'\(data.hex)'"
        }
    }
}
