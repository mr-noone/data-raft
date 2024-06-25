import Foundation

/// A custom SQLite scalar function for performing regular expression matching (REGEXP) in SQLite queries.
///
/// This struct conforms to `Function.Scalar`, enabling it to define and register the `REGEXP` function with an SQLite connection.
///
/// Before using `SQLiteRegexp`, you must add it to your SQLite connection:
/// ```swift
/// let connection = try Connection(
///     path: dbFileURL.path,
///     options: [.create, .readwrite, .nomutex]
/// )
/// try connection.add(function: SQLiteRegexp.self)
/// ```
///
/// After adding `SQLiteRegexp` to your connection, you can use it in SQLite queries like this:
/// ```sql
/// -- Find rows where 'name' column matches the regular expression 'John.*'
/// SELECT * FROM users WHERE REGEXP('John.*', name);
/// ```
///
/// ```sql
/// -- Find rows where 'name' column starts with 'John'
/// SELECT * FROM users WHERE name REGEXP 'John.*';
/// ```
@available(iOS 16.0, *)
public struct SQLiteRegexp: Function.Scalar {
    /// Possible errors that can occur during the invocation of the `REGEXP` function.
    public enum Error: Swift.Error {
        /// Indicates that the arguments passed to the `REGEXP` function are incorrect.
        case argumentsWrong
        
        /// Indicates an error occurred during regular expression processing.
        case regexError(Swift.Error)
    }
    
    // MARK: - Properties
    
    /// The number of arguments expected by the `REGEXP` function, which is 2 (regex pattern and value to match).
    public static var argc: Int32 { 2 }
    
    /// The name of the SQLite scalar function, which is "REGEXP".
    public static var name: String { "REGEXP" }
    
    /// Options for the `REGEXP` function, including deterministic and innocuous behavior.
    public static var options: Function.Options {
        [.deterministic, .innocuous]
    }
    
    // MARK: - Methods
    
    /// Invokes the `REGEXP` function with the provided arguments.
    ///
    /// - Parameters:
    ///   - args: An array of `SQLiteConvertible` arguments, where the first argument is the regex pattern
    ///           and the second argument is the value to match against the regex pattern.
    /// - Returns: A boolean indicating whether the regex pattern matches the value.
    /// - Throws: `SQLiteRegexp.Error.argumentsWrong` if the arguments are not of the expected types.
    /// - Throws: `SQLiteRegexp.Error.regexError` if an error occurs during regular expression processing.
    public static func invoke(args: Function.Arguments) throws -> SQLiteConvertible? {
        guard let regex = args[0] as String?,
              let value = args[1] as String?
        else { throw Error.argumentsWrong }
        do {
            return try Regex(regex).wholeMatch(in: value) != nil
        } catch {
            throw Error.regexError(error)
        }
    }
}
