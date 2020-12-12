import Foundation

class ObserverBox: TransactionObserver {
  let observer: TransactionObserver
  
  init(_ observer: TransactionObserver) {
    self.observer = observer
  }
  
  func observes(event: ObserverEvent) -> Bool {
    return observer.observes(event: event)
  }
  
  func connectionDidChange(_ connection: Connection, event: ObserverEvent) {
    observer.connectionDidChange(connection, event: event)
  }
  
  func connectionWillCommit(_ connection: Connection) throws {
    try observer.connectionWillCommit(connection)
  }
  
  func connectionDidCommit(_ connection: Connection) {
    observer.connectionDidCommit(connection)
  }
  
  func connectionDidRollback(_ connection: Connection) {
    observer.connectionDidRollback(connection)
  }
}
