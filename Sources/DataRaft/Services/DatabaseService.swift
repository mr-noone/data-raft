import Foundation
import SQLiteSwift

/// A base class responsible for managing SQLite database operations.
///
/// This class provides basic functionality for performing database operations, including synchronous
/// task execution and transaction management.
/// Subclasses can inherit from this class to extend its functionality or provide additional features.
public class DatabaseService {
    // MARK: - Properties
    
    private let connection: Connection
    private let queue: DispatchQueue
    private let queueKey = DispatchSpecificKey<Void>()
    
    // MARK: - Inits
    
    /// Initializes a new `DatabaseService` with the provided SQLite connection and an optional DispatchQueue.
    ///
    /// - Parameters:
    ///   - connection:
    ///         The SQLite database connection to use.
    ///   - queue:
    ///         An optional DispatchQueue to execute tasks on.
    ///         If not provided, a new queue is created with a label based on the type name.
    public init(connection: Connection, queue: DispatchQueue? = nil) {
        self.connection = connection
        self.queue = queue ?? .init(for: Self.self)
        self.queue.setSpecific(key: queueKey, value: ())
    }
    
    // MARK: - Methods
    
    /// Executes a closure on the database connection.
    ///
    /// This method ensures thread safety by synchronizing access to the database connection.
    ///
    /// - Parameter closure: The closure to execute, which takes a `Connection` parameter.
    /// - Returns: The result of the closure execution.
    /// - Throws: Any error that occurs during the closure execution.
    func perform<T>(_ closure: (Connection) throws -> T) rethrows -> T {
        switch DispatchQueue.getSpecific(key: queueKey) {
        case .none: return try queue.sync { try closure(connection) }
        case .some: return try closure(connection)
        }
    }
    
    /// Executes a closure within a transaction on the database connection.
    ///
    /// If the connection is in autocommit mode, it begins and commits
    /// the transaction around the closure's execution.
    /// Otherwise, it directly executes the closure.
    ///
    /// This method ensures thread safety by synchronizing access to the database connection.
    ///
    /// - Parameters:
    ///   - transaction: The type of SQLite transaction to perform.
    ///   - closure: The closure to execute, which takes a `Connection` parameter.
    /// - Returns: The result of the closure execution.
    /// - Throws: Any error that occurs during the closure execution.
    func perform<T>(
        in transaction: SQLiteTransactionType,
        closure: (Connection) throws -> T
    ) rethrows -> T {
        if connection.isAutocommit {
            try perform { connection in
                do {
                    try connection.beginTransaction(transaction)
                    let result = try closure(connection)
                    try connection.commitTransaction()
                    return result
                } catch {
                    try connection.rollbackTransaction()
                    throw error
                }
            }
        } else {
            try perform(closure)
        }
    }
}
