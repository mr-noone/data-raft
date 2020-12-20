import Foundation

class ObserverBox: TransactionObserver {
  private weak var weak: TransactionObserver?
  private var strong: TransactionObserver?
  
  var unbox: TransactionObserver? {
    return strong ?? weak
  }
  
  init(weak: TransactionObserver) {
      self.weak = weak
  }
  
  init(strong: TransactionObserver) {
      self.strong = strong
  }
  
  func observes(event: ObserverEvent) -> Bool {
    return unbox?.observes(event: event) ?? false
  }
  
  func connectionDidChange(_ connection: Connection, event: ObserverEvent) {
    unbox?.connectionDidChange(connection, event: event)
  }
  
  func connectionWillCommit(_ connection: Connection) throws {
    try unbox?.connectionWillCommit(connection)
  }
  
  func connectionDidCommit(_ connection: Connection) {
    unbox?.connectionDidCommit(connection)
  }
  
  func connectionDidRollback(_ connection: Connection) {
    unbox?.connectionDidRollback(connection)
  }
}
