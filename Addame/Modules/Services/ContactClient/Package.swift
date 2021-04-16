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
  name: "ContactClient",
  platforms: [
    .iOS(.v14),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "ContactClient",
      targets: ["ContactClient"]),
    .library(
      name: "ContactClientLive",
      targets: ["ContactClientLive"])
  ],
  dependencies: [
    .package(path: "\(Path.Container.domain)/AddaMeModels"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
    .package(path: "\(Path.Container.core)/CombineContacts"),
    .package(path: "\(Path.Container.core)/CoreDataStore"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.3"))
  ],
  targets: [
    .target(
      name: "ContactClient",
      dependencies: ["AddaMeModels", "InfoPlist", "FoundationExtension", "FuncNetworking", "PhoneNumberKit", "CombineContacts"]),
    
    .target(
      name: "ContactClientLive",
      dependencies: ["ContactClient", "CoreDataStore"]),
    
    .testTarget(
      name: "ContactClientTests",
      dependencies: ["ContactClient"]),
  ]
)
