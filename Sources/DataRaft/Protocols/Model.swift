import Foundation
import SQLiteSwift

/// The `Model` protocol defines an interface for data models in the application.
///
/// Types conforming to this protocol represent structured data that can be stored and retrieved from a database.
/// Each model object has a unique identifier and may have associated properties.
///
/// To conform to this protocol, a type must implement the `Codable` protocol to support encoding
/// and decoding, allowing it to be serialized to and deserialized from external representations such as JSON.
/// Additionally, the associated `ID` type must conform to `Codable` and `SQLiteBindable`,
/// enabling it to be bound to SQLite statements.
///
/// Example:
/// ```swift
/// struct User: Model {
///     let id: UUID
///     var name: String
///     var email: String
/// }
/// ```
public protocol Model: Codable {
    /// An associated type representing the identifier type of the model.
    ///
    /// The `ID` type must conform to `Codable` and `SQLiteBindable`,
    /// allowing it to be encoded/decoded and bound to SQLite statements.
    associatedtype ID: Codable & SQLiteBindable
    
    /// The name of the table where objects of this model are stored in the database.
    static var table: String { get }
    
    /// The unique identifier of the model object.
    var id: ID { get }
}

public extension Model {
    /// By default, returns the table name which matches the type name of the model.
    static var table: String { String(describing: Self.self) }
    
    /// By default, returns the key name for the identifier column in the database table.
    static var idKey: String { "id" }
}
