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
  name: "EventView",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "EventView",
      targets: ["EventView"]),
  ],
  dependencies: [
    
    // Domains
    .package(path: "\(Path.Container.domains)/AddaMeModels"),
    
    // Core
    .package(path: "\(Path.Container.core)/Common"),
    .package(path: "\(Path.Container.core)/AsyncImageLoder"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
    .package(path: "\(Path.Container.core)/KeychainService"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
    .package(path: "\(Path.Container.core)/SwiftUIExtension"),
    
    // Services
    .package(path: "\(Path.Container.services)/PathMonitorClient"),
    .package(path: "\(Path.Container.services)/WebsocketClient"),
    .package(path: "\(Path.Container.services)/ConversationClient"),
    .package(path: "\(Path.Container.services)/ChatClient"),
    .package(path: "\(Path.Container.services)/EventClient"),
    
    // Views
    
    
  ],
  targets: [
    .target(
      name: "EventView",
      dependencies: [
        
        // Domains
        "AddaMeModels",
        
        // Services
        "EventClient", "InfoPlist", "Common",
        "PathMonitorClient", "WebsocketClient", "ConversationClient",
        "ChatClient",
        
        // Core
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "FuncNetworking", "KeychainService",
        
        // Views
        
        // Live
        .product(name: "PathMonitorClientLive", package: "PathMonitorClient"),
        .product(name: "EventClientLive", package: "EventClient"),
      
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "EventViewTests",
      dependencies: ["EventView"]),
  ]
)
