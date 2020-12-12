import Foundation
import SQLighter

public final class ModelObserver<M: Model>: TransactionObserver {
  public typealias Observer = (Kind<M>) -> ()
  
  public enum Kind<M: Model> {
    case insert(_ models: [M])
    case update(_ models: [M])
    case delete(_ models: [M])
  }
  
  // MARK: - Properties
  
  private let coder: RecordCoder
  private var observers = [Observer]()
  private var events = [ObserverEvent]()
  private var deleted = [Record]()
  
  // MARK: - Inits
  
  public init(coder: RecordCoder = .init()) {
    self.coder = coder
  }
  
  // MARK: - Public methods
  
  public func add(_ observer: @escaping Observer) {
    observers.append(observer)
  }
  
  // MARK: - TransactionObserver
  
  public func observes(event: ObserverEvent) -> Bool {
    return M.table == event.table
  }
  
  public func connectionDidChange(_ connection: Connection, event: ObserverEvent) {
    events.append(event)
  }
  
  public func connectionWillCommit(_ connection: Connection) throws {
    deleted = records(forEventOf: .delete, on: connection)
  }
  
  public func connectionDidCommit(_ connection: Connection) {
    let insert = records(forEventOf: .insert, on: connection).compactMap { decode(from: $0) }
    let update = records(forEventOf: .update, on: connection).compactMap { decode(from: $0) }
    let delete = deleted.compactMap { decode(from: $0) }
    
    events.removeAll()
    deleted.removeAll()
    
    DispatchQueue.main.async {
      self.notify(insert, of: .insert)
      self.notify(update, of: .update)
      self.notify(delete, of: .delete)
    }
  }
  
  public func connectionDidRollback(_ connection: Connection) {
    events.removeAll()
    deleted.removeAll()
  }
  
  // MARK: - Private
  
  private func records(forEventOf kind: ObserverEvent.Kind, on connection: Connection) -> [Record] {
    let IDs = events.filter { $0.kind == kind }.map { $0.rowID }
    guard !IDs.isEmpty else { return [] }
    
    let sql = SQL.select(from: M.table).where("rowid" ~= IDs).sqlQuery()
    do {
      return try connection.execute(sql: sql.sql, args: sql.args)
    } catch {
      #if DEBUG
      fatalError("\(error)")
      #else
      return []
      #endif
    }
  }
  
  private func decode(from record: Record) -> M? {
    do {
      return try coder.decode(M.self, from: record)
    } catch {
      #if DEBUG
      fatalError("\(error)")
      #else
      return nil
      #endif
    }
  }
  
  private func notify(_ models: [M], of kind: ObserverEvent.Kind) {
    if models.isEmpty == false {
      switch kind {
      case .insert: observers.forEach { $0(.insert(models)) }
      case .update: observers.forEach { $0(.update(models)) }
      case .delete: observers.forEach { $0(.delete(models)) }
      }
    }
  }
}
