import Foundation
import SQLiteC

/// Sets the result text for an SQLite query.
///
/// - Parameters:
///   - ctx: A pointer to the context of the SQLite query.
///   - string: The text to be set as the result of the query.
func sqlite3_result_text(_ ctx: OpaquePointer!, _ string: String) {
    sqlite3_result_text(ctx, string, -1, SQLITE_TRANSIENT)
}

/// Sets the result blob for an SQLite query.
///
/// - Parameters:
///   - ctx: A pointer to the context of the SQLite query.
///   - data: The binary data to be set as the result of the query.
func sqlite3_result_blob(_ ctx: OpaquePointer!, _ data: Data) {
    data.withUnsafeBytes {
        sqlite3_result_blob(ctx, $0.baseAddress, Int32($0.count), SQLITE_TRANSIENT)
    }
}

/// Sets the result of an SQLite query based on the provided SQLiteValue.
///
/// - Parameters:
///   - ctx: A pointer to the context of the SQLite query.
///   - value: The SQLiteValue to be set as the result of the query.
func sqlite3_result_value(_ ctx: OpaquePointer!, _ value: SQLiteValue?) {
    switch value ?? .null {
    case .int(let value):   sqlite3_result_int64(ctx, value)
    case .real(let value):  sqlite3_result_double(ctx, value)
    case .text(let value):  sqlite3_result_text(ctx, value)
    case .blob(let value):  sqlite3_result_blob(ctx, value)
    case .null:             sqlite3_result_null(ctx)
    }
}

/// Executes a custom SQLite scalar function.
///
/// - Parameters:
///   - ctx: A pointer to the context of the SQLite query.
///   - argc: The number of arguments passed to the function.
///   - argv: An array of pointers to the values of the arguments passed to the function.
///
/// This function retrieves the function implementation from the context associated with the SQLite query,
/// invokes the function with the provided arguments, and sets the result of the query based on the
/// returned value or reports an error if any occurs during the function invocation.
private func xFunc(
    _ ctx: OpaquePointer?,
    _ argc: Int32,
    _ argv: UnsafeMutablePointer<OpaquePointer?>?
) {
    let function = Unmanaged<Function>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
    do {
        let args = Function.Arguments(argc: argc, argv: argv)
        let result = try function.invoke(args: args)
        sqlite3_result_value(ctx, result?.sqliteValue)
    } catch {
        let message = error.localizedDescription
        sqlite3_result_error(ctx, message, -1)
    }
}

/// Executes the step operation of an aggregate function.
///
/// This function is called by SQLite for each input row to an aggregate function.
/// It retrieves the Function instance associated with the provided context, then invokes
/// the step operation of the aggregate function with the given arguments.
/// If an error occurs during the execution of the step operation, it sets a flag in the context
/// indicating the error and returns an error message to SQLite.
///
/// - Parameters:
///   - ctx: The SQLite context associated with the aggregate function.
///   - argc: The number of arguments passed to the aggregate function.
///   - argv: An array of pointers to the values of the arguments.
private func xStep(
    _ ctx: OpaquePointer?,
    _ argc: Int32,
    _ argv: UnsafeMutablePointer<OpaquePointer?>?
) {
    let context = Unmanaged<Function>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
        .aggregateContext(ctx: ctx)
        .takeUnretainedValue()

    assert(!context.hasErrored)
    
    do {
        let args = Function.Arguments(argc: argc, argv: argv)
        try context.definition.step(args: args)
    } catch {
        let message = error.localizedDescription
        context.hasErrored = true
        sqlite3_result_error(ctx, message, -1)
    }
}

/// Executes the finalize operation of an aggregate function.
///
/// This function is called by SQLite after all input rows have been processed by the aggregate function.
/// It retrieves the Function instance associated with the provided context, then invokes the finalize
/// operation of the aggregate function.
/// If an error occurs during the execution of the finalize operation, it returns an error message to SQLite.
///
/// - Parameter ctx: The SQLite context associated with the aggregate function.
private func xFinal(_ ctx: OpaquePointer?) {
    let unmanagedContext = Unmanaged<Function>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
        .aggregateContext(ctx: ctx)
    
    let context = unmanagedContext.takeUnretainedValue()
    
    unmanagedContext.release()
    
    guard !context.hasErrored else { return }
    
    do {
        let result = try context.definition.finalize()
        sqlite3_result_value(ctx, result?.sqliteValue)
    } catch {
        let message = error.localizedDescription
        sqlite3_result_error(ctx, message, -1)
    }
}

/// Destroys the context associated with a custom SQLite function.
///
/// - Parameter ctx: A pointer to the context of the SQLite function.
private func xDestroy(_ ctx: UnsafeMutableRawPointer?) {
    guard let ctx else { return }
    Unmanaged<AnyObject>.fromOpaque(ctx).release()
}

/// Represents a custom SQLite function.
///
/// This class allows you to define and manage custom functions in SQLite databases.
public final class Function: Hashable {
    /// A class representing the context for an aggregate function.
    ///
    /// This class holds the state of an aggregate function during its execution, including
    /// the aggregatefunction definition and whether an error has occurred.
    fileprivate final class AggregateContext {
        /// The aggregate function definition associated with this context.
        var definition: Aggregate
        
        /// A flag indicating whether an error has occurred during the execution of the aggregate function.
        var hasErrored = false
        
        /// Initializes the aggregate context with the specified aggregate function definition.
        ///
        /// - Parameter definition: The aggregate function definition.
        init(definition: Aggregate) {
            self.definition = definition
        }
    }
    
    // MARK: - Properties
    
    /// The opaque pointer to the SQLite database connection.
    private let connection: OpaquePointer
    
    /// The definition of the custom function.
    private let definition: Definition.Type
    
