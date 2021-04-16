// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KeychainService",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "KeychainService",
      targets: ["KeychainService"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "KeychainService",
      dependencies: []),
    .testTarget(
      name: "KeychainServiceTests",
      dependencies: ["KeychainService"]),
  ]
)
