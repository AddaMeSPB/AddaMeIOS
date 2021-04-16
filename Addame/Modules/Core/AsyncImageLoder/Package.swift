// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AsyncImageLoder",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "AsyncImageLoder",
      targets: ["AsyncImageLoder"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "AsyncImageLoder",
      dependencies: []),
    .testTarget(
      name: "AsyncImageLoderTests",
      dependencies: ["AsyncImageLoder"]),
  ]
)
