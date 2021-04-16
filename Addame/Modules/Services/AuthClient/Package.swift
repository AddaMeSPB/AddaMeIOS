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
  name: "AuthClient",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "AuthClient",
      targets: ["AuthClient"]),
    .library(
      name: "AuthClientLive",
      targets: ["AuthClientLive"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.3")),
  ],
  targets: [
    .target(
      name: "AuthClient",
      dependencies: ["AddaMeModels", "InfoPlist", "FoundationExtension", "FuncNetworking", "PhoneNumberKit"]),
    .target(
      name: "AuthClientLive",
      dependencies: ["AuthClient"]),
    .testTarget(
      name: "AuthClientTests",
      dependencies: ["AuthClient"]),
  ]
)
