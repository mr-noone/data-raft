import Foundation

/// A structure representing a LIMIT clause in a SQL query,
/// specifying the maximum number of rows to return along with an optional starting offset.
///
/// A `Limit` object allows setting constraints on the number of rows returned by a SQL query,
/// with an option to specify a starting offset.
/// It consists of a `limit` property defining the maximum number of rows to return
/// and an optional `offset` property specifying the starting point.
///
/// You can create a `Limit` object using an integer literal for the `limit` parameter,
/// and optionally providing an `offset` value.
///
/// Example Usage:
/// ```swift
/// let limit: Limit = 10
/// print(limit) // Output: LIMIT 10
///
/// let limitWithOffset: Limit = Limit(limit: 5, offset: 10)
/// print(limitWithOffset) // Output: LIMIT 5 OFFSET 10
/// ```
///
/// ## Topics
///
/// ### Initializers
///
/// - ``init(limit:offset:)``
/// - ``init(integerLiteral:)``
///
/// ### Instance Properties
///
/// - ``limit``
/// - ``offset``
/// - ``description``
public struct Limit: ExpressibleByIntegerLiteral, CustomStringConvertible {
    // MARK: - Properties
    
    /// The maximum number of rows to return.
    public var limit: UInt
    
    /// An optional starting offset for row retrieval.
    public var offset: UInt?
    
    /// Returns a string representation of the LIMIT clause.
    ///
    /// If no offset is provided, only the limit is included.
    @inlinable
    public var description: String {
        if let offset = offset {
            return "LIMIT \(limit) OFFSET \(offset)"
        } else {
            return "LIMIT \(limit)"
        }
    }
    
    // MARK: - Inits
    
    /// Creates a `Limit` object with the specified limit and optional offset.
    ///
    /// - Parameters:
    ///   - limit: The maximum number of rows to return.
    ///   - offset: An optional starting offset for row retrieval.
    public init(limit: UInt, offset: UInt? = nil) {
        self.limit = limit
        self.offset = offset
    }
    
    /// Creates a `Limit` object using an integer literal for the limit.
    ///
    /// - Parameter limit: The maximum number of rows to return.
    public init(integerLiteral limit: UInt) {
        self.init(limit: limit)
    }
}
