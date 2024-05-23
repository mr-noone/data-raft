import Foundation

extension OrderBy {
    /// Enumeration defining the sort order for a sort descriptor.
    ///
    /// Use `SortOrder` to specify whether a column should be sorted in ascending or descending order.
    public enum SortOrder: String, CustomStringConvertible {
        /// Indicates ascending sort order.
        case ascending = "ASC"
        
        /// Indicates descending sort order.
        case descending = "DESC"
        
        // MARK: - Properties
        
        /// Returns a string representation of the sort order.
        ///
        /// For ascending order, returns "ASC".
        /// For descending order, returns "DESC".
        @inlinable
        public var description: String {
            rawValue
        }
    }
}
