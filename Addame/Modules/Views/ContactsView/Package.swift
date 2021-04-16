// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Path {
  static let modules = "../Modules"
  enum Container {
    static let core = "\(Path.modules)/Core"
    static let domain = "\(Path.modules)/Domain"
    static let services = "\(Path.modules)/Services"
    static let views = "\(Path.modules)/Views"
  }
}

let package = Package(
  name: "ContactsView",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "ContactsView",
      targets: ["ContactsView"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/AsyncImageLoder"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.services)/ContactClient"),
    .package(path: "\(Path.Container.core)/CoreDataStore"),
    .package(path: "\(Path.Container.services)/CoreDataClient")
  ],
  targets: [
    .target(
      name: "ContactsView",
      dependencies: [
        "AddaMeModels", "AsyncImageLoder", "FuncNetworking", "ContactClient",
        "CoreDataStore", "CoreDataClient",
        .product(name: "ContactClientLive", package: "ContactClient"),
      ]),
    .testTarget(
      name: "ContactsViewTests",
      dependencies: ["ContactsView"]),
  ]
)
