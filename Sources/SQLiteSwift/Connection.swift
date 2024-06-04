import Foundation
import SQLiteC

/// A value representing a static destructor for SQLite.
let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)

/// A value representing a transient destructor for SQLite.
let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)

/// Callback function for tracing SQL statements.
///
/// This function is used as a callback for tracing SQL statements executed by SQLite.
/// It extracts the SQL statement being executed in both unexpanded and expanded
/// forms and notifies the connection delegate if available.
///
/// - Parameters:
///   - flag: The tracing flag.
///   - ctx: A context pointer.
///   - p: A pointer to the SQLite statement being executed.
///   - x: A pointer to additional information.
/// - Returns: An SQLite result code.
private func traceCallback(
    _ flag: UInt32,
    _ ctx: UnsafeMutableRawPointer?,
    _ p: UnsafeMutableRawPointer?,
    _ x: UnsafeMutableRawPointer?
) -> Int32 {
    guard let ctx = ctx else { return SQLITE_OK }
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    
    if let delegate = connection.delegate {
        guard let stmt = OpaquePointer(p),
              let pSql = sqlite3_expanded_sql(stmt),
              let xSql = x?.assumingMemoryBound(to: CChar.self)
        else { return SQLITE_OK }
        
        let pSqlString = String(cString: pSql)
        let xSqlString = String(cString: xSql)
        let trace = (xSqlString, pSqlString)
        delegate.connection(connection, trace: trace)
    }
    
    return SQLITE_OK
}

/// Callback function for update notifications.
///
/// This function is used as a callback for update notifications triggered by SQLite.
/// It notifies the connection delegate if available, providing information about the type of
/// update action that occurred, including the database name, table name, and row ID.
///
/// - Parameters:
///   - ctx: A context pointer.
///   - action: The type of update action that occurred.
///   - dName: The name of the affected database.
///   - tName: The name of the affected table.
///   - rowID: The row ID of the affected row.
private func updateHookCallback(
    _ ctx: UnsafeMutableRawPointer?,
    _ action: Int32,
    _ dName: UnsafePointer<CChar>?,
    _ tName: UnsafePointer<CChar>?,
    _ rowID: sqlite3_int64
) {
    guard let ctx = ctx else { return }
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    
    if let delegate = connection.delegate {
        guard let dName = dName, let tName = tName else { return }
        
        let dbName = String(cString: dName)
        let tableName = String(cString: tName)
        let updateAction: SQLiteAction
        
        switch action {
        case SQLITE_INSERT:
            updateAction = .insert(db: dbName, table: tableName, rowID: rowID)
        case SQLITE_UPDATE:
            updateAction = .update(db: dbName, table: tableName, rowID: rowID)
        case SQLITE_DELETE:
            updateAction = .delete(db: dbName, table: tableName, rowID: rowID)
        default:
            return
        }
        
        delegate.connection(connection, didUpdate: updateAction)
    }
}

/// Callback function for committing transactions.
///
/// This function is used as a callback for committing transactions in SQLite.
/// It notifies the connection delegate if available that a transaction has been successfully committed.
/// If the delegate throws an error during the commit process, the COMMIT operation is converted into a ROLLBACK.
///
/// - Parameter ctx: A context pointer.
/// - Returns: An SQLite result code indicating the status of the commit operation.
private func commitHookCallback(_ ctx: UnsafeMutableRawPointer?) -> Int32 {
    do {
        guard let ctx = ctx else { return SQLITE_OK }
        let connection = Unmanaged<Connection>
            .fromOpaque(ctx)
            .takeUnretainedValue()
        if let delegate = connection.delegate {
            try delegate.connectionDidCommit(connection)
        }
        return SQLITE_OK
    } catch {
        return SQLITE_ERROR
    }
}

/// Callback function for rolling back transactions.
///
/// This function is used as a callback for rolling back transactions in SQLite.
/// It notifies the connection delegate if available that a transaction has been rolled back.
///
/// - Parameter ctx: A context pointer.
private func rollbackHookCallback(_ ctx: UnsafeMutableRawPointer?) {
    guard let ctx = ctx else { return }
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    if let delegate = connection.delegate {
        delegate.connectionDidRollback(connection)
    }
}

