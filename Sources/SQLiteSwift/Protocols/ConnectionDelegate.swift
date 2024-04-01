import Foundation

/// A protocol defining methods that can be implemented by delegates of a `Connection` object.
public protocol ConnectionDelegate: AnyObject {
    /// Informs the delegate that a SQL statement is being traced.
    ///
    /// This method is called when a SQL statement is about to be executed, allowing the delegate to monitor SQLite queries.
    ///
    /// - Parameters:
    ///   - connection: The `Connection` instance.
    ///   - sql: A tuple containing the unexpanded and expanded forms of the SQL statement being traced.
    func connection(_ connection: Connection, trace sql: (unexpandedSQL: String, expandedSQL: String))
    
    /// Informs the delegate that an update action has occurred.
    ///
    /// - Parameters:
    ///   - connection: The `Connection` instance.
    ///   - action: The type of update action that occurred.
    func connection(_ connection: Connection, didUpdate action: SQLiteAction)
    
    /// Informs the delegate that a transaction has been successfully committed.
    ///
    /// If this method throws an error, the COMMIT operation is converted into a ROLLBACK.
    ///
    /// - Parameter connection: The `Connection` instance.
    /// - Throws: May throw an error to abort the commit process.
    func connectionDidCommit(_ connection: Connection) throws
    
    /// Informs the delegate that a transaction has been rolled back.
    ///
    /// - Parameter connection: The `Connection` instance.
    func connectionDidRollback(_ connection: Connection)
}

public extension ConnectionDelegate {
    /// Default implementation of the `connection(_:trace:)` method.
    ///
    /// This default implementation does nothing.
    ///
    /// - Parameters:
    ///   - connection: The `Connection` instance.
    ///   - sql: A tuple containing the unexpanded and expanded forms of the SQL statement being traced.
    func connection(_ connection: Connection, trace sql: (unexpandedSQL: String, expandedSQL: String)) {}
    
    /// Default implementation of the `connection(_:didUpdate:)` method.
    ///
    /// This default implementation does nothing.
    ///
    /// - Parameters:
    ///   - connection: The `Connection` instance.
    ///   - action: The type of update action that occurred.
    func connection(_ connection: Connection, didUpdate action: SQLiteAction) {}
    
    /// Default implementation of the `connectionDidCommit(_:)` method.
    ///
    /// This default implementation does nothing.
    ///
    /// - Parameter connection: The `Connection` instance.
    /// - Throws: May throw an error to abort the commit process.
    func connectionDidCommit(_ connection: Connection) throws {}
    
    /// Default implementation of the `connectionDidRollback(_:)` method.
    ///
    /// This default implementation does nothing.
    ///
    /// - Parameter connection: The `Connection` instance.
    func connectionDidRollback(_ connection: Connection) {}
}
