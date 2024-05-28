import Foundation

extension Statement {
    /// A structure representing a set of arguments used in database statements.
    ///
    /// `Arguments` provides a convenient way to manage and pass parameters to database queries.
    /// It supports both indexed and named tokens, allowing flexibility in specifying parameters.
    ///
    /// ## Argument Tokens
    ///
    /// A "token" in this context refers to a placeholder in the SQL statement for a value that is provided at runtime.
    /// There are two types of tokens:
    ///
    /// - Indexed Tokens: Represented by numerical indices (`?NNNN`, `?`).
    /// These placeholders correspond to specific parameter positions.
    /// - Named Tokens: Represented by string names (`:AAAA`, `@AAAA`, `$AAAA`).
    /// These placeholders are identified by unique names.
    ///
    /// More information on SQLite parameters can be found [here](https://www.sqlite.org/lang_expr.html#varparam).
    /// The `Arguments` structure supports indexed (?) and named (:AAAA) forms of tokens.
    ///
    /// ## Creating Arguments
    ///
    /// You can initialize `Arguments` using arrays or dictionaries:
    ///
    /// - **Indexed Arguments**: Initialize with an array of values or use an array literal.
    /// ```swift
    /// let args: Statement.Arguments = ["John", 30]
    /// ```
    /// - **Named Arguments**: Initialize with a dictionary of named values or use a dictionary literal.
    /// ```swift
    /// let args: Statement.Arguments = ["name": "John", "age": 30]
    /// ```
    ///
    /// ## Combining Arguments
    ///
    /// You can concatenate and merge sets of `Arguments` using operators:
    ///
    /// - **`+` Operator**: Concatenates two argument sets.
    /// If any argument token already exists in the left-hand side collection, it raises a fatal error indicating a duplicate token.
    /// - **`&+` Operator**: Merges two argument sets. Allows overriding named arguments.
    /// - **`+=` Operator**: Adds the arguments from the right-hand side collection to the left-hand side collection.
    /// If any argument token already exists in the left-hand side collection, it raises a fatal error indicating a duplicate token.
    ///
    /// ```swift
    /// var args = Statement.Arguments()
    /// args += ["name": "John"]
    /// args += ["name": "Jane"] // Allowed with `&+` operator
    /// ```
    ///
    /// ## Mixing Arguments
    ///
    /// While possible, mixing named and indexed arguments is generally discouraged due to potential confusion.
    ///
    /// ```swift
    /// var args = Statement.Arguments()
    /// args += ["name": "John", "age": 30] // Named arguments
    /// args += ["city", "country"]         // Indexed arguments
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Subtypes
    ///
    /// - ``Token``
    ///
    /// ### Type Aliases
    ///
    /// - ``Index``
    /// - ``Element``
    ///
    /// ### Initializers
    ///
    /// - ``init()``
    /// - ``init(_:)-4ql0v``
    /// - ``init(_:)-7vfog``
    /// - ``init(_:)-3shvx``
    /// - ``init(arrayLiteral:)``
    /// - ``init(dictionaryLiteral:)``
    ///
    /// ### Instance Properties
    ///
    /// - ``tokens``
    /// - ``count``
    /// - ``isEmpty``
    /// - ``startIndex``
    /// - ``endIndex``
    /// - ``description``
    ///
    /// ### Instance Methods
    ///
    /// - ``index(after:)``
    /// - ``firstIndex(by:)``
    ///
    /// ### Subscripts
    ///
    /// - ``subscript(_:)``
    public struct Arguments: Collection, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, CustomStringConvertible {
        /// Represents a token used in database statements, either indexed or named.
        ///
        /// Tokens are used to identify placeholders for values in SQL statements.
        /// They can either be indexed, represented by an integer index, or named, represented by a string name.
        public enum Token: Hashable, CustomStringConvertible {
            /// Represents an indexed token with a numerical index.
            case indexed(index: Int)
            /// Represents a named token with a string name.
            case named(name: String)
            
            /// A textual description of the token.
            ///
            /// This property provides a human-readable description of the token, either as an indexed or named token.
            @inlinable
            public var description: String {
                switch self {
                case .indexed(let index):
                    return index.description
                case .named(let name):
                    return "':\(name)'"
                }
            }
        }
        
        /// Alias for the index type used in `Arguments`.
        public typealias Index = Int
        
