import Foundation
import SQLiteC

extension Function {
    /// The `Definition` protocol defines the common characteristics of SQLite user-defined functions.
    ///
    /// This protocol defines the basic attributes required for implementing SQLite user-defined functions,
    /// such as function name, number of arguments, and options.
    public protocol Definition {
        /// The name of the function.
        static var name: String { get }
        
        /// The number of arguments of the function.
        static var argc: Int32 { get }
        
        /// The options of the function.
        static var options: Options { get }
    }
}

extension Function.Definition {
    static var encoding: Function.Options {
        Function.Options(rawValue: SQLITE_UTF8)
    }
    
    static var opts: Int32 {
        var options = options
        options.insert(encoding)
        return options.rawValue
    }
}