/// The `Connection` class represents an object-oriented connection to a SQLite database.
///
/// You can use this class to establish a connection to a SQLite database with the specified options.
/// The class provides methods for executing SQL statements, managing transactions,
/// and observing database events through a delegate.
///
/// ## Topics
///
/// ### Subtypes
///
/// - ``Options``
/// - ``Location``
///
/// ### Initializers
///
/// - ``init(location:options:)``
/// - ``init(path:options:)``
///
/// ### Instance Properties
///
/// - ``delegate``
/// - ``busyTimeout``
/// - ``isAutocommit``
/// - ``isReadonly``
///
/// ### Initialize SQLite Library
///
/// - ``initialize()``
/// - ``shutdown()``
///
/// ### Manage Custom SQL Functions
///
/// - ``add(function:)-5c0qi``
/// - ``add(function:)-5c09h``
/// - ``remove(function:)``
///
/// ### Preparing SQL Statement
///
/// - ``prepare(sql:options:)``
///
/// ### Executing Prepared Statements
///
/// - ``execute(sql:args:)-3m0g2``
/// - ``execute(sql:args:)-7z488``
/// - ``execute(sql:args:)-5wmqj``
/// - ``execute(sql:args:)-2h5tu``
///
/// ### Executing SQL Queries
///
/// - ``execute(sql:args:)-4g5v8``
/// - ``execute(sql:args:)-5kkea``
/// - ``execute(sql:args:)-5vpki``
/// - ``execute(sql:args:)-86eyf``
///
/// ### Executing SQL Script
///
/// - ``execute(sql:)``
///
/// ### Executing PRAGMA Queries
///
/// - ``foreignKeys``
/// - ``journalMode``
/// - ``synchronous``
/// - ``userVersion``
///
/// - ``get(pragma:)``
/// - ``set(pragma:value:)``
///
/// ### Transaction Methods
///
/// - ``beginTransaction(_:)``
/// - ``commitTransaction()``
/// - ``rollbackTransaction()``
public final class Connection {
    // MARK: - Public properties
    
    /// A weak reference to an object conforming to the `ConnectionDelegate` protocol.
    ///
    /// The delegate object is responsible for implementing methods defined in the `ConnectionDelegate`
    /// protocol to handle various events and actions related to the SQLite database connection.
    public weak var delegate: ConnectionDelegate?
    
    /// Indicates whether the SQLite database connection is in autocommit mode.
    ///
    /// Autocommit mode automatically commits each SQL transaction immediately after it is executed.
    /// If autocommit mode is enabled, this property returns `true`; otherwise, it returns `false`.
    ///
    /// - Note: Autocommit mode can be enabled or disabled using specific SQL commands or through the SQLite API.
    ///         By default, SQLite operates in autocommit mode unless explicitly configured otherwise.
    ///
    /// Example usage:
    /// ```swift
    /// let connection = try Connection(path: "~/example.db", options: .readwrite)
    /// print(connection.isAutocommit) // true
    /// ```
    public var isAutocommit: Bool {
        sqlite3_get_autocommit(connection) != 0
    }
    
    /// Indicates whether the SQLite database connection is in read-only mode.
    ///
    /// If the connection is in read-only mode, this property returns `true`; otherwise, it returns `false`.
    /// A read-only connection allows SELECT statements to be executed but prevents any data modifications.
    ///
    /// - Note: The read-only status is determined based on the file system permissions of the SQLite database file.
    ///         If the database file is read-only at the file system level, the connection will be considered read-only.
    ///
    /// Example usage:
    /// ```swift
    /// let connection = try Connection(path: "~/example.db", options: .readonly)
    /// print(connection.isReadonly) // true
    /// ```
    public var isReadonly: Bool {
        sqlite3_db_readonly(connection, location.path) == 1
    }
    
    /// The busy timeout value for the SQLite connection.
    ///
    /// If SQLite receives a busy signal when attempting to access a database that is locked by another process,
    /// it will wait for the specified amount of time before returning an error.
    /// Setting this property allows you to control the duration SQLite waits before timing out.
    ///
    /// The default value is `0`, indicating no busy timeout is set.
    /// A value of `0` means that SQLite will return immediately if it encounters a locked database.
    public var busyTimeout: Int32 = 0 {
        didSet { sqlite3_busy_timeout(connection, busyTimeout) }
    }
    
