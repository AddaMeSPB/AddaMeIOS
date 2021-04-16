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
  name: "AttachmentClient",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "AttachmentClient",
      targets: ["AttachmentClient"]),
    .library(
      name: "AttachmentClientLive",
      targets: ["AttachmentClientLive"]),
  ],
  dependencies: [
    .package(path: "\(Path.Container.core)/KeychainService"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
    .package(name: "AWSSDKSwift", url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.9.0")
  ],
  targets: [
    .target(
      name: "AttachmentClient",
      dependencies: [
        .product(name: "S3", package: "AWSSDKSwift"),
        "AddaMeModels", "KeychainService", "FoundationExtension", "FuncNetworking", "InfoPlist"
      ]),
    .target(
      name: "AttachmentClientLive",
      dependencies: ["AttachmentClient"]),
    .testTarget(
      name: "AttachmentClientTests",
      dependencies: ["AttachmentClient"]),
  ]
)
