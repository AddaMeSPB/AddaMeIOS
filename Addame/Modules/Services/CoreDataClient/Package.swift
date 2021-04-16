// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Path {
  static let modules = "../Modules"
  enum Container {
    static let core = "\(Path.modules)/Core"
    static let domain = "\(Path.modules)/Domain"
    static let services = "\(Path.modules)/Services"
  }
}

let package = Package(
  name: "CoreDataClient",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "CoreDataClient",
      targets: ["CoreDataClient"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.core)/CoreDataStore"),
    .package(path: "\(Path.Container.services)/ContactClient"),
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
  ],
  targets: [
    .target(
      name: "CoreDataClient",
      dependencies: [
        "CoreDataStore", "ContactClient", "AddaMeModels",
        .product(name: "ContactClientLive", package: "ContactClient"),
      ]),
    .testTarget(
      name: "CoreDataClientTests",
      dependencies: ["CoreDataClient"]),
  ]
)
