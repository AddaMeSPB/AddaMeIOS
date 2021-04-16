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
  name: "ChatClient",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "ChatClient",
      targets: ["ChatClient"]),
    .library(
      name: "ChatClientLive",
      targets: ["ChatClientLive"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
    .package(path: "\(Path.Container.core)/KeychainService"),
  ],
  targets: [
    .target(
      name: "ChatClient",
      dependencies: ["AddaMeModels", "FoundationExtension", "FuncNetworking", "InfoPlist", "KeychainService"]),
    
    .target(
      name: "ChatClientLive",
      dependencies: ["ChatClient"]),
    
    .testTarget(
      name: "ChatClientTests",
      dependencies: ["ChatClient"]),
  ]
)
