import Foundation

public struct DatabaseConfig {
  public var trace: Connection.TraceCallback?
  public var busyTimeout: Int32 = 5000
  
  public init() {}
}
