import Foundation

extension OrderBy {
    /// Enumeration defining the placement of NULL values in a sort descriptor.
    ///
    /// Use `NullPlacement` to specify whether NULL values should be placed first or last when sorting a column.
    public enum NullPlacement: String, CustomStringConvertible {
        /// Indicates that NULL values should be placed first.
        case first = "NULLS FIRST"
        
        /// Indicates that NULL values should be placed last.
        case last = "NULLS LAST"
        
        // MARK: - Properties
        
        /// Returns a string representation of the NULL placement.
        ///
        /// For placing NULL values first, returns "NULLS FIRST".
        /// For placing NULL values last, returns "NULLS LAST".
        @inlinable
        public var description: String {
            rawValue
        }
    }
}
