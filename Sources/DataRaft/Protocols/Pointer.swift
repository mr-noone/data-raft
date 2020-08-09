import Foundation

prefix operator *

protocol Pointer where Self: AnyObject {
  static prefix func * (value: Self) -> UnsafeMutableRawPointer
}

extension Pointer {
  static prefix func * (value: Self) -> UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(value).toOpaque()
  }
}

extension Connection: Pointer {}
