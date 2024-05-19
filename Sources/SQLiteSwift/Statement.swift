import Foundation
import SQLiteC

/// Binds a string value to the parameter at the specified index in the prepared SQL statement.
///
/// - Parameters:
///   - stmt: The opaque pointer to the SQLite statement.
///   - index: The index of the parameter.
///   - string: The string value to bind.
/// - Returns: A result code indicating success or failure.
func sqlite3_bind_text(_ stmt: OpaquePointer!, _ index: Int32, _ string: String) -> Int32 {
    sqlite3_bind_text(stmt, index, string, -1, SQLITE_TRANSIENT)
}

/// Binds a Data object to the parameter at the specified index in the prepared SQL statement.
///
/// - Parameters:
///   - stmt: The opaque pointer to the SQLite statement.
///   - index: The index of the parameter.
///   - data: The Data object to bind.
/// - Returns: A result code indicating success or failure.
func sqlite3_bind_blob(_ stmt: OpaquePointer!, _ index: Int32, _ data: Data) -> Int32 {
    data.withUnsafeBytes {
        sqlite3_bind_blob(stmt, index, $0.baseAddress, Int32($0.count), SQLITE_TRANSIENT)
    }
}

/// Retrieves the text value from the specified column in the current row of the SQLite result set.
///
/// - Parameters:
///   - stmt: The opaque pointer to the SQLite statement.
///   - iCol: The index of the column.
/// - Returns: The text value from the column, or an empty string if the value is NULL.
func sqlite3_column_text(_ stmt: OpaquePointer!, _ iCol: Int32) -> String {
    String(cString: SQLiteC.sqlite3_column_text(stmt, iCol))
}

/// Retrieves the data from the specified column in the current row of the SQLite result set.
///
/// - Parameters:
///   - stmt: The opaque pointer to the SQLite statement.
///   - iCol: The index of the column.
/// - Returns: The data from the column, or an empty Data object if the value is NULL.
func sqlite3_column_blob(_ stmt: OpaquePointer!, _ iCol: Int32) -> Data {
    Data(
        bytes: sqlite3_column_blob(stmt, iCol),
        count: Int(sqlite3_column_bytes(stmt, iCol))
    )
}

/// The `Statement` class represents a prepared SQL statement in SQLite.
///
/// ## Topics
///
/// ### Subtypes
///
/// - ``Options``
///
/// ### Binding Parameters
///
/// - ``bindParameterCount()``
/// - ``bind(parameterIndexBy:)-3u2n7``
/// - ``bind(parameterIndexBy:)-3b92l``
/// - ``bind(parameterNameBy:)``
/// - ``bind(nullAt:)``
/// - ``bind(_:at:)-9nhpf``
/// - ``bind(_:at:)-8owa4``
/// - ``bind(_:at:)-5fdre``
/// - ``bind(_:)``
/// - ``clearBindings()``
///
/// ### Getting Results
///
/// - ``columnCount()``
/// - ``columnType(at:)``
/// - ``columnName(at:)``
/// - ``columnValue(at:)-4zsq3``
/// - ``columnValue(at:)-6nclp``
/// - ``rowValue()``
///
/// ### Evaluating
///
/// - ``step()``
/// - ``reset()``
///
/// ### Hashing
///
/// - ``hash(into:)``
public final class Statement: Equatable, Hashable {
    // MARK: - Private properties
    
    /// The opaque pointer to the SQLite statement.
    private let statement: OpaquePointer
    
    /// The opaque pointer to the SQLite database connection.
    private let connection: OpaquePointer
    
    // MARK: - Inits
    
    /// Initializes a new SQLite statement with the provided database connection, SQL query, and options.
    ///
    /// - Parameters:
    ///   - connection: The opaque pointer to the SQLite database connection.
    ///   - query: The SQL query string.
    ///   - options: Options for preparing the SQL statement.
    /// - Throws: An `SQLiteError` if the statement cannot be prepared.
    init(db connection: OpaquePointer, sql query: String, options: Options) throws {
        var statement: OpaquePointer! = nil
        let status = sqlite3_prepare_v3(connection, query, -1, options.rawValue, &statement, nil)
        
        if status == SQLITE_OK, let statement {
            self.statement = statement
            self.connection = connection
        } else {
            sqlite3_finalize(statement)
            throw SQLiteError(connection)
        }
    }
    
    deinit {
        sqlite3_finalize(statement)
    }
    
    // MARK: - Methods
    
