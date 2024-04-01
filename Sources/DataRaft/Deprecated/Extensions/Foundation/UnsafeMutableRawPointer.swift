import Foundation

extension UnsafeMutableRawPointer {
  static prefix func * <T: AnyObject>(value: Self) -> T {
    return Unmanaged<T>.fromOpaque(value).takeUnretainedValue()
  }
}

extension Optional where Wrapped == UnsafeMutableRawPointer {
  static prefix func * <T: AnyObject>(value: Self) -> T? {
    switch value {
    case .some(let value):
      return Unmanaged<T>.fromOpaque(value).takeUnretainedValue()
    case .none:
      return nil
    }
  }
}
