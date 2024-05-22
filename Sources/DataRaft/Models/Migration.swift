import Foundation

/// Represents a database migration script.
///
/// A `Migration` instance encapsulates information about a database migration script,
/// including its version number and the URL to the script file.
public struct Migration: Hashable {
    /// The version number of the migration.
    public let version: Int32
    
    /// The URL to the migration script file.
    public let scriptURL: URL
    
    /// Initializes a `Migration` instance with the specified version and script URL.
    ///
    /// - Parameters:
    ///   - version: The version number of the migration.
    ///   - scriptURL: The URL to the migration script file.
    public init(version: Int32, scriptURL: URL) {
        self.version = version
        self.scriptURL = scriptURL
    }
    
    /// Initializes a `Migration` instance with the specified version and script URL
    /// by resource name and extension.
    ///
    /// - Parameters:
    ///   - version: The version number of the migration.
    ///   - name: The name of the resource file containing the migration script.
    ///   - extension: The file extension of the resource file. Default is `nil`.
    ///   - bundle: The bundle from which to load the resource file. Default is the main bundle.
    /// - Returns: A `Migration` instance or nil if the script file could nit be located.
    public init?(
        version: Int32,
        byResource name: String?,
        extension: String? = nil,
        in bundle: Bundle = .main
    ) {
        guard let url = bundle.url(
            forResource: name,
            withExtension: `extension`
        ) else { return nil }
        self.init(version: version, scriptURL: url)
    }
}
