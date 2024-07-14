import Foundation

/// Represents different types of database update actions.
///
/// The `SQLiteAction` enum is used to identify the type of action
/// performed on a database, such as insertion, updating, or deletion.
public enum SQLiteAction {
    /// Indicates the insertion of a new row into a table.
    ///
    /// - Parameters:
    ///     - db: The name of the database where the insertion occurred.
    ///     - table: The name of the table where the insertion occurred.
    ///     - rowID: The row ID of the newly inserted row.
    case insert(db: String, table: String, rowID: Int64)
    
    /// Indicates the modification of an existing row in a table.
    ///
    /// - Parameters:
    ///     - db: The name of the database where the update occurred.
    ///     - table: The name of the table where the update occurred.
    ///     - rowID: The row ID of the updated row.
    case update(db: String, table: String, rowID: Int64)
    
    /// Indicates the removal of a row from a table.
    ///
    /// - Parameters:
    ///     - db: The name of the database from which the row was deleted.
    ///     - table: The name of the table from which the row was deleted.
    ///     - rowID: The row ID of the deleted row.
    case delete(db: String, table: String, rowID: Int64)
}
