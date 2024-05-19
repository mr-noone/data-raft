import Foundation

/// Represents a collection of arguments used in SQLite queries or commands.
///
/// The `SQLiteArguments` struct conforms to the `Collection` protocol,
/// allowing for convenient iteration and access to its elements.
///
/// It also conforms to `ExpressibleByArrayLiteral` and `ExpressibleByDictionaryLiteral`,
/// allowing initialization with array or dictionary literals.
public struct SQLiteArguments: Collection, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    /// Represents a token for an argument, which can be either indexed or named.
    public enum Token {
        /// Represents an indexed argument with its index.
        case indexed(index: Int)
        
        /// Represents a named argument with its name.
        case named(name: String)
    }
    
    /// Alias for the index type used in `SQLiteArguments`.
    public typealias Index = Int
    
    /// Represents a tuple containing a token and its corresponding value.
    public typealias Element = (token: Token, value: SQLiteValue)
    
    // MARK: - Properties
    
    private var elements: [Element]
    
    /// The number of arguments in the collection.
    public var count: Int {
        elements.count
    }
    
    /// A Boolean value indicating whether the collection is empty.
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    /// The starting index of the collection.
    public var startIndex: Index {
        elements.startIndex
    }
    
    /// The ending index of the collection.
    public var endIndex: Index {
        elements.endIndex
    }
    
    // MARK: - Inits
    
    /// Initializes an `SQLiteArguments` instance with elements provided as an array literal.
    ///
    /// - Parameter elements: The array containing elements convertible to `SQLiteValue`.
    ///
    /// This initializer creates an `SQLiteArguments` instance with elements provided as an array literal.
    /// Each element can be either `nil` or convertible to `SQLiteValue`.
    ///
    /// Example:
    /// ```swift
    /// let args: SQLiteArguments = ["John", 25]
    /// ```
    public init(arrayLiteral elements: SQLiteConvertible?...) {
        self.elements = elements.enumerated().map {
            (.indexed(index: $0.offset + 1), $0.element?.sqliteValue ?? .null)
        }
    }
    
    /// Initializes an `SQLiteArguments` instance with elements provided as a dictionary literal.
    ///
    /// - Parameter elements: The dictionary containing named elements convertible to `SQLiteValue`.
    ///
    /// This initializer creates an `SQLiteArguments` instance with elements provided as a dictionary literal.
    /// Each element consists of a name and a value convertible to `SQLiteValue`.
    ///
    /// Example:
    /// ```swift
    /// let args: SQLiteArguments = ["name": "John", "age": 25]
    /// ```
    public init(dictionaryLiteral elements: (String, SQLiteConvertible?)...) {
        self.elements = elements.map { (name, element) in
            (.named(name: name), element?.sqliteValue ?? .null)
        }
    }
    
    /// Initializes an `SQLiteArguments` instance with elements from an `SQLiteRow`.
    ///
    /// - Parameter row: The `SQLiteRow` containing column-value pairs.
    ///
    /// This initializer creates an `SQLiteArguments` instance with elements extracted from an `SQLiteRow`.
    /// Each column name in the row corresponds to a named argument in the `SQLiteArguments` instance.
    ///
    /// Example:
    /// ```swift
    /// let row = ["name": "John", "age": 25] as SQLiteRow
    /// let args = SQLiteArguments(row: row)
    /// ```
    public init(row: SQLiteRow) {
        self.elements = row.map { (column, value) in
            (.named(name: column), value)
        }
    }
    
    // MARK: - Subscripts
    
    /// Accesses the argument at the specified index within the collection.
    ///
    /// - Parameter index: The index of the argument to access.
    /// - Returns: The argument at the specified index.
    ///
    /// This subscript allows accessing the argument at a specific index within the collection.
    /// The index should be within the bounds of the collection's elements, otherwise, it will result in a runtime error.
    ///
    /// - Complexity: O(1)
    public subscript(index: Index) -> Element {
        get { elements[index] }
    }
    
    // MARK: - Methods
    
    /// Returns the index after the specified index.
    ///
    /// - Parameter i: The index.
    /// - Returns: The index immediately after the specified index within the collection.
    ///
    /// This method is used to advance to the next index in the collection when iterating over its elements.
    ///
    /// - Complexity: O(1)
    public func index(after i: Index) -> Index {
        elements.index(after: i)
    }
}
