// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CombineContacts",
  platforms: [
    .iOS(.v14),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "CombineContacts",
      targets: ["CombineContacts"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "CombineContacts",
      dependencies: []),
    .testTarget(
      name: "CombineContactsTests",
      dependencies: ["CombineContacts"]),
  ]
)
