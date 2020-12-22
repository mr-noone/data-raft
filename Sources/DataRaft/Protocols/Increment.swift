import Foundation

prefix operator ++
postfix operator ++

protocol Increment {
  static prefix func ++ (value: inout Self) -> Self
  static postfix func ++ (value: inout Self) -> Self
}

extension Increment where Self: BinaryInteger {
  static prefix func ++ (value: inout Self) -> Self {
    value = value + 1
    return value
  }
  
  static postfix func ++ (value: inout Self) -> Self {
    value = value + 1
    return value - 1
  }
}

extension Int: Increment {}
extension Int8: Increment {}
extension Int16: Increment {}
extension Int32: Increment {}
extension Int64: Increment {}

extension UInt: Increment {}
extension UInt8: Increment {}
extension UInt16: Increment {}
extension UInt32: Increment {}
extension UInt64: Increment {}
