// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "InfoPlist",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "InfoPlist",
      targets: ["InfoPlist"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "InfoPlist",
      dependencies: [],
      resources: [
        .copy("Resources/settings.plist")
      ]
    ),
    .testTarget(
      name: "InfoPlistTests",
      dependencies: ["InfoPlist"]),
  ]
)
