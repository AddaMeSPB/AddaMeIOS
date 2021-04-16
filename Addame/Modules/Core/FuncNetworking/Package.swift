// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FuncNetworking",
  platforms: [
    .iOS(.v14),
    .macOS(.v10_15),
    .tvOS(.v10),
    .watchOS(.v3)
  ],
  products: [
    .library(
      name: "FuncNetworking",
      targets: ["FuncNetworking"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "FuncNetworking",
      dependencies: []),
    .testTarget(
      name: "FuncNetworkingTests",
      dependencies: ["FuncNetworking"]),
  ]
)
