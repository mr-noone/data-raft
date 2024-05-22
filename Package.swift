// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let sqlitePkg = "sqlite3"
#else
let sqlitePkg: String? = nil
#endif

let package = Package(
    name: "DataRaft",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "DataRaft",
            targets: ["DataRaft"]
        ),
        .library(
            name: "SQLiteSwift",
            targets: ["SQLiteSwift"]
        )
    ],
    targets: [
        .systemLibrary(
            name: "SQLiteC",
            pkgConfig: sqlitePkg,
            providers: [
                .apt([
                    "sqlite3",
                    "libsqlite3-dev"
                ]),
                .brew(["sqlite"])
            ]
        ),
        .target(
            name: "SQLiteSwift",
            dependencies: [
                "SQLiteC"
            ]
        ),
        .testTarget(
            name: "SQLiteSwiftTests",
            dependencies: ["SQLiteSwift"],
            resources: [
                .copy("Resources/sample_script.sql"),
            ]
        ),
        .target(
            name: "DataRaft",
            dependencies: ["SQLiteSwift"],
            exclude: ["Deprecated"]
        ),
        .testTarget(
            name: "DataRaftTests",
            dependencies: ["DataRaft"]
        )
    ]
)
