// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Path {
  static let modules = "../Modules"
  enum Container {
    static let core = "\(Path.modules)/Core"
    static let domains = "\(Path.modules)/Domains"
    static let services = "\(Path.modules)/Services"
    static let views = "\(Path.modules)/Views"
  }
}

let package = Package(
  name: "AuthenticationCore",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "AuthenticationCore",
      targets: ["AuthenticationCore"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.core)/Common"),
    .package(path: "\(Path.Container.core)/PhoneNumberCommon"),
    .package(path: "\(Path.Container.domains)/AddaMeModels"),
    .package(path: "\(Path.Container.services)/AuthClient")
  ],
  targets: [
    .target(
      name: "AuthenticationCore",
      dependencies: [
        "Common", "PhoneNumberCommon", "AddaMeModels", "AuthClient",
        .product(name: "AuthClientLive", package: "AuthClient"),
      ]),
    .testTarget(
      name: "AuthenticationCoreTests",
      dependencies: ["AuthenticationCore"]),
  ]
)
