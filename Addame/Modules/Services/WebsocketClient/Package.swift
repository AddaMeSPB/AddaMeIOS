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
  name: "WebsocketClient",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "WebsocketClient",
      targets: ["WebsocketClient"]),
    
    .library(
      name: "WebsocketClientLive",
      targets: ["WebsocketClientLive"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
    .package(path: "\(Path.Container.core)/KeychainService"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
  ],
  targets: [
    .target(
      name: "WebsocketClient",
      dependencies: ["FoundationExtension", "FuncNetworking", "AddaMeModels", "InfoPlist", "KeychainService"]),
    
    .target(
      name: "WebsocketClientLive",
      dependencies: ["WebsocketClient"]),
    
    .testTarget(
      name: "WebsocketClientTests",
      dependencies: ["WebsocketClient"]),
  ]
)
