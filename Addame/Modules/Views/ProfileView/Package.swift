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
  name: "ProfileView",
  platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ProfileView",
            targets: ["ProfileView"]),
    ],
    dependencies: [
      
      // Domains
      .package(path: "\(Path.Container.domains)/AddaMeModels"),
      
      // Core
      .package(path: "\(Path.Container.core)/AsyncImageLoder"),
      .package(path: "\(Path.Container.core)/FoundationExtension"),
      .package(path: "\(Path.Container.core)/FuncNetworking"),
      .package(path: "\(Path.Container.core)/InfoPlist"),
      .package(path: "\(Path.Container.core)/KeychainService"),
      .package(path: "\(Path.Container.core)/SwiftUIExtension"),
      
      // Services
      .package(path: "\(Path.Container.services)/AuthClient"),
      .package(path: "\(Path.Container.services)/AttachmentClient"),
      .package(path: "\(Path.Container.services)/EventClient"),
      .package(path: "\(Path.Container.services)/UserClient"),
      
      // Views
      .package(path: "\(Path.Container.views)/AuthenticationCore")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ProfileView",
            dependencies: [
              // Domains
              "AddaMeModels",
              
              // Services
              "AuthClient", "EventClient", "AttachmentClient",
              "InfoPlist", "UserClient",
              
              // Core
              "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
              "FuncNetworking", "KeychainService",
              
              // Views
              "AuthenticationCore",
              
              .product(name: "AttachmentClientLive", package: "AttachmentClient"),
              .product(name: "AuthClientLive", package: "AuthClient"),
              .product(name: "UserClientLive", package: "UserClient"),
              .product(name: "EventClientLive", package: "EventClient"),
              
            ]
        ),
        .testTarget(
            name: "ProfileViewTests",
            dependencies: ["ProfileView"]),
    ]
)
