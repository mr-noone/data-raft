import Foundation

/// A collection of SQL statements parsed from a file.
///
/// This struct represents a collection of SQL statements extracted from a file.
/// It provides functionality to load SQL statements from a resource file,
/// remove comments and whitespace, and access individual statements in the collection.
///
/// To use `SQLScript`, you can initialize an instance by providing either the URL of the file
/// containing SQL statements or by specifying the name of the resource file along with the optional
/// file extension and bundle from which to load the file.
///
/// Once initialized, you can access individual SQL statements by index or iterate over them using `for...in` loops.
/// For example:
///
/// ```swift
/// // Load SQL script from a file named "sample_script.sql" in the main bundle.
/// if let sqlScript = try? SQLScript(byResource: "sample_script", extension: "sql") {
///     // Iterate over each SQL statement in the script.
///     for (index, statement) in sqlScript.enumerated() {
///         print("Statement \(index + 1):")
///         print(statement)
///         print("--------------------")
///     }
/// } else {
///     print("Failed to load SQL script.")
/// }
/// ```
///
/// In the above example:
/// - We attempt to initialize a `SQLScript` instance by loading SQL statements from a file named
///   "sample_script.sql" in the main bundle.
/// - If the initialization succeeds, we iterate over each SQL statement in the script using `enumerated()`
///   to get both the index and the statement itself.
/// - For each statement, we print its index, the statement itself, and a separator.
/// - If the initialization fails (e.g., due to the file not being found or an error occurred during parsing),
///   we print a failure message.
///
/// - Note: This struct assumes that SQL statements in the file are separated by semicolons (;)
///         and supports multi-line SQL statements.
/// - Note: The struct supports both single-line (`--`) and multi-line (`/* */`) comments in SQL files.
/// - Warning: This struct does not support nested block comments in SQL files.
///
/// Example SQL file content (`sample_script.sql`):
///
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
    
    // MARK: - Initialization
    
    /// Initializes a `SQLScript` instance by loading SQL statements from a file.
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
        let string = try String(contentsOf: url, encoding: .utf8)
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
