import Foundation
import WeakArray

public final class ObserverCenter: Pointer {
  private static var centers = [UUID : ObserverCenter]()
  
  private let connection: Connection
  private var observers = WeakArray<ObserverBox>()
  
  init(db connection: Connection) {
    self.connection = connection
  }
  
  public static func center(for dbFilePath: String) throws -> ObserverCenter {
    let uuid = UUID(md5: dbFilePath.md5)!
    return try centers[uuid] ?? {
      let center = try ObserverCenter(db: .init(path: dbFilePath, observer: nil))
      centers[uuid] = center
      return center
    }()
  }
  
  public func add(_ observer: TransactionObserver) {
    observers.compact()
    observers.append(.init(observer))
  }
  
  func didUpdate(_ event: ObserverEvent) {
    observers.compactMap { $0 }.filter {
      $0.observes(event: event)
    }.forEach {
      $0.connectionDidChange(connection, event: event)
    }
  }
  
  func willCommit() throws {
    try observers.compactMap { $0 }.forEach {
      try $0.connectionWillCommit(connection)
    }
  }
  
  func didCommit() {
    observers.compactMap { $0 }.forEach {
      $0.connectionDidCommit(connection)
    }
  }
  
  func didRollback() {
    observers.compactMap { $0 }.forEach {
      $0.connectionDidRollback(connection)
    }
  }
}
