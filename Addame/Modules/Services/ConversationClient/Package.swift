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
  name: "ConversationClient",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "ConversationClient",
      targets: ["ConversationClient"]),
    .library(
      name: "ConversationClientLive",
      targets: ["ConversationClientLive"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.core)/Common"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
    .package(path: "\(Path.Container.core)/KeychainService"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
  ],
  targets: [
    .target(
      name: "ConversationClient",
      dependencies: ["Common", "FoundationExtension","FuncNetworking", "AddaMeModels"]),
    .target(
      name: "ConversationClientLive",
      dependencies: ["ConversationClient", "KeychainService", "InfoPlist"]),
    .testTarget(
      name: "ConversationClientTests",
      dependencies: ["ConversationClient"]),
  ]
)
