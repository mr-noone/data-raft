import Foundation

public protocol TransactionObserver {
  func observes(event: ObserverEvent) -> Bool
  func connectionDidChange(_ connection: Connection, event: ObserverEvent)
  func connectionWillCommit(_ connection: Connection) throws
  func connectionDidCommit(_ connection: Connection)
  func connectionDidRollback(_ connection: Connection)
}
