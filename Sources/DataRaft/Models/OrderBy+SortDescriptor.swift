import Foundation

extension OrderBy {
    /// A structure representing a sort descriptor used in the ORDER BY clause.
    public struct SortDescriptor: CustomStringConvertible {
        // MARK: - Properties
        
        /// The name of the column to sort by.
        public let column: String
        /// The sort order for the column.
        public let sortOrder: SortOrder?
        /// The placement of NULL values for the column.
        public let nullPlacement: NullPlacement?
        
        /// Returns a string representation of the sort descriptor.
        ///
        /// The format is "column [ASC|DESC] [NULLS FIRST|NULLS LAST]".
        /// If sort order or null placement is not specified, they are omitted from the description.
        @inlinable
        public var description: String {
            [
                column,
                sortOrder?.description,
                nullPlacement?.description
            ].compactMap {
                $0
            }.joined(separator: " ")
        }
        
        // MARK: - Inits
        
        /// Creates a sort descriptor with the specified parameters.
        ///
        /// - Parameters:
        ///   - column: The name of the column to sort by.
        ///   - sortOrder: The sort order for the column. Default is `nil`.
        ///   - nullPlacement: The placement of NULL values for the column. Default is `nil`.
        public init(
            column: String,
            sortOrder: SortOrder? = nil,
            nullPlacement: NullPlacement? = nil
        ) {
            self.column = column.trimmingCharacters(in: .whitespacesAndNewlines)
            self.sortOrder = sortOrder
            self.nullPlacement = nullPlacement
        }
    }
}
