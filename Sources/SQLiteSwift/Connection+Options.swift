import Foundation
import SQLiteC

extension Connection {
    /// Options for controlling the connection to a SQLite database.
    ///
    /// This type represents a set of options that can be used when opening a connection to a SQLite database.
    /// Each option corresponds to one of the flags defined in the SQLite library.
    /// For more details read [Opening A New Database Connection](https://www.sqlite.org/c3ref/open.html).
    public struct Options: OptionSet {
        /// An integer value representing a combination of option flags.
        public var rawValue: Int32
        
        /// Option: open the database for read-only access.
        ///
        /// The database is opened in read-only mode. If the database does not already exist, an error is returned.
        public static let readonly = Self(rawValue: SQLITE_OPEN_READONLY)
        
        /// Option: open the database for reading and writing.
        ///
        /// The database is opened for reading and writing if possible, or reading only if the file is write protected by the
        /// operating system. In either case the database must already exist, otherwise an error is returned. For historical
        /// reasons, if opening in read-write mode fails due to OS-level permissions, an attempt is made to
        /// open it in read-only mode.
        public static let readwrite = Self(rawValue: SQLITE_OPEN_READWRITE)
        
        /// Option: create the database if it does not exist.
        public static let create = Self(rawValue: SQLITE_OPEN_CREATE)
        
        /// Option: specify a URI for opening the database.
        ///
        /// The filename can be interpreted as a URI if this flag is set.
        public static let uri = Self(rawValue: SQLITE_OPEN_URI)
        
        /// Option: open the database in memory.
        ///
        /// The database will be opened as an in-memory database. The database is named by the "filename" argument
        /// for the purposes of cache-sharing, if shared cache mode is enabled, but the "filename" is otherwise ignored.
        public static let memory = Self(rawValue: SQLITE_OPEN_MEMORY)
        
        /// Option: do not use mutexes.
        ///
        /// The new database connection will use the "multi-thread" [threading mode](https://www.sqlite.org/threadsafe.html).
        /// This means that separate threads are allowed to use SQLite at the same time, as long as each thread is using
        /// a different [database connection](https://www.sqlite.org/c3ref/sqlite3.html).
        public static let nomutex = Self(rawValue: SQLITE_OPEN_NOMUTEX)
        
        /// Option: use full mutexing.
        ///
        /// The new database connection will use the "serialized" [threading mode](https://www.sqlite.org/threadsafe.html).
        /// This means the multiple threads can safely attempt to use the same database connection at the same time.
        /// (Mutexes will block any actual concurrency, but in this mode there is no harm in trying.)
        public static let fullmutex = Self(rawValue: SQLITE_OPEN_FULLMUTEX)
        
        /// Option: use a shared cache.
        ///
        /// The database is opened [shared cache](https://www.sqlite.org/sharedcache.html) enabled.
        /// [The use of shared cache mode is discouraged](https://www.sqlite.org/sharedcache.html#dontuse)
        /// and hence shared cache capabilities may be omitted from many builds of SQLite. In such cases, this option is a no-op.
        public static let sharedcache = Self(rawValue: SQLITE_OPEN_SHAREDCACHE)
        
        /// Option: use a private cache.
        ///
        /// The database is opened [shared cache](https://www.sqlite.org/sharedcache.html) disabled.
        public static let privatecache = Self(rawValue: SQLITE_OPEN_PRIVATECACHE)
        
        /// Option: use extended result code mode.
        ///
        /// The database connection comes up in "extended result code mode".
        public static let exrescode = Self(rawValue: SQLITE_OPEN_EXRESCODE)
        
        /// Option: do not follow symbolic links when opening a file.
        ///
        /// The database filename is not allowed to contain a symbolic link.
        public static let nofollow = Self(rawValue: SQLITE_OPEN_NOFOLLOW)
        
        /// Initializes a set of options for connecting to a SQLite database.
        /// - Parameter rawValue: An integer value representing a combination of option flags.
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