        /// Represents a token-value pair in an `Arguments`.
        public typealias Element = (token: Token, value: SQLiteValue)
        
        // MARK: - Properties
        
        private var elements: [Element]
        
        /// Returns an array of tokens contained in the `Arguments`.
        ///
        /// - Complexity: O(*n*), where *n* is the number of elements in the `Arguments`.
        public var tokens: [Token] {
            elements.map { $0.token }
        }
        
        /// The number of elements in the `Arguments`.
        ///
        /// - Complexity: O(1)
        public var count: Int {
            elements.count
        }
        
        /// A Boolean value indicating whether the `Arguments` is empty.
        ///
        /// - Complexity: O(1)
        public var isEmpty: Bool {
            elements.isEmpty
        }
        
        /// The index of the first element in the `Arguments`.
        ///
        /// - Complexity: O(1)
        public var startIndex: Index {
            elements.startIndex
        }
        
        /// The index after the last element in the `Arguments`.
        ///
        /// - Complexity: O(1)
        public var endIndex: Index {
            elements.endIndex
        }
        
        /// A textual representation of the `Arguments`.
        ///
        /// - Complexity: O(*n*), where *n* is the number of elements in the `Arguments`.
        public var description: String {
            let elements = elements.map { token, value in
                let token = token.description
                let value = value.description
                return "(token: \(token), value: \(value))"
            }.joined(separator: ", ")
            return "[\(elements)]"
        }
        
        // MARK: - Inits
        
        /// Initializes an empty `Arguments`.
        ///
        /// - Complexity: O(1)
        public init() {
            self.elements = []
        }
        
        /// Initializes `Arguments` with an array of values.
        ///
        /// - Parameter elements: An array of `SQLiteBindable` values.
        ///
        /// - Complexity: O(*n*), where *n* is the number of elements in the input array.
        public init(_ elements: [SQLiteBindable?]) {
            self.elements = elements.enumerated().map { offset, value in
                (.indexed(index: offset + 1), value?.sqliteValue ?? .null)
            }
        }
        
        /// Initializes `Arguments` with a dictionary of named values.
        ///
        /// - Parameter elements: A dictionary mapping names to `SQLiteBindable` values.
        ///
        /// - Complexity: O(*n*), where *n* is the number of elements in the input dictionary.
        public init(_ elements: [String : SQLiteBindable?]) {
            self.elements = elements.map { (name, value) in
                (.named(name: name), value?.sqliteValue ?? .null)
            }
        }
        
        /// Initializes `Arguments` with values from a `SQLiteRow`.
        ///
        /// - Parameter row: A `SQLiteRow` containing column-value pairs.
        ///
        /// - Complexity: O(*n*), where *n* is the number of elements in the input `SQLiteRow`.
        public init(_ row: SQLiteRow) {
            self.elements = row.map {
                (.named(name: $0.column), $0.value)
            }
        }
        
        /// Initializes `Arguments` with an array literal of values.
        ///
        /// - Parameter elements: An array of `SQLiteBindable?` values.
        ///
        /// - Complexity: O(*n*), where *n* is the number of elements in the input array.
        public init(arrayLiteral elements: SQLiteBindable?...) {
            self.init(elements)
        }
        
        /// Initializes `Arguments` with a dictionary literal of named values.
        ///
        /// - Parameter elements: A list of tuples representing name-value pairs.
        ///
        /// - Complexity: O(*n*), where *n* is the number of elements in the input dictionary literal.
        public init(dictionaryLiteral elements: (String, SQLiteBindable?)...) {
            self.elements = elements.map { (name, value) in
                (.named(name: name), value?.sqliteValue ?? .null)
            }
        }
        
        // MARK: - Subscripts
        
