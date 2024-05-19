import Foundation

/// Represents a single row of data fetched from an SQLite database.
///
/// The `SQLiteRow` struct conforms to the `Collection` protocol,
/// allowing for convenient iteration and access to its elements.
///
/// It also conforms to `ExpressibleByArrayLiteral` and `ExpressibleByDictionaryLiteral`,
/// allowing initialization with array or dictionary literals.
public struct SQLiteRow: Collection, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    /// Alias for the type representing a column name in an SQLite database.
    public typealias Column = String
    
    /// Alias for the type representing a value in an SQLite database.
    public typealias Value = SQLiteValue
    
    /// Alias for the index type used in `SQLiteRow`.
    public typealias Index = Int
    
    /// Represents a column-value pair in an SQLite row.
    public typealias Element = (column: Column, value: Value)
    
    // MARK: - Properties
    
    /// Array containing the column-value pairs of the row.
    private var elements: [Element]
    
    /// The number of column-value pairs in the row.
    ///
    /// - Complexity: O(1)
    public var count: Int {
        elements.count
    }
    
    /// A Boolean value indicating whether the row is empty.
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    /// The starting index of the row.
    ///
    /// - Complexity: O(1)
    public var startIndex: Index {
        elements.startIndex
    }
    
    /// The ending index of the row.
    ///
    /// - Complexity: O(1)
    public var endIndex: Index {
        elements.endIndex
    }
    
    // MARK: - Inits
    
    /// Initializes an empty `SQLiteRow`.
    public init() {
        self.elements = []
    }
    
    /// Initializes a `SQLiteRow` with elements provided as an array literal.
    ///
    /// - Parameter elements: The array containing column-value pairs.
    ///
    /// This initializer creates a `SQLiteRow` instance with column-value pairs provided as an array literal.
    /// Each pair consists of a column name and its corresponding value.
    ///
    /// Example:
    /// ```swift
    /// let row: SQLiteRow = [
    ///     ("ID", .int(1)),
    ///     ("Name", .text("John"))
    /// ]
    /// ```
    ///
    /// - Note: The order of elements in the resulting `SQLiteRow` corresponds to the order in the array literal.
    public init(arrayLiteral elements: Element...) {
        self.elements = elements
    }
    
    /// Initializes a `SQLiteRow` with elements provided as a dictionary literal.
    ///
    /// - Parameter elements: The dictionary containing column-value pairs.
    ///
    /// This initializer creates a `SQLiteRow` instance with column-value pairs provided as a dictionary literal.
    /// Each pair consists of a column name and its corresponding value.
    ///
    /// Example:
    /// ```swift
    /// let row: SQLiteRow = [
    ///     "ID" : .int(1),
    ///     "Name" : .text("John")
    /// ]
    /// ```
    ///
    /// - Note: The order of elements in the resulting `SQLiteRow` may not necessarily
    /// match the order in the dictionary literal.
    public init(dictionaryLiteral elements: (Column, Value)...) {
        self.elements = elements
    }
    
    // MARK: - Subscripts
    
    /// Accesses the column-value pair at the specified index within the row.
    ///
    /// - Parameter index: The index of the element to access.
    /// - Returns: The column-value pair at the specified index.
    ///
    /// This subscript allows accessing the column-value pair at a specific index within the row.
    /// The index should be within the bounds of the row's elements, otherwise, it will result in a runtime error.
    ///
    /// - Complexity: O(1)
    public subscript(index: Index) -> Element {
        get { elements[index] }
    }
    
    /// Accesses the value associated with the specified column name.
    ///
    /// - Parameter column: The name of the column.
    /// - Returns: The value associated with the specified column name, or `nil` if the column is not found.
    /// - Important: When setting a value for a column that does not exist in the row, a new column-value pair is added.
    ///              When setting `nil` as the value for an existing column, the corresponding column-value pair is removed.
    ///
    /// - Complexity: O(*n*), where *n* is the number of column-value pairs in the row.
    public subscript(column: Column) -> Value? {
        get {
            guard let index = index(for: column) else {
                return nil
            }
            return self[index].value
        }
        set {
            if let newValue = newValue {
                if let index = index(for: column) {
                    elements[index].value = newValue
                } else {
                    elements.append((column, newValue))
                }
            } else {
                if let index = index(for: column) {
                    elements.remove(at: index)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    /// Returns the index after the specified index.
    ///
    /// - Parameter i: The index.
    /// - Returns: The index immediately after the specified index within the row.
    ///
    /// This method is used to advance to the next index in the row when iterating over its elements.
    ///
    /// - Complexity: O(1)
    public func index(after i: Index) -> Index {
        elements.index(after: i)
    }
    
    /// Returns the index of the column-value pair with the specified column name, if it exists in the row.
    ///
    /// - Parameter column: The name of the column.
    /// - Returns: The index of the column-value pair with the specified column name, or `nil` if not found.
    ///
    /// This method searches for the column-value pair with the specified column name within the row.
    ///
    /// - Complexity: O(*n*), where *n* is the number of column-value pairs in the row.
    public func index(for column: Column) -> Index? {
        elements.firstIndex { $0.column == column }
    }
}