    /// Returns the number of parameters in the prepared SQL statement.
    ///
    /// - Returns: The number of parameters.
    public func bindParameterCount() -> Int32 {
        sqlite3_bind_parameter_count(statement)
    }
    
    /// Returns the index of the parameter with the given name in the prepared SQL statement.
    ///
    /// - Parameter name: The name of the parameter.
    /// - Returns: The index of the parameter, or 0 if not found.
    public func bind(parameterIndexBy name: String) -> Int32 {
        sqlite3_bind_parameter_index(statement, name)
    }
    
    /// Returns the parameter index for the given token in the prepared SQL statement.
    ///
    /// This method translates the token representing either an indexed or named parameter from the
    /// `SQLiteArguments.Token` enumeration into the corresponding index in the prepared SQL statement.
    ///
    /// If the token is indexed, the method directly returns the index.
    /// If the token is named, the method delegates the retrieval of the index to the `bind(parameterIndexBy:)`
    /// method, using the name extracted from the token.
    ///
    /// - Parameter token: The token representing either an indexed or named parameter.
    /// - Returns: The index of the parameter in the prepared SQL statement.
    public func bind(parameterIndexBy token: SQLiteArguments.Token) -> Int32 {
        switch token {
        case .indexed(let index):
            return Int32(index)
        case .named(let name):
            return bind(parameterIndexBy: name)
        }
    }
    
    /// Returns the name of the parameter at the given index in the prepared SQL statement.
    ///
    /// - Parameter index: The index of the parameter.
    /// - Returns: The name of the parameter, or nil if not found.
    public func bind(parameterNameBy index: Int32) -> String? {
        guard let cString = sqlite3_bind_parameter_name(statement, index) else {
            return nil
        }
        return String(cString: cString)
    }
    
