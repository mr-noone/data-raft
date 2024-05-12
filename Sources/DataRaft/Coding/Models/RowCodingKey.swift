import Foundation

/// A custom `CodingKey` implementation used for encoding and decoding SQLite rows.
struct RowCodingKey: CodingKey {
    // MARK: - Properties
    
    /// The string value of the coding key.
    var stringValue: String
    
    /// The integer value of the coding key.
    var intValue: Int?
    
    // MARK: - Initializers
    
    /// Initializes a `RowCodingKey` with the given string value.
    /// - Parameter stringValue: The string value of the coding key.
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    /// Initializes a `RowCodingKey` with the given integer value.
    /// - Parameter intValue: The integer value of the coding key.
    init(intValue: Int) {
        self.stringValue = "Index \(intValue)"
        self.intValue = intValue
    }
}
