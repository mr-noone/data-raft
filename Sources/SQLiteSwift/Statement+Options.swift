import Foundation
import SQLiteC

extension Statement {
    /// The `Options` struct represents various options for preparing SQLite statements.
    public struct Options: OptionSet {
        /// The raw value representing the combination of options.
        public var rawValue: UInt32
        
        /// Indicates that the prepared statement should be persistent and reusable.
        public static let persistent = Self(rawValue: UInt32(SQLITE_PREPARE_PERSISTENT))
        
        /// Indicates that the SQL statement should be normalized before preparation.
        public static let normalize = Self(rawValue: UInt32(SQLITE_PREPARE_NORMALIZE))
        
        /// Indicates that virtual tables should not be used during preparation.
        public static let noVtab = Self(rawValue: UInt32(SQLITE_PREPARE_NO_VTAB))
        
        /// Initializes an `Options` instance with the given raw value.
        /// - Parameter rawValue: The raw value representing the combination of options.
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}
