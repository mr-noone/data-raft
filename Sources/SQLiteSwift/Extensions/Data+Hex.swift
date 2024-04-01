import Foundation

extension Data {
    /// A hexadecimal representation of the data.
    ///
    /// This property returns a hexadecimal string representation of the data.
    ///
    /// Example:
    /// ```swift
    /// let data = Data([0x48, 0x65, 0x6C, 0x6C, 0x6F])
    /// print(data.hex) // Output: "48656C6C6F"
    /// ```
    var hex: String {
        map { String(format: "%02hhX", $0) }.joined()
    }
}
