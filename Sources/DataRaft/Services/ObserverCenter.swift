import Foundation

public final class ObserverCenter: Pointer {
  private static var centers = [UUID : ObserverCenter]()
  
  private let connection: Connection
  private var observers = [ObserverBox]()
  
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
  
  public func add(_ observer: TransactionObserver, extent: ObservationExtent = .observerLifetime) {
    switch extent {
    case .observerLifetime: observers.append(.init(weak: observer))
    case .centerLifetime:   observers.append(.init(strong: observer))
    }
  }
  
  func didUpdate(_ event: ObserverEvent) {
    observers.filter {
      $0.observes(event: event)
    }.forEach {
      $0.connectionDidChange(connection, event: event)
    }
  }
  
  func willCommit() throws {
    try observers.forEach {
      try $0.connectionWillCommit(connection)
    }
  }
  
  func didCommit() {
    observers.forEach {
      $0.connectionDidCommit(connection)
    }
  }
  
  func didRollback() {
    observers.forEach {
      $0.connectionDidRollback(connection)
    }
  }
}
