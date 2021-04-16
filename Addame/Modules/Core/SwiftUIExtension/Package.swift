// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftUIExtension",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "SwiftUIExtension",
      targets: ["SwiftUIExtension"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SwiftUIExtension",
      dependencies: []),
    .testTarget(
      name: "SwiftUIExtensionTests",
      dependencies: ["SwiftUIExtension"]),
  ]
)
