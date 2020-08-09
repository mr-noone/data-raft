import Foundation

public protocol DatabaseValueConvertible {
  var databaseValue: DatabaseValue { get }
  init?(_ databaseValue: DatabaseValue)
}

// MARK: - SignedInteger

public extension DatabaseValueConvertible where Self: SignedInteger {
  var databaseValue: DatabaseValue {
    return .int(.init(self))
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.int(value) = databaseValue {
      self.init(value)
    } else {
      return nil
    }
  }
}

extension Int: DatabaseValueConvertible {}
extension Int8: DatabaseValueConvertible {}
extension Int16: DatabaseValueConvertible {}
extension Int32: DatabaseValueConvertible {}
extension Int64: DatabaseValueConvertible {}

// MARK: - UnsignedInteger

public extension DatabaseValueConvertible where Self: UnsignedInteger {
  var databaseValue: DatabaseValue {
    return .int(.init(self))
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.int(value) = databaseValue {
      self.init(value)
    } else {
      return nil
    }
  }
}

extension UInt: DatabaseValueConvertible {}
extension UInt8: DatabaseValueConvertible {}
extension UInt16: DatabaseValueConvertible {}
extension UInt32: DatabaseValueConvertible {}
extension UInt64: DatabaseValueConvertible {}

// MARK: - BinaryFloatingPoint

public extension DatabaseValueConvertible where Self: BinaryFloatingPoint {
  var databaseValue: DatabaseValue {
    return .double(.init(self))
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.double(value) = databaseValue {
      self.init(value)
    } else {
      return nil
    }
  }
}

extension Float: DatabaseValueConvertible {}
extension Double: DatabaseValueConvertible {}

// MARK: - Bool

extension Bool: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue {
    return .int(self ? 1 : 0)
  }
  
  public init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.int(value) = databaseValue {
      self = value == 1
    } else {
      return nil
    }
  }
}

// MARK: - StringProtocol

public extension DatabaseValueConvertible where Self: StringProtocol {
  var databaseValue: DatabaseValue {
    return .text(String(self))
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.text(value) = databaseValue {
      self.init(value)
    } else {
      return nil
    }
  }
}

extension String: DatabaseValueConvertible {}

// MARK: - Data

extension Data: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue {
    return .data(self)
  }
  
  public init?(_ databaseValue: DatabaseValue) {
    if case let DatabaseValue.data(value) = databaseValue {
      self = value
    } else {
      return nil
    }
  }
}

// MARK: - RawRepresentable

extension DatabaseValueConvertible where Self: RawRepresentable, RawValue: DatabaseValueConvertible {
  var databaseValue: DatabaseValue {
    return rawValue.databaseValue
  }
  
  init?(_ databaseValue: DatabaseValue) {
    if let value = RawValue(databaseValue) {
      self.init(rawValue: value)
    } else {
      return nil
    }
  }
}
