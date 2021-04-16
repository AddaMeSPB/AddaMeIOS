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
  name: "AddameSPM",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "AddameSPM",
      targets: ["AddameSPM"]),
  ],
  dependencies: [
    
    // CORE
    .package(path: "\(Path.Container.core)/Common"),
    .package(path: "\(Path.Container.core)/PhoneNumberCommon"),
    .package(path: "\(Path.Container.core)/AsyncImageLoder"),
    .package(path: "\(Path.Container.core)/FoundationExtension"),
    .package(path: "\(Path.Container.core)/FuncNetworking"),
    .package(path: "\(Path.Container.core)/InfoPlist"),
    .package(path: "\(Path.Container.core)/KeychainService"),
    .package(path: "\(Path.Container.core)/SwiftUIExtension"),
    .package(path: "\(Path.Container.core)/CoreDataStore"),
    .package(path: "\(Path.Container.core)/CombineContacts"),
    .package(path: "\(Path.Container.domains)/AddaMeModels"),
    
    // Services
    .package(path: "\(Path.Container.services)/AttachmentClient"),
    .package(path: "\(Path.Container.services)/AuthClient"),
    .package(path: "\(Path.Container.services)/ChatClient"),
    .package(path: "\(Path.Container.services)/ConversationClient"),
    .package(path: "\(Path.Container.services)/ContactClient"),
    .package(path: "\(Path.Container.services)/CoreDataClient"),
    .package(path: "\(Path.Container.services)/EventClient"),
    .package(path: "\(Path.Container.services)/PathMonitorClient"),
    .package(path: "\(Path.Container.services)/UserClient"),
    .package(path: "\(Path.Container.services)/WebsocketClient"),
    
    // Views
    .package(path: "\(Path.Container.views)/Tabs"),
    .package(path: "\(Path.Container.views)/EventView"),
    .package(path: "\(Path.Container.views)/ChatView"),
    .package(path: "\(Path.Container.views)/ProfileView"),
    .package(path: "\(Path.Container.views)/AuthenticationCore"),
    .package(path: "\(Path.Container.views)/ContactsView")
    
  ],
  targets: [
    .target(
      name: "AddameSPM",
      dependencies: [
        // CORE
        "AsyncImageLoder", "Common", "PhoneNumberCommon", "FuncNetworking",
        "InfoPlist", "KeychainService", "SwiftUIExtension", "FoundationExtension",
        "CombineContacts", "CoreDataStore",
        
        // DOMAINS
        "AddaMeModels",
        
        // Services
        "AttachmentClient", "AuthClient", "ChatClient", "ConversationClient",
        "ContactClient", "CoreDataClient", "EventClient",
        "PathMonitorClient", "UserClient", "WebsocketClient",
        .product(name: "AttachmentClientLive", package: "AttachmentClient"),
        .product(name: "AuthClientLive", package: "AuthClient"),
        .product(name: "ChatClientLive", package: "ChatClient"),
        .product(name: "ConversationClientLive", package: "ConversationClient"),
        .product(name: "ContactClientLive", package: "ContactClient"),
        .product(name: "EventClientLive", package: "EventClient"),
        .product(name: "PathMonitorClientLive", package: "PathMonitorClient"),
        .product(name: "UserClientLive", package: "UserClient"),
        .product(name: "WebsocketClientLive", package: "WebsocketClient"),
        
        // View
        "Tabs", "EventView", "ChatView", "ProfileView", "ContactsView", "AuthenticationCore"
        
      ]),
    .testTarget(
      name: "AddameSPMTests",
      dependencies: ["AddameSPM"]),
  ]
)
