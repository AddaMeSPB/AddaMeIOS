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
  name: "EventClient",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "EventClient",
      targets: ["EventClient"]),
    .library(
      name: "EventClientLive",
      targets: ["EventClientLive"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
    .package(path: "\(Path.Container.core)/KeychainService"),
  ],
  targets: [
    .target(
      name: "EventClient",
      dependencies: ["AddaMeModels","FuncNetworking", "InfoPlist"]
    ),
    
    .target(
      name: "EventClientLive",
      dependencies: ["EventClient", "KeychainService"]),
    .testTarget(
      name: "EventClientTests",
      dependencies: ["EventClient"]),
  ]
)
