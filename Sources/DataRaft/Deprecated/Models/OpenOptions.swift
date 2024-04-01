import Foundation
import CSQLite

extension Connection {
  public struct OpenOptions: OptionSet {
    public var rawValue: Int32
    
    public static let readonly      = Self(rawValue: SQLITE_OPEN_READONLY)!
    public static let readwrite     = Self(rawValue: SQLITE_OPEN_READWRITE)!
    public static let create        = Self(rawValue: SQLITE_OPEN_CREATE)!
    public static let uri           = Self(rawValue: SQLITE_OPEN_URI)!
    public static let memory        = Self(rawValue: SQLITE_OPEN_MEMORY)!
    public static let nomutex       = Self(rawValue: SQLITE_OPEN_NOMUTEX)!
    public static let fullmutex     = Self(rawValue: SQLITE_OPEN_FULLMUTEX)!
    public static let sharedcache   = Self(rawValue: SQLITE_OPEN_SHAREDCACHE)!
    public static let privatecache  = Self(rawValue: SQLITE_OPEN_PRIVATECACHE)!
    
    public init!(rawValue: Int32) {
      self.rawValue = rawValue
    }
  }
}
