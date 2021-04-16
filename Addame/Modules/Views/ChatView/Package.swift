// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ChatView",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "ChatView",
      targets: ["ChatView"]),
  ],
  dependencies: [
    .package(path: "../Modules/Core/Common"),
  ],
  targets: [
    .target(
      name: "ChatView",
      dependencies: ["Common"],
      path: "Sources"
    ),
    .testTarget(
      name: "ChatViewTests",
      dependencies: ["ChatView"]),
  ]
)