    /// Represents the foreign keys setting for the SQLite database.
    ///
    /// Accessing this property reads or sets the foreign keys enforcement status for the SQLite database.
    /// Enabling foreign keys ensures referential integrity between tables.
    public var foreignKeys: Bool {
        get { try! get(pragma: .foreignKeys) ?? false }
        set { try! set(pragma: .foreignKeys, value: newValue) }
    }
    
    /// Represents the journal mode setting for the SQLite database.
    ///
    /// Accessing this property reads or sets the journal mode for the SQLite database.
    /// The journal mode determines how changes are recorded in the database.
    public var journalMode: SQLiteJournalMode {
        get { try! get(pragma: .journalMode) ?? .off }
        set { try! set(pragma: .journalMode, value: newValue) }
    }
    
    /// Represents the synchronous setting for the SQLite database.
    ///
    /// Accessing this property reads or sets the synchronous mode for the SQLite database.
    /// The synchronous mode determines how transactions are synchronized to disk.
    public var synchronous: SQLiteSynchronous {
        get { try! get(pragma: .synchronous) ?? .off }
        set { try! set(pragma: .synchronous, value: newValue) }
    }
    
    /// Represents the user version number of the SQLite database.
    ///
    /// Accessing this property reads or sets the user version number associated with the SQLite database.
    /// The user version number can be used to track and manage database schema versions.
    public var userVersion: Int32 {
        get { try! get(pragma: .userVersion) ?? 0 }
        set { try! set(pragma: .userVersion, value: newValue) }
    }
    
    // MARK: - Private properties
    
    /// The underlying SQLite connection object.
    private let connection: OpaquePointer
    
    /// The location of the SQLite database.
    private let location: Location
    
    /// A set containing user-defined SQLite functions.
    ///
    /// This set stores instances of the `Function` class, representing user-defined
    /// SQLite functions registered in the SQLite database connection.
    private var functions = Set<Function>()
    
    // MARK: - Inits
    
