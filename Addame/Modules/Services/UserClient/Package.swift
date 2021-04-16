// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Path {
  static let modules = "../Modules"
  enum Container {
    static let core = "\(Path.modules)/Core"
    static let domain = "\(Path.modules)/Domain"
  }
}

let package = Package(
  name: "UserClient",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "UserClient",
      targets: ["UserClient"]),
    .library(
      name: "UserClientLive",
      targets: ["UserClientLive"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
    .package(path: "\(Path.Container.core)/KeychainService"),
  ],
  targets: [
    .target(
      name: "UserClient",
      dependencies: ["AddaMeModels", "FuncNetworking", "KeychainService", "InfoPlist"]),
    .target(
      name: "UserClientLive",
      dependencies: ["UserClient"]),
    .testTarget(
      name: "UserClientTests",
      dependencies: ["UserClient"]),
  ]
)