    /// Binds a NULL value to the parameter at the specified index in the prepared SQL statement.
    ///
    /// - Parameter index: The index of the parameter.
    /// - Throws: An `SQLiteError` if the value cannot be bound.
    public func bind(nullAt index: Int32) throws {
        if sqlite3_bind_null(statement, index) != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    /// Binds an `SQLiteValue` to the parameter at the specified index in the prepared SQL statement.
    ///
    /// - Parameters:
    ///   - value: The `SQLiteValue` to bind.
    ///   - index: The index of the parameter.
    /// - Throws: An `SQLiteError` if the value cannot be bound.
    public func bind(_ value: SQLiteValue, at index: Int32) throws {
        var status: Int32
        switch value {
        case .int(let value):   status = sqlite3_bind_int64(statement, index, value)
        case .real(let value):  status = sqlite3_bind_double(statement, index, value)
        case .text(let value):  status = sqlite3_bind_text(statement, index, value)
        case .blob(let value):  status = sqlite3_bind_blob(statement, index, value)
        case .null:             status = sqlite3_bind_null(statement, index)
        }
        if status != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    /// Binds an SQLite value to the parameter in the prepared SQL statement based on the provided token.
    ///
    /// This method binds the specified SQLite value to the parameter in the prepared SQL statement.
    /// It uses the provided token, which represents either an indexed or named parameter from the
    /// `SQLiteArguments.Token` enumeration, to determine the parameter's index.
    ///
    /// The method first retrieves the index using the `bind(parameterIndexBy:)` method with the provided token.
    /// Then, it delegates the actual binding operation to the `bind(_:at:)` method, passing the retrieved
    /// index and the SQLite value.
    ///
    /// - Parameters:
    ///   - value: The SQLite value to bind to the parameter.
    ///   - token: The token representing either an indexed or named parameter.
    /// - Throws: An `SQLiteError` if the value cannot be bound to the parameter.
    public func bind(_ value: SQLiteValue, at token: SQLiteArguments.Token) throws {
        try bind(value, at: bind(parameterIndexBy: token))
    }
    
    /// Binds a value conforming to the `SQLiteBindable` protocol to the parameter at the specified index in the prepared SQL statement.
    ///
    /// - Parameters:
    ///   - value: The value to bind.
    ///   - index: The index of the parameter.
    /// - Throws: An `SQLiteError` if the value cannot be bound.
    public func bind<T: SQLiteBindable>(_ value: T, at index: Int32) throws {
        try bind(value.sqliteValue, at: index)
    }
    
    /// Binds values from the provided SQLiteArguments instance to parameters in the prepared SQL statement.
    ///
    /// This method iterates over the tokens and corresponding values in the given SQLiteArguments instance.
    /// For each token-value pair, it attempts to bind the value to the parameter in the prepared SQL statement.
    /// The binding operation is performed using the `bind(_:at:)` method, passing the token to determine
    /// the parameter's index.
    ///
    /// - Parameter args: An SQLiteArguments instance containing tokens and corresponding values to bind.
    /// - Throws: An `SQLiteError` if any value cannot be bound to its parameter.
    public func bind(_ args: SQLiteArguments) throws {
        try args.forEach { token, value in
            try bind(value, at: token)
        }
    }
    
    /// Clears all bindings on the prepared SQL statement.
    ///
    /// After calling, all parameters will have a NULL bound to them.
    ///
    /// - Throws: An `SQLiteError` if the bindings cannot be cleared.
    public func clearBindings() throws {
        if sqlite3_clear_bindings(statement) != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    /// Returns the number of columns in the result set of the prepared SQL statement.
    ///
    /// - Returns: The number of columns.
    public func columnCount() -> Int32 {
        sqlite3_column_count(statement)
    }
    
    /// Returns the data type of the column at the specified index in the result set of the prepared SQL statement.
    ///
    /// - Parameter index: The index of the column.
    /// - Returns: The data type of the column.
    public func columnType(at index: Int32) -> SQLiteType {
        .init(rawValue: sqlite3_column_type(statement, index)) ?? .null
    }
    
    /// Returns the name of the column at the specified index in the result set of the prepared SQL statement.
    ///
    /// - Parameter index: The index of the column.
    /// - Returns: The name of the column.
    public func columnName(at index: Int32) -> String {
        String(cString: sqlite3_column_name(statement, index))
    }
    
    /// Retrieves the SQLite value from the column at the specified index in the result set of the prepared SQL statement.
    ///
    /// - Parameter index: The index of the column.
    /// - Returns: The SQLite value from the column.
    public func columnValue(at index: Int32) -> SQLiteValue {
        switch columnType(at: index) {
        case .int:  return .int(sqlite3_column_int64(statement, index))
        case .real: return .real(sqlite3_column_double(statement, index))
        case .text: return .text(sqlite3_column_text(statement, index))
        case .blob: return .blob(sqlite3_column_blob(statement, index))
        case .null: return .null
        }
    }
    
    /// Retrieves the value of the specified type from the column at the specified index in the result set of the prepared SQL statement.
    ///
    /// - Parameter index: The index of the column.
    /// - Returns: The value of the specified type from the column, or nil if the value is NULL or cannot be converted to the specified type.
    public func columnValue<T: SQLiteConvertible>(at index: Int32) -> T? {
        T(columnValue(at: index))
    }
    
    /// Retrieves the current row of the result set as a SQLiteRow instance.
    ///
    /// This method iterates over the columns of the current row in the result set.
    /// For each column, it retrieves the column name and corresponding value using the
    /// `columnName(at:)` and `columnValue(at:)` methods.
    /// It then populates a SQLiteRow instance with these column-value pairs.
    ///
    /// - Returns: A SQLiteRow instance representing the current row of the result set.
    public func rowValue() -> SQLiteRow {
        var row = SQLiteRow()
        for index in 0..<columnCount() {
            let name = columnName(at: index)
            let value = columnValue(at: index)
            row[name] = value
        }
        return row
    }
    
    /// Executes the next step of the prepared SQL statement.
    ///
    /// - Returns: A boolean indicating whether there are more rows to process
    /// (`true` if there is at least one row, `false` if the statement has finished executing).
    /// - Throws: An `SQLiteError` if an error occurs during execution.
    public func step() throws -> Bool {
        switch sqlite3_step(statement) {
        case SQLITE_ROW:  return true
        case SQLITE_DONE: return false
        default: throw SQLiteError(connection)
        }
    }
    
    /// Resets the prepared SQL statement so it can be executed again.
    ///
    /// - Throws: An `SQLiteError` if the statement cannot be reset.
    public func reset() throws {
        if sqlite3_reset(statement) != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    // MARK: - Equatable
    
    /// Checks if two Statement instances are equal.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side Statement instance to compare.
    ///   - rhs: The right-hand side Statement instance to compare.
    /// - Returns: True if the statements and connections are equal, otherwise false.
    public static func == (lhs: Statement, rhs: Statement) -> Bool {
        lhs.statement == rhs.statement && lhs.connection == rhs.connection
    }
    
    // MARK: - Hashable
    
    /// Hashes the essential components of the Statement instance into a Hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the hash values.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(statement)
        hasher.combine(connection)
    }
}