        /// Accesses the element at the specified position.
        ///
        /// - Parameter index: The position of the element to access.
        /// - Returns: The element at the specified index.
        ///
        /// - Complexity: O(1)
        public subscript(index: Index) -> Element {
            get { elements[index] }
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
        
        /// Returns the index of the first occurrence of a token in the `Arguments`.
        ///
        /// - Parameter token: The token to search for.
        /// - Returns: The index of the first occurrence of `token` in the `Arguments`,
        ///            or `nil` if `token` is not found.
        ///
        /// - Complexity: O(*n*), where *n* is the number of elements in the `Arguments`.
        @inlinable
        public func firstIndex(by token: Token) -> Index? {
            firstIndex { $0.token == token }
        }
        
        // MARK: - Operators
        
        /// Concatenates an `Arguments` instance with a single `SQLiteValue`.
        ///
        /// This operator appends a single `SQLiteValue` to the `lhs` `Arguments`
        /// instance, creating a new `Arguments` instance.
        /// The `SQLiteValue` is appended as an indexed token, where the index
        /// corresponds to the position of the value in the `lhs` instance plus one.
        ///
        /// - Parameters:
        ///   - lhs: The left-hand side `Arguments` instance.
        ///   - rhs: The right-hand side `SQLiteValue` to be appended.
        /// - Returns: A new `Arguments` instance with the `SQLiteValue` appended as an indexed token.
        ///
        /// - Complexity: O(1)
        public static func + (lhs: Arguments, rhs: SQLiteValue) -> Arguments {
            var lhs = lhs
            lhs.elements.append((
                .indexed(index: lhs.count + 1),
                rhs
            ))
            return lhs
        }
        
        /// Concatenates two collections of arguments into a new collection.
        ///
        /// This operator creates a new collection by appending the arguments from the `rhs`
        /// collection to the `lhs` collection.
        /// It does not modify the original collections.
        ///
        /// - Parameters:
        ///   - lhs: The left-hand side collection of arguments.
        ///   - rhs: The right-hand side collection of arguments.
        /// - Returns: A new collection containing the combined arguments from both `lhs` and `rhs`.
        ///
        /// - Warning: Using this operator may result in a fatal error if any token in the `rhs`
        ///            collection is already present in the `lhs` collection.
        ///
        /// - Complexity: O(*n*), where *n* is the total number of arguments in both `lhs` and `rhs` collections.
        public static func + (lhs: Arguments, rhs: Arguments) -> Arguments {
            var lhs = lhs
            lhs += rhs
            return lhs
        }
        
        /// Merges two collections of arguments, appending indexed arguments and replacing existing named arguments.
        ///
        /// This operator creates a new collection by merging the arguments from the
        /// `rhs` collection into the `lhs` collection.
        /// It appends indexed arguments to the `lhs` collection and replaces existing
        /// named arguments if they already exist in the `lhs` collection.
        ///
        /// - Parameters:
        ///   - lhs: The left-hand side collection of arguments.
        ///   - rhs: The right-hand side collection of arguments.
        /// - Returns: A new collection containing the merged arguments from both `lhs` and `rhs`.
        ///
        /// - Complexity: O(*n* * *m*), where *n* is the number of arguments in the `lhs`
        ///               collection and *m* is the number of arguments in the `rhs` collection.
        public static func &+ (lhs: Arguments, rhs: Arguments) -> Arguments {
            let tokens = Set(lhs.tokens)
            var lhs = lhs
            rhs.forEach { token, value in
                switch token {
                case .indexed:
                    lhs.elements.append((.indexed(index: lhs.count + 1), value))
                case .named:
                    if tokens.contains(token), let index = lhs.firstIndex(by: token) {
                        lhs.elements[index] = (token, value)
                    } else {
                        lhs.elements.append((token, value))
                    }
                }
            }
            return lhs
        }
        
        /// Adds the arguments from the right-hand side collection to the left-hand side collection.
        ///
        /// This operator appends the arguments from the `rhs` collection to the `lhs` collection.
        /// If any argument token already exists in the `lhs` collection, it raises a fatal error indicating a duplicate token.
        ///
        /// - Parameters:
        ///   - lhs: The left-hand side collection to which the arguments will be added.
        ///   - rhs: The right-hand side collection containing the arguments to be added.
        ///
        /// - Warning: Using this operator may result in a fatal error if any token in the `rhs`
        ///            collection is already present in the `lhs` collection.
        ///
        /// - Complexity: O(*n*), where *n* is the number of arguments in the `rhs` collection.
        public static func += (lhs: inout Arguments, rhs: Arguments) {
            let tokens = Set(lhs.tokens)
            rhs.forEach { token, value in
                switch token {
                case .indexed:
                    lhs.elements.append((.indexed(index: lhs.count + 1), value))
                case .named:
                    if tokens.contains(token) {
                        fatalError("Duplicate token '\(token)' found.")
                    } else {
                        lhs.elements.append((token, value))
                    }
                }
            }
        }
    }
}
