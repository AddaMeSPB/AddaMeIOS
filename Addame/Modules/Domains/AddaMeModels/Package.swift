// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Path {
  static let modules = "../Modules"
  enum Container {
    static let core = "\(Path.modules)/Core"
  }
}

let package = Package(
  name: "AddaMeModels",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "AddaMeModels",
      targets: ["AddaMeModels"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.core)/KeychainService"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
  ],
  
  targets: [
    .target(
      name: "AddaMeModels",
      dependencies: ["KeychainService", "FoundationExtension"]),
    .testTarget(
      name: "AddaMeModelsTests",
      dependencies: ["AddaMeModels"]),
  ]
)
