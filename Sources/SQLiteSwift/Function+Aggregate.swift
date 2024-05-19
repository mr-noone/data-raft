import Foundation

extension Function {
    /// The `Aggregate` protocol extends the `Definition` protocol and adds behavior for SQLite aggregate functions.
    ///
    /// Aggregate functions are used to compute sum, average, minimum, maximum, etc. over a set of values.
    public protocol Aggregate: Definition {
        /// Initializes the aggregate function.
        init()
        
        /// Updates the state of the aggregate function with the given arguments.
        ///
        /// - Parameter args: The function arguments.
        mutating func step(args: Arguments) throws
        
        /// Finalizes the computation of the aggregate function and returns the result, conforming to `SQLiteConvertible`.
        ///
        /// - Returns: The aggregation result, conforming to `SQLiteConvertible`.
        func finalize() throws -> SQLiteConvertible?
    }
}