    /// Initializes and opens a connection to a SQLite database.
    ///
    /// - Parameters:
    ///   - location: The location of the SQLite database.
    ///   - options: Options for controlling the connection to the SQLite database.
    /// - Throws: An `SQLiteError` if the connection cannot be established.
    ///
    /// Before opening the connection, if the location is a file-based database and the path is not empty,
    /// the method attempts to create the directory containing the database file if it does not exist.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let connection = try Connection(
    ///         location: .file(path: "~/example.db"),
    ///         options: .readwrite
    ///     )
    ///     // Use the connection to execute queries
    /// } catch {
    ///     print("Error establishing connection: \(error)")
    /// }
    /// ```
    public init(location: Location, options: Options) throws {
        if case let Location.file(path) = location, !path.isEmpty {
            try FileManager.default.createDirectory(
                at: URL(fileURLWithPath: path).deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        }
        
        var connection: OpaquePointer! = nil
        let status = sqlite3_open_v2(location.path, &connection, options.rawValue, nil)
        
        if status == SQLITE_OK, let connection = connection {
            self.connection = connection
            self.location = location
            
            let ctx = Unmanaged.passUnretained(self).toOpaque()
            sqlite3_trace_v2(connection, UInt32(SQLITE_TRACE_STMT), traceCallback(_:_:_:_:), ctx)
            sqlite3_update_hook(connection, updateHookCallback(_:_:_:_:_:), ctx)
            sqlite3_commit_hook(connection, commitHookCallback(_:), ctx)
            sqlite3_rollback_hook(connection, rollbackHookCallback(_:), ctx)
        } else {
            let error = SQLiteError(connection)
            sqlite3_close_v2(connection)
            throw error
        }
    }
    
    /// Convenient initializer for creating a connection to a file-based SQLite database.
    ///
    /// - Parameters:
    ///   - path: The path to the file-based SQLite database.
    ///   - options: Options for controlling the connection to the SQLite database.
    /// - Throws: An `SQLiteError` if the connection cannot be established.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let connection = try Connection(
    ///         path: "~/example.db",
    ///         options: .readwrite
    ///     )
    ///     // Use the connection to execute queries
    /// } catch {
    ///     print("Error establishing connection: \(error)")
    /// }
    /// ```
    public convenience init(path: String, options: Options) throws {
        try self.init(location: .file(path: path), options: options)
    }
    
    deinit {
        sqlite3_close_v2(connection)
    }
    
    // MARK: - Methods
    
    /// Initializes the SQLite library.
    ///
    /// This method initializes the SQLite library, allowing the application to use SQLite functions and APIs.
    /// It must be called before any other SQLite function is used. Note that SQLite automatically initializes itself
    /// the first time it is used, so calling this function explicitly may not be necessary in many cases.
    ///
    /// - Throws: An `SQLiteError` if the initialization of the SQLite library fails.
    public static func initialize() throws {
        let status = sqlite3_initialize()
        if status != SQLITE_OK {
            throw SQLiteError(code: status, mesg: "")
        }
    }
    
    /// Shuts down the SQLite library.
    ///
    /// This method shuts down the SQLite library. It should only be called from a single thread, and all open database connections
    /// must be closed and all other SQLite resources must be deallocated prior to invoking this method.
    ///
    /// - Throws: An `SQLiteError` if shutting down the SQLite library fails.
    public static func shutdown() throws {
        let status = sqlite3_shutdown()
        if status != SQLITE_OK {
            throw SQLiteError(code: status, mesg: "")
        }
    }
    
    /// Creates and adds a new scalar function to the SQLite connection.
    ///
    /// This method creates an instance of the `Function` class for the specified scalar function definition
    /// type and inserts it into the set of user-defined SQLite functions associated with the connection.
    ///
    /// - Parameter definition: The type of scalar function definition.
    /// - Throws: An `SQLiteError` if the creation of the function fails.
    public func add(function definition: Function.Scalar.Type) throws {
        try functions.insert(Function(db: connection, definition: definition))
    }
    
    /// Creates and adds a new aggregate function to the SQLite connection.
    ///
    /// - Parameter definition: The type of aggregate function definition.
    /// - Throws: An `SQLiteError` if the creation of the function fails.
    public func add(function definition: Function.Aggregate.Type) throws {
        guard !functions.contains(where: { $0.contains(definition) }) else { return }
        try functions.insert(Function(db: connection, definition: definition))
    }
    
    /// Removes a user-defined function from the SQLite connection.
    ///
    /// - Parameter definition: The type of function definition to remove.
    public func remove(function definition: Function.Definition.Type) {
        functions.removeAll { $0.contains(definition) }
    }
    
    /// Prepares a new SQLite statement with the provided SQL query and options.
    ///
    /// This function prepares a new SQLite statement with the given SQL query and options,
    /// using the provided SQLite database connection.
    ///
    /// - Parameters:
    ///   - query: The SQL query string to prepare.
    ///   - options: Options for preparing the SQL statement.
    /// - Returns: A prepared `Statement` instance ready for execution.
    /// - Throws: An `SQLiteError` if the statement cannot be prepared.
    public func prepare(
        sql query: String,
        options: Statement.Options = []
    ) throws -> Statement {
        try .init(db: connection, sql: query, options: options)
    }
    
    /// Executes an SQLite statement with optional arguments.
    ///
    /// This function executes the provided SQLite statement, optionally binding
    /// arguments to the statement before execution. It steps through the statement
    /// until no more rows are available, collecting the resulting rows into an array
    /// of `SQLiteRow`.
    ///
    /// - Parameters:
    ///   - statement: The `Statement` instance to execute.
    ///   - args: An optional array of `Arguments` to bind to the statement.
    /// - Returns: An array of `SQLiteRow` representing the result set.
    /// - Throws: An `SQLiteError` if there is an issue during statement execution.
    @discardableResult
    public func execute(
        sql statement: Statement,
        args: [Statement.Arguments]? = nil
    ) throws -> [SQLiteRow] {
        var result = [SQLiteRow]()
        var argIndex = 0
        
        repeat {
            if let args, args.count > argIndex {
                try statement.bind(args[argIndex])
            }
            while try statement.step() {
                result.append(statement.rowValue())
            }
            try statement.clearBindings()
            try statement.reset()
            argIndex += 1
        } while argIndex < args?.count ?? 0
        
        return result
    }
    
    /// Executes an SQLite statement with optional arguments and returns a single row.
    ///
    /// This function executes the provided SQLite statement, optionally binding
    /// arguments to the statement before execution. It retrieves the first row
    /// of the result set and returns it as a single `SQLiteRow` instance.
    ///
    /// - Parameters:
    ///   - statement: The `Statement` instance to execute.
    ///   - args: An optional `Arguments` to bind to the statement.
    /// - Returns: A single `SQLiteRow` representing the first row of the result set,
    ///   or `nil` if there are no rows.
    /// - Throws: An `SQLiteError` if there is an issue during statement execution.
    @discardableResult
    public func execute(
        sql statement: Statement,
        args: Statement.Arguments? = nil
    ) throws -> SQLiteRow? {
        var result: SQLiteRow?
        if let args = args {
            try statement.bind(args)
        }
        if try statement.step() {
            result = statement.rowValue()
        }
        try statement.clearBindings()
        try statement.reset()
        return result
    }
    
    /// Executes an SQLite statement with a single set of arguments and returns the result set.
    ///
    /// This function executes the provided SQLite statement, binding the specified
    /// arguments to the statement before execution. It returns an array of `SQLiteRow`
    /// representing the result set.
    ///
    /// - Parameters:
    ///   - statement: The `Statement` instance to execute.
    ///   - args: The `Arguments` to bind to the statement.
    /// - Returns: An array of `SQLiteRow` representing the result set.
    /// - Throws: An `SQLiteError` if there is an issue during statement execution.
    @discardableResult
    public func execute(
        sql statement: Statement,
        args: Statement.Arguments
    ) throws -> [SQLiteRow] {
        try execute(sql: statement, args: [args])
    }
    
    /// Executes an SQLite statement with optional arguments and returns the result as a single value.
    ///
    /// This function executes the provided SQLite statement, optionally binding
    /// arguments to the statement before execution. It retrieves the result as a single
    /// value of type `T`, which must conform to the `SQLiteConvertible` protocol.
    ///
    /// - Parameters:
    ///   - statement: The `Statement` instance to execute.
    ///   - args: An optional `Arguments` to bind to the statement.
    /// - Returns: A single value of type `T`, representing the result of the query, or `nil` if the result set is empty.
    /// - Throws: An `SQLiteError` if there is an issue during statement execution.
    @discardableResult
    public func execute<T>(
        sql statement: Statement,
        args: Statement.Arguments? = nil
    ) throws -> T? where T: SQLiteConvertible {
        let row = try execute(sql: statement, args: args)
        return T(row?.first?.value ?? .null)
    }
    
    /// Executes an SQL query with optional arguments and returns the result set.
    ///
    /// This function prepares and executes an SQL query using the provided query string
    /// and optional arguments. It returns an array of `SQLiteRow` representing the result set.
    ///
    /// - Parameters:
    ///   - query: The SQL query string to execute.
    ///   - args: An optional array of `Arguments` to bind to the query.
    /// - Returns: An array of `SQLiteRow` representing the result set.
    /// - Throws: An `SQLiteError` if there is an issue during query execution.
    @discardableResult
    public func execute(
        sql query: String,
        args: [Statement.Arguments]? = nil
    ) throws -> [SQLiteRow] {
        let stmt = try prepare(sql: query)
        return try execute(sql: stmt, args: args)
    }
    
    /// Executes an SQL query with optional arguments and returns a single row.
    ///
    /// This function prepares and executes an SQL query using the provided query string
    /// and optional arguments. It returns a single `SQLiteRow` representing the first row
    /// of the result set, or `nil` if the result set is empty.
    ///
    /// - Parameters:
    ///   - query: The SQL query string to execute.
    ///   - args: An optional `Arguments` to bind to the query.
    /// - Returns: A single `SQLiteRow` representing the first row of the result set,
    ///   or `nil` if there are no rows.
    /// - Throws: An `SQLiteError` if there is an issue during query execution.
    @discardableResult
    public func execute(
        sql query: String,
        args: Statement.Arguments? = nil
    ) throws -> SQLiteRow? {
        let stmt = try prepare(sql: query)
        return try execute(sql: stmt, args: args)
    }
    
    /// Executes an SQL query with a single set of arguments and returns the result set.
    ///
    /// This function prepares and executes an SQL query using the provided query string
    /// and a single set of arguments. It returns an array of `SQLiteRow` representing
    /// the result set.
    ///
    /// - Parameters:
    ///   - query: The SQL query string to execute.
    ///   - args: The `Arguments` to bind to the query.
    /// - Returns: An array of `SQLiteRow` representing the result set.
    /// - Throws: An `SQLiteError` if there is an issue during query execution.
    @discardableResult
    public func execute(
        sql query: String,
        args: Statement.Arguments
    ) throws -> [SQLiteRow] {
        let stmt = try prepare(sql: query)
        return try execute(sql: stmt, args: args)
    }
    
    /// Executes an SQL query with optional arguments and returns the result as a single value.
    ///
    /// This function prepares and executes an SQL query using the provided query string
    /// and optional arguments. It returns the result as a single value of type `T`,
    /// which must conform to the `SQLiteConvertible` protocol.
    ///
    /// - Parameters:
    ///   - query: The SQL query string to execute.
    ///   - args: An optional array of `Arguments` to bind to the query.
    /// - Returns: A single value of type `T`, representing the result of the query,
    ///   or `nil` if the result set is empty.
    /// - Throws: An `SQLiteError` if there is an issue during query execution.
    @discardableResult
    public func execute<T>(
        sql query: String,
        args: Statement.Arguments? = nil
    ) throws -> T? where T: SQLiteConvertible {
        let stmt = try prepare(sql: query)
        return try execute(sql: stmt, args: args)
    }
    
    /// Executes SQL statements provided in a `SQLScript` instance.
    ///
    /// This function iterates over each SQL statement in the provided `SQLScript` instance
    /// and executes them sequentially.
    ///
    /// - Parameter script: The `SQLScript` instance containing SQL statements to execute.
    /// - Throws: An `SQLiteError` if there is an issue during statement execution.
    public func execute(sql script: SQLScript) throws {
        try script.forEach {
            let stmt = try prepare(sql: $0)
            try execute(sql: stmt, args: [])
        }
    }
    
    /// Retrieves the value of the specified SQLite pragma.
    ///
    /// This function executes a PRAGMA query to retrieve the value of the specified pragma.
    ///
    /// - Parameter pragma: The SQLite pragma to retrieve.
    /// - Returns: The value of the pragma, converted to the specified type `T`.
    /// - Throws: An `SQLiteError` if there is an issue during the pragma query execution.
    public func get<T>(pragma: SQLitePragma) throws -> T? where T: SQLiteConvertible {
        try execute(sql: "PRAGMA \(pragma)")
    }
    
    /// Sets the value of the specified SQLite pragma.
    ///
    /// This function executes a PRAGMA query to set the value of the specified pragma.
    ///
    /// - Parameters:
    ///   - pragma: The SQLite pragma to set.
    ///   - value: The value to set for the pragma.
    /// - Returns: The value that was set for the pragma, converted to the specified type `T`.
    /// - Throws: An `SQLiteError` if there is an issue during the pragma query execution.
    @discardableResult
    public func set<T>(pragma: SQLitePragma, value: T) throws -> T? where T: SQLiteConvertible {
        try execute(sql: "PRAGMA \(pragma) = \(value.sqliteLiteral)")
    }
    
    /// Begins a transaction with the specified transaction type.
    ///
    /// - Parameter type: The type of transaction to begin. Defaults to deferred.
    /// - Throws: An `SQLiteError` if the transaction cannot be initiated.
    public func beginTransaction(_ type: SQLiteTransactionType = .deferred) throws {
        try execute(sql: "BEGIN \(type) TRANSACTION", args: [])
    }
    
    /// Commits the current transaction.
    ///
    /// - Throws: An `SQLiteError` if the transaction cannot be committed.
    public func commitTransaction() throws {
        try execute(sql: "COMMIT TRANSACTION", args: [])
    }
    
    /// Rolls back the current transaction.
    ///
    /// - Throws: An `SQLiteError` if the transaction cannot be rolled back.
    public func rollbackTransaction() throws {
        try execute(sql: "ROLLBACK TRANSACTION", args: [])
    }
}
