import Foundation

extension Function {
    /// The `Scalar` protocol extends the `Definition` protocol and adds behavior for SQLite scalar functions.
    ///
    /// Scalar functions take arguments and return a single value.
    public protocol Scalar: Definition {
        /// Invokes the scalar function with the given arguments.
        ///
        /// - Parameter args: The function arguments.
        /// - Returns: The result of the function execution, conforming to `SQLiteConvertible`.
        static func invoke(args: Arguments) throws -> SQLiteConvertible?
    }
}
