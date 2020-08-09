// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DataRaft",
  platforms: [
    .macOS(.v10_12),
    .iOS(.v10)
  ],
  products: [
    .library(name: "DataRaft", targets: ["DataRaft"])
  ],
  dependencies: [
    .package(name: "CSQLite", url: "https://github.com/mr-noone/csqlite.git", .exact("1.0.0"))
  ],
  targets: [
    .target(name: "DataRaft", dependencies: ["CSQLite"])
  ]
)
