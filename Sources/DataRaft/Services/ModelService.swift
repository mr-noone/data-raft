import Foundation
import SQLiteSwift

/// A service class for interacting with models in an SQLite database.
///
/// `ModelService` provides convenient methods to perform common CRUD (Create, Read, Update, Delete)
/// operations on models stored in an SQLite database. It encapsulates the database connection
/// and provides a set of methods to manage the models efficiently.
public final class ModelService: DatabaseService {
    // MARK: - Properties
    
    /// The decoder used to decode database rows into Swift models.
    private let decoder: RowDecoder
    
    /// The encoder used to encode Swift models into database rows.
    private let encoder: RowEncoder
    
    // MARK: - Inits
    
    /// Initializes a new instance of `ModelService`.
    ///
    /// - Parameters:
    ///   - connection: The SQLite database connection.
    ///   - queue: An optional dispatch queue to perform operations asynchronously.
    ///   - decoder: The decoder used to decode database rows into Swift models.
    ///   - encoder: The encoder used to encode Swift models into database rows.
    public init(
        connection: Connection,
        queue: DispatchQueue? = nil,
        decoder: RowDecoder = .init(),
        encoder: RowEncoder = .init()
    ) {
        self.decoder = decoder
        self.encoder = encoder
        super.init(
            connection: connection,
            queue: queue
        )
    }
    
    // MARK: - Methods
    
    /// Executes a batch of operations within a deferred transaction.
    ///
    /// This method allows executing multiple database operations atomically within a single transaction.
    /// It ensures consistency and atomicity of operations, making it suitable for performing a batch of
    /// operations that need to be treated as a single unit.
    ///
    /// - Parameter closure: The closure containing the operations to be performed.
    /// - Returns: The result of the closure execution.
    /// - Throws: Any error that occurred during the execution of the closure.
    public func batchPerform<T>(
        _ closure: (ModelService) throws -> T
    ) rethrows -> T {
        try perform(in: .deferred) { _ in
            try closure(self)
        }
    }
    
    /// Retrieves models from the database based on the specified criteria.
    ///
    /// This method retrieves models from the database table associated with the specified model type.
    /// It allows filtering, ordering, and limiting the results based on the provided criteria.
    ///
    /// - Parameters:
    ///   - predicate: An optional predicate to filter the results.
    ///   - orderBy: An optional ordering specification.
    ///   - limit: An optional limit on the number of results.
    /// - Returns: An array of models matching the criteria.
    /// - Throws: Any error that occurred during the database operation.
    public func select<M: Model>(
        _ predicate: Predicate? = nil,
        orderBy: OrderBy? = nil,
        limit: Limit? = nil
    ) throws -> [M] {
        try perform(in: .deferred) { connection in
            let components = [
                "SELECT * FROM \(M.table)",
                predicate?.description,
                orderBy?.description,
                limit?.description
            ]
            let sql = components
                .compactMap { $0 }
                .joined(separator: " ")
            let args = predicate?.arguments ?? []
            let stmt = try connection.prepare(sql: sql)
            let rows = try connection.execute(sql: stmt, args: args)
            return try decoder.decode([M].self, from: rows)
        }
    }
    
    /// Retrieves a single model from the database by its ID.
    ///
    /// This method fetches a single model from the database table associated with the specified model type
    /// using its unique identifier. If no model with the provided ID is found, it returns `nil`.
    ///
    /// - Parameter id: The ID of the model to retrieve.
    /// - Returns: The model with the specified ID, or `nil` if not found.
    /// - Throws: Any error that occurred during the database operation.
    public func select<M: Model>(id: M.ID) throws -> M? {
        let predicate = Predicate(expression: "\(M.idKey) = ?", id)
        return try select(predicate, limit: 1).first
    }
    
    /// Counts the number of models in the database based on the specified criteria.
    ///
    /// This method retrieves the count of models from the database table associated with the specified model type.
    /// It allows filtering the models based on the provided predicate.
    ///
    /// - Parameters:
    ///   - predicate: An optional predicate to filter the models.
    ///   - type: The type of the model to count.
    /// - Returns: The number of models matching the specified criteria.
    /// - Throws: Any error that occurred during the database operation.
    public func count<M: Model>(
        _ predicate: Predicate? = nil,
        of type: M.Type
    ) throws -> Int {
        try perform(in: .deferred) { connection in
            let components = [
                "SELECT COUNT(*) FROM \(M.table)",
                predicate?.description
            ]
            let sql = components
                .compactMap { $0 }
                .joined(separator: " ")
            let args = predicate?.arguments
            let stmt = try connection.prepare(sql: sql)
            return try connection.execute(sql: stmt, args: args) ?? 0
        }
    }
    
