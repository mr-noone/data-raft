import Foundation

/// A collection of SQL statements parsed from a file or string.
///
/// This struct represents a collection of SQL statements extracted from a file or string input.
/// It provides functionality to load SQL statements, remove comments and whitespace,
/// and access individual statements in the collection.
///
/// ## Example Usage
///
/// To use `SQLScript`, you can initialize an instance by providing either the URL of a file
/// containing SQL statements or by directly passing a string containing SQL statements:
///
/// ```swift
/// // Load SQL script from a file named "sample_script.sql" in the main bundle.
/// do {
///     guard let sqlScript = try SQLScript(
///         byResource: "sample_script",
///         extension: "sql"
///     ) else {
///         throw NSError(domain: "SomeDomain", code: -1)
///     }
///     for (index, statement) in sqlScript.enumerated() {
///         print("Statement \(index + 1):")
///         print(statement)
///         print("--------------------")
///     }
/// } catch {
///     print(error)
/// }
/// ```
///
/// ```swift
/// // Initialize SQL script from a string directly.
/// do {
///     let sqlString = """
///     CREATE TABLE users (
///         id INTEGER PRIMARY KEY,
///         username TEXT NOT NULL,
///         email TEXT NOT NULL
///     );
///     INSERT INTO users (id, username, email)
///     VALUES (1, 'john_doe', 'john@example.com');
///     """
///     let sqlScript = try SQLScript(string: sqlString)
/// } catch {
///     print(error)
/// }
/// ```
///
/// - Note: Ensure that the file or string input follows the expected format
///         (semicolons between statements, correct comment syntax).
/// - Note: Error handling is critical, especially during initialization and parsing stages.
///
/// ## File Format
///
/// - This struct assumes that SQL statements in a file or string are separated by semicolons (`;`)
///   and supports multi-line SQL statements.
/// - It supports both single-line (`--`) and multi-line (`/* */`) comments in SQL files or strings.
///
/// - Warning: Nested block comments in SQL files or strings are not supported.
///
/// Example SQL file content (`sample_script.sql`):
/// ```SQL
/// -- This is a single-line comment.
/// CREATE TABLE users (
///     id INTEGER PRIMARY KEY,
///     username TEXT NOT NULL,
///     email TEXT NOT NULL
/// );
///
/// /*
///    This is a multi-line comment.
///    It spans multiple lines and can contain any text.
/// */
/// INSERT INTO users (id, username, email)
/// VALUES
///     (1, 'john_doe', 'john@example.com'), -- Inserting John Doe
///     (2, 'jane_doe', 'jane@example.com'); -- Inserting Jane Doe
/// ```
public struct SQLScript: Collection {
    /// The type used to represent the index of a SQL statement in the collection.
    public typealias Index = Int
    
    /// The type of elements stored in the collection, which are SQL statements represented as strings.
    public typealias Element = String
    
    // MARK: - Properties
    
    /// The array containing the SQL statements.
    private var elements: [Element]
    
    /// The starting index of the collection.
    public var startIndex: Index {
        elements.startIndex
    }
    
    /// The ending index of the collection.
    public var endIndex: Index {
        elements.endIndex
    }
    
    /// The number of SQL statements in the collection.
    public var count: Int {
        elements.count
    }
    
    /// A boolean value indicating whether the collection is empty.
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    // MARK: - Inits
    
    /// Initializes a `SQLScript` instance by loading SQL statements from a resource file.
    ///
    /// - Parameters:
    ///   - name: The name of the resource file containing SQL statements.
    ///   - extension: The file extension of the resource file. Default is `nil`.
    ///   - bundle: The bundle from which to load the resource file. Default is the main bundle.
    /// - Throws: An error if the file cannot be loaded or parsed.
    public init?(
        byResource name: String?,
        extension: String? = nil,
        in bundle: Bundle = .main
    ) throws {
        guard let url = bundle.url(
            forResource: name,
            withExtension: `extension`
        ) else { return nil }
        try self.init(contentsOf: url)
    }
    
    /// Initializes a `SQLScript` instance by loading SQL statements from a file.
    ///
    /// - Parameter url: The URL of the file containing SQL statements.
    /// - Throws: An error if the file cannot be loaded or parsed.
    public init(contentsOf url: URL) throws {
        try self.init(string: .init(contentsOf: url, encoding: .utf8))
    }
    
    /// Initializes a `SQLScript` instance by parsing SQL statements from a string.
    ///
    /// - Parameter string: The string containing SQL statements.
    /// - Throws: An error if the string cannot be parsed correctly.
    public init(string: String) throws {
        let comments = "--.*|\\/\\*(?:.|\\n)*?\\*\\/"
        let emptyLines = "^\\s\\n|\\s+(?=(?:\\n|$))"
        let statements = "\\w(?:.|\\n)*?(?:(?=;|\\z))"
        
        #if os(iOS) || os(macOS)
        if #available(macOS 13.0, iOS 16.0, *) {
            elements = try string
                .replacing(Regex(comments), with: "")
                .replacing(Regex(emptyLines).anchorsMatchLineEndings(), with: "")
                .matches(of: Regex(statements, as: Substring.self))
                .map { String($0.output) }
        } else {
            let string = string
                .replacingOccurrences(of: comments, with: "", options: .regularExpression)
                .replacingOccurrences(of: emptyLines, with: "", options: .regularExpression)
            elements = try NSRegularExpression(pattern: statements)
                .matches(in: string, range: NSRange(string.startIndex..., in: string))
                .map { (string as NSString).substring(with: $0.range) }
        }
        #else
        elements = try string
            .replacing(Regex(comments), with: "")
            .replacing(Regex(emptyLines).anchorsMatchLineEndings(), with: "")
            .matches(of: Regex(statements, as: Substring.self))
            .map { String($0.output) }
        #endif
    }
    
    // MARK: - Subscripts
    
    /// Accesses the SQL statement at the specified index.
    ///
    /// - Parameter index: The index of the SQL statement to access.
    public subscript(index: Index) -> Element {
        elements[index]
    }
    
    // MARK: - Methods
    
    /// Returns the index after the specified index.
    ///
    /// - Parameter i: The index to advance from.
    /// - Returns: The index immediately after the specified index.
    public func index(after i: Index) -> Index {
        elements.index(after: i)
    }
}
