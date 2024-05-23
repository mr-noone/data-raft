import Foundation

/// A structure representing an ORDER BY clause in a SQL query, composed of one or more sort descriptors.
///
/// An `OrderBy` object allows specifying sorting criteria for the result set of a SQL query.
/// It consists of one or more `SortDescriptor` objects, each defining a column to sort by,
/// along with optional settings for sort order and null placement.
///
/// You can create an `OrderBy` object using an array literal of `SortDescriptor` objects, providing the desired
/// sorting criteria. The resulting `OrderBy` object can then be applied in a SQL query's ORDER BY clause.
///
/// Example Usage:
/// ```swift
/// let orderBy: OrderBy = [
///     .init(column: "name", sortOrder: .ascending),
///     .init(column: "age", sortOrder: .descending, nullPlacement: .last)
/// ]
/// print(orderBy) // Output: ORDER BY name ASC, age DESC NULLS LAST
/// ```
///
/// ## Topics
///
/// ### Subtypes
///
/// - ``SortDescriptor``
/// - ``SortOrder``
/// - ``NullPlacement``
///
/// ### Initializers
///
/// - ``init(_:)``
/// - ``init(arrayLiteral:)``
///
/// ### Instance Properties
///
/// - ``descriptors``
/// - ``description``
public struct OrderBy: ExpressibleByArrayLiteral, CustomStringConvertible {
    // MARK: - Properties
    
    /// The sort descriptors specifying the sorting criteria.
    public let descriptors: [SortDescriptor]
    
    /// Returns a string representation of the ORDER BY clause.
    ///
    /// If there are no sort descriptors, an empty string is returned.
    @inlinable
    public var description: String {
        guard !descriptors.isEmpty else { return "" }
        let descriptors = descriptors.map { $0.description }
        return "ORDER BY \(descriptors.joined(separator: ", "))"
    }
    
    // MARK: - Inits
    
    /// Creates an `OrderBy` object with the specified sort descriptors.
    ///
    /// - Parameter descriptors: The sort descriptors specifying the sorting criteria.
    public init(_ descriptors: [SortDescriptor]) {
        self.descriptors = descriptors.filter { !$0.column.isEmpty }
    }
    
    /// Creates an `OrderBy` object with the specified sort descriptors.
    ///
    /// - Parameter descriptors: The sort descriptors specifying the sorting criteria.
    public init(arrayLiteral descriptors: SortDescriptor...) {
        self.init(descriptors)
    }
}