    // MARK: - Inits
    
    /// Initializes a custom SQLite scalar function with the provided database connection and definition.
    ///
    /// Use this initializer to create a custom scalar function in an SQLite database.
    /// It registers the provided function definition with the specified database connection.
    ///
    /// - Parameters:
    ///   - db: The opaque pointer to the SQLite database connection.
    ///   - definition: The definition of the custom scalar function.
    /// - Throws: An `SQLiteError` if the function cannot be created.
    init<D: Scalar>(db connection: OpaquePointer, definition: D.Type) throws {
        self.connection = connection
        self.definition = definition
        
        let ctx = Unmanaged.passRetained(self).toOpaque()
        let status = sqlite3_create_function_v2(
            connection,
            definition.name,
            definition.argc,
            definition.opts,
            ctx,
            xFunc(_:_:_:),
            nil,
            nil,
            xDestroy(_:)
        )
        
        if status != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    /// Initializes a custom SQLite aggregate function with the provided database connection and definition.
    ///
    /// Use this initializer to create a custom aggregate function in an SQLite database.
    /// It registers the provided function definition with the specified database connection.
    ///
    /// - Parameters:
    ///   - db: The opaque pointer to the SQLite database connection.
    ///   - definition: The definition of the custom aggregate function.
    /// - Throws: An `SQLiteError` if the function cannot be created.
    init<D: Aggregate>(db connection: OpaquePointer, definition: D.Type) throws {
        self.connection = connection
        self.definition = definition
        
        let ctx = Unmanaged.passRetained(self).toOpaque()
        let status = sqlite3_create_function_v2(
            connection,
            definition.name,
            definition.argc,
            definition.opts,
            ctx,
            nil,
            xStep(_:_:_:),
            xFinal(_:),
            xDestroy(_:)
        )
        
        if status != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    /// Destroys the custom SQLite function.
    ///
    /// When an instance of `Function` is deallocated, this method is called to
    /// unregister the custom function from the SQLite database connection.
    /// If an error occurs during deregistration, a fatal error is raised.
    deinit {
        let status = sqlite3_create_function_v2(
            connection,
            definition.name,
            definition.argc,
            definition.opts,
            nil, nil, nil, nil, nil
        )
        if status != SQLITE_OK {
            fatalError(SQLiteError(connection).localizedDescription)
        }
    }
    
    // MARK: - Methods
    
    /// Checks if the current SQLite function instance contains the specified definition type.
    ///
    /// This method compares the definition type of the current SQLite function instance with the specified definition type.
    ///
    /// - Parameter definition: The type of the definition to check.
    /// - Returns: `true` if the current SQLite function instance contains the specified definition type; otherwise, `false`.
    func contains(_ definition: Definition.Type) -> Bool {
        return self.definition == definition
    }
    
    /// Invokes the `invoke` method of the scalar function definition.
    ///
    /// This function attempts to invoke the `invoke` method of the scalar
    /// function definition,passing the provided arguments.
    /// If the definition conforms to the `Scalar` protocol and implements the
    /// `invoke` method,it calls the method and returns the result.
    /// If the definition does not conform to the `Scalar` protocol or the `invoke`
    /// method throws an error, this function rethrows the error.
    ///
    /// - Parameter args: The arguments to pass to the scalar function.
    /// - Returns: The result of the scalar function invocation, or `nil`.
    fileprivate func invoke(args: Arguments) throws -> SQLiteConvertible? {
        try (definition as! Scalar.Type).invoke(args: args)
    }
    
    /// Retrieves or creates the aggregate context associated with the given SQLite context.
    ///
    /// This function retrieves the aggregate context associated with the provided SQLite context.
    /// If no context exists, it creates a new one and initializes it with the aggregate function definition.
    /// The context is stored in SQLite's aggregate context mechanism.
    ///
    /// - Parameter ctx: The SQLite context associated with the aggregate function.
    /// - Returns: An unmanaged reference to the aggregate context.
    fileprivate func aggregateContext(ctx: OpaquePointer?) -> Unmanaged<AggregateContext> {
        let stride = MemoryLayout<Unmanaged<AggregateContext>>.stride
        let contextBuffer = UnsafeMutableRawBufferPointer(
            start: sqlite3_aggregate_context(ctx, Int32(stride)),
            count: stride
        )
        
        if contextBuffer.contains(where: { $0 != 0 }) {
            return contextBuffer.baseAddress!.assumingMemoryBound(
                to: Unmanaged<AggregateContext>.self
            ).pointee
        } else {
            let definition = (definition as! Aggregate.Type).init()
            let context = AggregateContext(definition: definition)
            
            let unmanagedContext = Unmanaged.passRetained(context)
            let contextPointer = unmanagedContext.toOpaque()
            withUnsafeBytes(of: contextPointer) {
                contextBuffer.copyMemory(from: $0)
            }
            return unmanagedContext
        }
    }
    
    // MARK: - Equatable
    
    /// Compares two `Function` instances for equality.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `Function`.
    ///   - rhs: The right-hand side `Function`.
    /// - Returns: `true` if both `Function` instances are equal, otherwise `false`.
    public static func == (lhs: Function, rhs: Function) -> Bool {
        lhs.connection == rhs.connection && lhs.definition == rhs.definition
    }
    
    // MARK: - Hashable
    
    /// Hashes the `Function` instance into the provided hasher.
    ///
    /// - Parameter hasher: The hasher to use for hashing.
    ///
    /// This method combines the hash values of the `connection` and `definition`
    /// properties to produce a hash value for the `Function` instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(connection)
        hasher.combine(definition.name)
        hasher.combine(definition.argc)
        hasher.combine(definition.opts)
    }
}
