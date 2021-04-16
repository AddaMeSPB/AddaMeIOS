// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LocationClient",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "LocationClient",
      targets: ["LocationClient"]),
    .library(
      name: "LocationClientLive",
      targets: ["LocationClientLive"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "LocationClient",
      dependencies: []),
    .testTarget(
      name: "LocationClientTests",
      dependencies: ["LocationClient"]),
    .target(
      name: "LocationClientLive",
      dependencies: ["LocationClient"]),
  ]
)
