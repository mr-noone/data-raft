import Foundation
import SQLiteSwift

/// A structure representing a WHERE clause in a SQL query.
///
/// The `Predicate` struct encapsulates a condition used to filter data in SQL queries.
/// It consists of a string expression representing the condition and optional arguments for parameterized queries.
///
/// ## Parameters
///
/// A "variable" or "parameter" token specifies a placeholder in the expression for a value that is filled in at runtime.
/// Parameters can take several forms:
///
/// - Indexed: Represented by numerical indices (`?NNNN`, `?`).
///   These placeholders correspond to specific parameter positions.
/// - Named: Represented by string names (`:AAAA`, `@AAAA`, `$AAAA`).
///   These placeholders are identified by unique names.
///
/// More information on SQLite parameters can be found [here](https://www.sqlite.org/lang_expr.html#varparam).
/// The `Predicate` structure supports indexed (?) and named (:AAAA) forms of parameters.
///
/// ## Usage
///
/// For indexed arguments, pass an array of values:
///
/// ```swift
/// let arguments: Arguments = ["John", 30]
/// let predicate = Predicate(expression: "name = ? AND age = ?", arguments)
/// ```
///
/// For named arguments, pass a dictionary of named values:
///
/// ```swift
/// let arguments: Arguments = ["name": "John", "age": 30]
/// let predicate = Predicate(expression: "name = :name AND age = :age", arguments)
/// ```
///
/// You can also directly pass indexed arguments using the initializer with variadic parameters:
///
/// ```swift
/// let predicate = Predicate(expression: "name = ? AND age = ?", "John", 30)
/// ```
///
/// ## Topics
///
/// ### Type Aliases
///
/// - ``Arguments``
///
/// ### Initializers
///
/// - ``init(expression:_:)-5pxj3``
/// - ``init(expression:_:)-9bqp5``
/// - ``init(expression:_:)-7js6c``
///
/// ### Instance Properties
///
/// - ``expression``
/// - ``arguments``
/// - ``description``
public struct Predicate: CustomStringConvertible {
    /// Typealias for the set of `Arguments` used in a predicate.
    public typealias Arguments = Statement.Arguments
    
    // MARK: - Properties
    
    /// The string expression of the predicate.
    public let expression: String
    
    /// The arguments associated with the predicate expression.
    public let arguments: Arguments?
    
    /// A textual representation of the predicate.
    ///
    /// If the expression is empty, an empty string is returned.
    @inlinable
    public var description: String {
        guard !expression.isEmpty else { return "" }
        return "WHERE \(expression)"
    }
    
    // MARK: - Inits
    
    /// Initializes a new `Predicate` with the given expression and arguments.
    ///
    /// - Parameters:
    ///   - expression: The string expression representing the condition.
    ///   - arguments: Optional arguments associated with the expression.
    public init(expression: String, _ arguments: Arguments? = nil) {
        self.expression = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        self.arguments = arguments
    }
    
    /// Initializes a new `Predicate` with the given expression and arguments.
    ///
    /// - Parameters:
    ///   - expression: The string expression representing the condition.
    ///   - arguments: Optional arguments associated with the expression.
    public init(expression: String, _ arguments: SQLiteBindable?...) {
        self.init(expression: expression, Arguments(arguments))
    }
    
    /// Initializes a new `Predicate` with the given expression and arguments.
    ///
    /// - Parameters:
    ///   - expression: The string expression representing the condition.
    ///   - arguments: Optional arguments associated with the expression.
    public init(expression: String, _ arguments: [SQLiteBindable?]) {
        self.init(expression: expression, Arguments(arguments))
    }
}
