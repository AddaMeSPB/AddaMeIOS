// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

// swiftlint:disable file_length
let package = Package(
  name: "AddameSPM",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v14)
  ],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "AsyncImageLoder", targets: ["AsyncImageLoder"]),
    .library(name: "SwiftUIExtension", targets: ["SwiftUIExtension"]),
    .library(name: "InfoPlist", targets: ["InfoPlist"]),
    .library(name: "KeychainService", targets: ["KeychainService"]),
    .library(name: "SharedModels", targets: ["SharedModels"]),
    .library(name: "CoreDataStore", targets: ["CoreDataStore"]),
    .library(name: "FoundationExtension", targets: ["FoundationExtension"]),

    // Client
    .library(name: "UserNotificationClient", targets: ["UserNotificationClient"]),
    .library(name: "RemoteNotificationsClient", targets: ["RemoteNotificationsClient"]),
    .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
    .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),

    .library(name: "AttachmentClient", targets: ["AttachmentClient"]),
    .library(name: "AttachmentClientLive", targets: ["AttachmentClientLive"]),
    .library(name: "AuthClient", targets: ["AuthClient"]),
    .library(name: "AuthClientLive", targets: ["AuthClientLive"]),
    .library(name: "ChatClient", targets: ["ChatClient"]),
    .library(name: "ChatClientLive", targets: ["ChatClientLive"]),
    .library(name: "ContactClient", targets: ["ContactClient"]),
    .library(name: "ContactClientLive", targets: ["ContactClientLive"]),
    .library(name: "ConversationClient", targets: ["ConversationClient"]),
    .library(name: "ConversationClientLive", targets: ["ConversationClientLive"]),
    .library(name: "CoreDataClient", targets: ["CoreDataClient"]),
    .library(name: "EventClient", targets: ["EventClient"]),
    .library(name: "EventClientLive", targets: ["EventClientLive"]),
    .library(name: "PathMonitorClient", targets: ["PathMonitorClient"]),
    .library(name: "PathMonitorClientLive", targets: ["PathMonitorClientLive"]),
    .library(name: "UserClient", targets: ["UserClient"]),
    .library(name: "UserClientLive", targets: ["UserClientLive"]),
    .library(name: "WebSocketClient", targets: ["WebSocketClient"]),
    .library(name: "WebSocketClientLive", targets: ["WebSocketClientLive"]),
    .library(name: "LocationSearchClient", targets: ["LocationSearchClient"]),
    .library(name: "IDFAClient", targets: ["IDFAClient"]),
    .library(name: "IDFAClientLive", targets: ["IDFAClientLive"]),

    // Views
    .library(name: "AuthenticationView", targets: ["AuthenticationView"]),
    .library(name: "ChatView", targets: ["ChatView"]),
    .library(name: "ConversationsView", targets: ["ConversationsView"]),
    .library(name: "ContactsView", targets: ["ContactsView"]),
    .library(name: "EventView", targets: ["EventView"]),
    .library(name: "EventDetailsView", targets: ["EventDetailsView"]),
    .library(name: "EventFormView", targets: ["EventFormView"]),
    .library(name: "ProfileView", targets: ["ProfileView"]),
    .library(name: "TabsView", targets: ["TabsView"]),
    .library(name: "SettingsView", targets: ["SettingsView"]),
    .library(name: "MapView", targets: ["MapView"]),

    // Helpers
    .library(name: "NotificationHelpers", targets: ["NotificationHelpers"]),
    .library(name: "CombineHelpers", targets: ["CombineHelpers"]),
    .library(name: "ComposableArchitectureHelpers", targets: ["ComposableArchitectureHelpers"]),
    .library(name: "ImagePicker", targets: ["ImagePicker"])

  ],

  dependencies: [
//    .package(name: "AWSSDKSwift", url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.9.0"),
    .package(url: "https://github.com/soto-project/soto.git", from: "5.13.1"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.3")),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.36.0"),
    .package(url: "https://github.com/pointfreeco/composable-core-location.git", .branch("main")),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.1.0"),
    .package(url: "https://github.com/AddaMeSPB/CombineContacts.git", from: "1.0.0"),
//    .package(path: "../../HTTPRequestKit"),
    .package(url: "https://github.com/AddaMeSPB/HTTPRequestKit.git", from: "3.0.0"),
    .package(url: "https://github.com/darrarski/swift-composable-presentation.git", from: "0.3.0")
  ],

  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "UserNotificationClient", "RemoteNotificationsClient", "NotificationHelpers",
        "AuthClient", "AuthClientLive", "AttachmentClient", "ChatClient",
        "ConversationClient", "EventClient", "UserClient", "WebSocketClient",
        "EventView", "ConversationsView", "ProfileView", "TabsView",
        "AuthenticationView", "SettingsView", "ContactClient", "UserDefaultsClient",
        "KeychainService"
      ]
    ),

    .testTarget(
      name: "AppFeatureTests",
      dependencies: ["AppFeature"]
    ),

    // Core
    .target(name: "AsyncImageLoder"),
    .target(name: "SwiftUIExtension"),
    .target(
      name: "InfoPlist",
      resources: [.process("Resources/")]
    ),
    .target(name: "KeychainService"),
    .target(
      name: "SharedModels",
      dependencies: [
        "KeychainService", "FoundationExtension"
      ]
    ),
    .target(
      name: "CoreDataStore",
      dependencies: [
        "SharedModels", "FoundationExtension"
      ]
    ),
    .target(name: "FoundationExtension"),

    // Client
    .target(
      name: "RemoteNotificationsClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),

    .target(
      name: "UserNotificationClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),

    .target(
      name: "UIApplicationClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
      ]
    ),

    .target(
      name: "UserDefaultsClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
      ]
    ),

    .target(
      name: "CoreDataClient",
      dependencies: [
        "CoreDataStore", "ContactClient", "ContactClientLive", "SharedModels"
      ]
    ),

    .target(
      name: "AttachmentClient",
      dependencies: [
//        .product(name: "S3", package: "AWSSDKSwift"),
        .product(name: "SotoS3", package: "soto"),
        "SharedModels", "KeychainService", "FoundationExtension",
        "HTTPRequestKit", "InfoPlist"
      ]
    ),
    .target(name: "AttachmentClientLive", dependencies: ["AttachmentClient"]),

    .target(
      name: "AuthClient",
      dependencies: [
        "SharedModels", "InfoPlist", "FoundationExtension",
        "HTTPRequestKit", "PhoneNumberKit"
      ]
    ),
    .target(name: "AuthClientLive", dependencies: ["AuthClient"]),

    .target(
      name: "ChatClient",
      dependencies: [
        "SharedModels", "FoundationExtension", "HTTPRequestKit",
        "InfoPlist", "KeychainService"
      ]
    ),
    .target(name: "ChatClientLive", dependencies: ["ChatClient"]),

    .target(
      name: "ContactClient",
      dependencies: [
        "SharedModels", "InfoPlist", "FoundationExtension",
        "HTTPRequestKit", "PhoneNumberKit", "CombineContacts"
      ]
    ),
    .target(
      name: "ContactClientLive",
      dependencies: ["ContactClient", "CoreDataStore"]
    ),
    .target(
        name: "IDFAClient",
        dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]
    ),
    .target(
        name: "IDFAClientLive",
        dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "IDFAClient"
        ]),
    .target(
      name: "ConversationClient",
      dependencies: ["FoundationExtension", "HTTPRequestKit", "SharedModels"]
    ),
    .target(
      name: "ConversationClientLive",
      dependencies: ["ConversationClient", "KeychainService", "InfoPlist"]
    ),

    .target(
      name: "EventClient",
      dependencies: ["SharedModels", "HTTPRequestKit", "InfoPlist"]
    ),
    .target(
      name: "EventClientLive",
      dependencies: ["EventClient", "KeychainService"]
    ),

    .target(name: "PathMonitorClient"),
    .target(name: "PathMonitorClientLive", dependencies: ["PathMonitorClient"]),

    .target(
      name: "UserClient",
      dependencies: ["SharedModels", "HTTPRequestKit", "KeychainService", "InfoPlist"]
    ),
    .target(name: "UserClientLive", dependencies: ["UserClient"]),

    .target(
      name: "WebSocketClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "FoundationExtension", "HTTPRequestKit", "SharedModels", "InfoPlist", "KeychainService"
      ]
    ),
    .target(
      name: "WebSocketClientLive",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "WebSocketClient"
      ]
    ),

    .target(
      name: "LocationSearchClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),

    // Views
    .target(
      name: "AuthenticationView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "PhoneNumberKit", "SharedModels", "AuthClient", "KeychainService",
        "HTTPRequestKit", "AuthClientLive", "UserDefaultsClient"
      ],
      resources: [
        .process("Resources/PhoneNumberMetadata.json")
      ]
    ),
    .testTarget(
      name: "AuthenticationViewTests",
      dependencies: [
        "AuthenticationView",
        "PhoneNumberKit", "SharedModels", "AuthClient", "KeychainService",
        "HTTPRequestKit", "AuthClientLive"
      ]
    ),

    .target(
      name: "TabsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "AuthClient", "AuthClientLive", "UserClient", "UserClientLive",
        "EventClient", "EventClientLive", "AttachmentClient", "AttachmentClientLive",
        "PathMonitorClient", "PathMonitorClientLive", "ConversationClient",
        "ConversationClientLive",
        "EventView", "ConversationsView", "ProfileView",
        "SwiftUIExtension", "WebSocketClient", "WebSocketClientLive"
      ]
    ),

    .target(
      name: "ChatView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SharedModels", "InfoPlist", "KeychainService",
        "WebSocketClient", "ConversationClient", "ChatClient",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HTTPRequestKit", "ChatClientLive", "ConversationClientLive",
        "WebSocketClientLive"
      ]
    ),

    .target(
      name: "ConversationsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        "SharedModels", "InfoPlist", "KeychainService",
        "WebSocketClient", "ChatClient", "ChatClientLive",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HTTPRequestKit", "ConversationClient", "ConversationClientLive",
        "WebSocketClientLive", "ChatView", "ComposableArchitectureHelpers",
        "ContactClient", "ContactClientLive", "ContactsView", "CoreDataClient"
      ]
    ),

    .target(
      name: "ContactsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        "SharedModels", "AsyncImageLoder", "HTTPRequestKit",
        "ContactClient", "ContactClientLive", "WebSocketClient",
        "WebSocketClientLive", "ChatClient", "ChatClientLive",
        "CoreDataStore", "CoreDataClient",
        "ChatView", "ComposableArchitectureHelpers"
      ]
    ),

    .target(
      name: "EventView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        "SharedModels", "EventClient", "InfoPlist", "EventFormView",
        "PathMonitorClient", "WebSocketClient", "WebSocketClientLive",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HTTPRequestKit", "KeychainService", "ChatClient", "ChatView",
        "PathMonitorClientLive", "EventClientLive",
        "EventDetailsView", "ConversationClient", "ConversationClientLive",
        "UserDefaultsClient", "ComposableArchitectureHelpers",
        "IDFAClient", "IDFAClientLive"
      ]
    ),
    .testTarget(
      name: "EventViewTests",
      dependencies: [
        "EventView",
        "HTTPRequestKit",
        "KeychainService",
        "SharedModels",
        "PathMonitorClient",
        "PathMonitorClientLive",
        "UserDefaultsClient"
      ]
    ),

    .target(
      name: "EventFormView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        "SharedModels", "EventClient", "InfoPlist",
        "PathMonitorClient", "ConversationClient",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HTTPRequestKit", "KeychainService", "ChatClient", "EventClientLive",
        "PathMonitorClientLive", "MapView", "ComposableArchitectureHelpers"
      ]
    ),
    .testTarget(
      name: "EventFormViewTests",
      dependencies: [
        "EventFormView",
        "HTTPRequestKit",
        "KeychainService",
        "SharedModels"
      ]
    ),

    .target(
      name: "EventDetailsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        "SharedModels", "EventClient", "InfoPlist",
        "AsyncImageLoder", "SwiftUIExtension", "FoundationExtension",
        "HTTPRequestKit", "KeychainService", "ChatClient",
        "PathMonitorClient", "PathMonitorClientLive", "MapView", "ChatView",
        "ConversationClient", "ConversationClientLive", "ComposableArchitectureHelpers"
      ]
    ),

    .target(
      name: "ProfileView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        "AuthClient", "EventClient", "AttachmentClient",
        "InfoPlist", "UserClient", "SharedModels",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HTTPRequestKit", "KeychainService", "AuthenticationView",
        "AttachmentClientLive", "AuthClientLive", "UserClientLive",
        "EventClientLive", "SettingsView", "ComposableArchitectureHelpers",
        "ImagePicker"
      ]
      // resources: [.process("Images")]
    ),

    .target(
      name: "SettingsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        "UserNotificationClient", "UIApplicationClient", "UserDefaultsClient",
        "KeychainService", "SharedModels", "AuthenticationView"
      ]
    ),

    .target(
      name: "MapView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        "SwiftUIExtension", "SharedModels", "ComposableArchitectureHelpers"
      ]
    ),
    .testTarget(
      name: "MapViewTests",
      dependencies: ["MapView"]
    ),

    // Helpers
    .target(
      name: "NotificationHelpers",
      dependencies: [
        "UserNotificationClient", "RemoteNotificationsClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),

    .target(name: "CombineHelpers"),
    .target(
      name: "ComposableArchitectureHelpers",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),

    .target(
      name: "ImagePicker",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    )
  ]
)
