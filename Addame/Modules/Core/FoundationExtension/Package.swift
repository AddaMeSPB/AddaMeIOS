// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FoundationExtension",
  platforms: [
    .iOS(.v14),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "FoundationExtension",
      targets: ["FoundationExtension"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "FoundationExtension",
      dependencies: []),
    .testTarget(
      name: "FoundationExtensionTests",
      dependencies: ["FoundationExtension"]),
  ]
)