    /// Checks whether any models exist in the database based on the specified criteria.
    ///
    /// This method determines whether there are any models in the database table associated
    /// with the specified model type that satisfy the provided predicate.
    ///
    /// - Parameters:
    ///   - predicate: An optional predicate to filter the models.
    ///   - type: The type of the model to check for existence.
    /// - Returns: `true` if any matching models exist, otherwise `false`.
    /// - Throws: Any error that occurred during the database operation.
    public func exists<M: Model>(
        _ predicate: Predicate? = nil,
        of type: M.Type
    ) throws -> Bool {
        try perform(in: .deferred) { connection in
            let components: [String?] = [
                "SELECT 1 FROM \(M.table)",
                predicate?.description
            ]
            let select = components
                .compactMap { $0 }
                .joined(separator: " ")
            let sql = "SELECT EXISTS (\(select))"
            let args = predicate?.arguments
            let stmt = try connection.prepare(sql: sql)
            return try connection.execute(sql: stmt, args: args) ?? false
        }
    }
    
    /// Checks whether a model with the specified ID exists in the database.
    ///
    /// - Parameters:
    ///   - id: The ID of the model to check for existence.
    ///   - type: The type of the model.
    /// - Returns: `true` if a matching model exists, otherwise `false`.
    /// - Throws: Any error that occurred during the database operation.
    public func exists<M: Model>(id: M.ID, of type: M.Type) throws -> Bool {
        let predicate = Predicate(expression: "\(M.idKey) = ?", id)
        return try exists(predicate, of: type)
    }
    
    /// Inserts one or more models into the database.
    ///
    /// - Parameter models: An array of models to be inserted.
    /// - Throws: Any error that occurred during the database operation.
    public func insert<M: Model>(_ models: [M]) throws {
        try perform(in: .deferred) { connection in
            let rows: [SQLiteRow] = try encoder.encode(models)
            if let row = rows.first {
                let columns = row.columns
                let sql = """
                INSERT INTO \(M.table) (\(columns.joined(separator: ", ")))
                VALUES (\(columns.map { ":\($0)" }.joined(separator: ", ")))
                """
                let args: [Statement.Arguments] = rows.map { .init($0) }
                let stmt = try connection.prepare(sql: sql)
                try connection.execute(sql: stmt, args: args)
            }
        }
    }
    
    /// Inserts a single model into the database.
    ///
    /// - Parameter model: The model to be inserted.
    /// - Throws: Any error that occurred during the database operation.
    public func insert<M: Model>(_ model: M) throws {
        try insert([model])
    }
    
    /// Updates one or more models in the database.
    ///
    /// - Parameter models: An array of models to be updated.
    /// - Throws: Any error that occurred during the database operation.
    public func update<M: Model>(_ models: [M]) throws {
        try perform(in: .deferred) { connection in
            let rows: [SQLiteRow] = try encoder.encode(models)
            if let row = rows.first {
                let predicate = Predicate(expression: "\(M.idKey) = ?")
                let columns = row.columns
                    .map { "\($0) = :\($0)" }
                    .joined(separator: ", ")
                let sql = "UPDATE \(M.table) SET \(columns) \(predicate)"
                let args: [Statement.Arguments] = rows.map {
                    .init($0) + ($0[M.idKey] ?? .null)
                }
                let stmt = try connection.prepare(sql: sql)
                try connection.execute(sql: stmt, args: args)
            }
        }
    }
    
    /// Updates a single model in the database.
    ///
    /// - Parameter model: The model to be updated.
    /// - Throws: Any error that occurred during the database operation.
    public func update<M: Model>(_ model: M) throws {
        try update([model])
    }
    
    /// Deletes models from the database based on the specified predicate.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter the models to be deleted.
    ///   - type: The type of the model.
    /// - Throws: Any error that occurred during the database operation.
    public func delete<M: Model>(
        _ predicate: Predicate,
        of type: M.Type
    ) throws {
        try perform(in: .deferred) { connection in
            let sql = "DELETE FROM \(M.table) \(predicate)"
            let args = predicate.arguments
            let stmt = try connection.prepare(sql: sql)
            try connection.execute(sql: stmt, args: args)
        }
    }
    
    /// Deletes a single model from the database.
    ///
    /// - Parameter model: The model to be deleted.
    /// - Throws: Any error that occurred during the database operation.
    public func delete<M: Model>(_ model: M) throws {
        let predicate = Predicate(expression: "\(M.idKey) = ?", model.id)
        try delete(predicate, of: M.self)
    }
    
    /// Deletes multiple models from the database.
    ///
    /// - Parameter models: An array of models to be deleted.
    /// - Throws: Any error that occurred during the database operation.
    public func delete<M: Model>(_ models: [M]) throws {
        let args = models.map { $0.id }
        let params = Array(repeating: "?", count: models.count).joined(separator: ", ")
        let predicate = Predicate(expression: "\(M.idKey) IN (\(params))", args)
        try delete(predicate, of: M.self)
    }
}
