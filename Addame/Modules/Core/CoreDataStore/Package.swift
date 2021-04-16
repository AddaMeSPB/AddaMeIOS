// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Path {
  static let modules = "../Modules"
  enum Container {
    static let domain = "\(Path.modules)/Domain"
  }
}

let package = Package(
  name: "CoreDataStore",
  platforms: [
    .iOS(.v14),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "CoreDataStore",
      targets: ["CoreDataStore"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.domain)/AddaMeModels")
  ],
  targets: [
    .target(
      name: "CoreDataStore",
      dependencies: ["AddaMeModels"]),
    .testTarget(
      name: "CoreDataStoreTests",
      dependencies: ["CoreDataStore"]),
  ]
)
