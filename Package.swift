// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var dependencies: [Package.Dependency] = [
  .package(name: "CSQLite", url: "https://github.com/mr-noone/csqlite.git", .upToNextMajor(from: "1.0.0")),
  .package(name: "SQLighter", url: "https://github.com/mr-noone/sqlighter.git", .upToNextMajor(from: "1.0.0"))
]
var targetDependencies: [Target.Dependency] = ["CSQLite", "SQLighter"]

#if os(Linux)
dependencies.append(.package(name: "Cryptor", url: "https://github.com/Kitura/BlueCryptor.git", from: "1.0.200"))
dependencies.append(.package(name: "OpenSSL", url: "https://github.com/Kitura/OpenSSL.git", from: "2.2.200"))
targetDependencies.append(.byName(name: "Cryptor"))
targetDependencies.append(.byName(name: "OpenSSL"))
#endif

let package = Package(
  name: "DataRaft",
  platforms: [
    .macOS(.v10_12),
    .iOS(.v10)
  ],
  products: [
    .library(name: "DataRaft", targets: ["DataRaft"])
  ],
  dependencies: dependencies,
  targets: [
    .target(name: "DataRaft", dependencies: targetDependencies),
    .testTarget(name: "DataRaftTests", dependencies: ["DataRaft"])
  ]
)
