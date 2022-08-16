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
    .library(name: "AppDelegate", targets: ["AppDelegate"]),
    .library(name: "AsyncImageLoder", targets: ["AsyncImageLoder"]),
    .library(name: "SwiftUIExtension", targets: ["SwiftUIExtension"]),
    .library(name: "InfoPlist", targets: ["InfoPlist"]),
    .library(name: "KeychainService", targets: ["KeychainService"]),
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
    .library(name: "DeviceClient", targets: ["DeviceClient"]),
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
    .library(name: "MyEventsView", targets: ["MyEventsView"]),

    // Helpers
    .library(name: "NotificationHelpers", targets: ["NotificationHelpers"]),
    .library(name: "CombineHelpers", targets: ["CombineHelpers"]),
    .library(name: "ComposableArchitectureHelpers", targets: ["ComposableArchitectureHelpers"]),
    .library(name: "ImagePicker", targets: ["ImagePicker"])

  ],

  dependencies: [
//    .package(name: "AWSSDKSwift", url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.9.0"),
    .package(url: "https://github.com/AddaMeSPB/adda-shared-models", .branch("route")),
    .package(url: "https://github.com/soto-project/soto.git", from: "5.13.1"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.3")),
    .package(
        url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.40.2"),
    .package(url: "https://github.com/pointfreeco/composable-core-location.git", .branch("main")),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.1.0"),
    .package(url: "https://github.com/AddaMeSPB/CombineContacts.git", .branch("async")),
    .package(url: "https://github.com/AddaMeSPB/HTTPRequestKit.git", from: "3.0.0"),
    .package(url: "https://github.com/saroar/swift-composable-presentation.git", .branch("foundation"))
  ],

  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "UserNotificationClient", "RemoteNotificationsClient", "NotificationHelpers",
        "AuthClient", "AuthClientLive", "AttachmentClient", "ChatClient",
        "ConversationClient", "EventClient", "WebSocketClient",
        "EventView", "ConversationsView", "ProfileView", "TabsView",
        "AuthenticationView", "SettingsView", "ContactClient", "UserDefaultsClient",
        "KeychainService", "AppDelegate", "UserClient", "UserClientLive"
      ]
    ),

    .testTarget(
      name: "AppFeatureTests",
      dependencies: ["AppFeature"]
    ),

    .target(
        name: "AppDelegate",
        dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            .product(name: "AddaSharedModels", package: "adda-shared-models"),
            "KeychainService", "FoundationExtension",
            "HTTPRequestKit", "InfoPlist", "DeviceClient", "CombineHelpers",
            "RemoteNotificationsClient", "NotificationHelpers"
        ]
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
      name: "CoreDataStore",
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "FoundationExtension"
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
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "CoreDataStore", "ContactClient", "ContactClientLive"
      ]
    ),

    .target(
        name: "DeviceClient",
        dependencies: [
            .product(name: "AddaSharedModels", package: "adda-shared-models"),
            "KeychainService", "FoundationExtension", "InfoPlist"
        ]
    ),

    .target(
      name: "AttachmentClient",
      dependencies: [
//        .product(name: "S3", package: "AWSSDKSwift"),
        .product(name: "SotoS3", package: "soto"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "KeychainService", "FoundationExtension",
        "HTTPRequestKit", "InfoPlist"
      ]
    ),
    .target(name: "AttachmentClientLive", dependencies: ["AttachmentClient"]),

    .target(
      name: "AuthClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "InfoPlist", "FoundationExtension", "PhoneNumberKit"
      ]
    ),
    .target(name: "AuthClientLive", dependencies: ["AuthClient"]),

    .target(
      name: "ChatClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "FoundationExtension", "HTTPRequestKit",
        "InfoPlist", "KeychainService"
      ]
    ),
    .target(name: "ChatClientLive", dependencies: ["ChatClient"]),

    .target(
      name: "ContactClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "InfoPlist", "FoundationExtension",
        "HTTPRequestKit", "PhoneNumberKit", "CombineContacts"
      ]
    ),
    .target(
      name: "ContactClientLive",
      dependencies: ["ContactClient", "CoreDataStore", "KeychainService"]
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
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "FoundationExtension", "HTTPRequestKit", "KeychainService", "InfoPlist"
      ]
    ),
    .target(
      name: "ConversationClientLive",
      dependencies: ["ConversationClient"]
    ),

    .target(
      name: "EventClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "HTTPRequestKit", "InfoPlist", "KeychainService", "FoundationExtension"
      ]
    ),
    .target(
      name: "EventClientLive",
      dependencies: ["EventClient"]
    ),

    .target(name: "PathMonitorClient"),
    .target(name: "PathMonitorClientLive", dependencies: ["PathMonitorClient"]),

    .target(
      name: "UserClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "HTTPRequestKit", "KeychainService", "InfoPlist"
      ]
    ),
    .target(name: "UserClientLive", dependencies: ["UserClient"]),

    .target(
      name: "WebSocketClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "FoundationExtension", "HTTPRequestKit", "InfoPlist", "KeychainService"
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
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "PhoneNumberKit", "AuthClient", "KeychainService",
        "HTTPRequestKit", "AuthClientLive", "UserDefaultsClient"
      ],
      resources: [
        .process("Resources/PhoneNumberMetadata.json")
      ]
    ),
    .testTarget(
      name: "AuthenticationViewTests",
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "AuthenticationView",
        "PhoneNumberKit", "AuthClient", "KeychainService",
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
        "SwiftUIExtension", "WebSocketClient", "WebSocketClientLive",
        "DeviceClient", "CombineHelpers", "NotificationHelpers"
      ]
    ),

    .target(
      name: "ChatView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "InfoPlist", "KeychainService",
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
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "InfoPlist", "KeychainService",
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
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "AsyncImageLoder", "HTTPRequestKit",
        "ContactClient", "ContactClientLive", "WebSocketClient",
        "WebSocketClientLive", "ChatClient", "ChatClientLive",
        "CoreDataStore", "CoreDataClient",
        "ChatView", "ComposableArchitectureHelpers"
      ]
    ),

    .testTarget(
      name: "ContactsViewTests",
      dependencies: [
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "AsyncImageLoder", "HTTPRequestKit",
        "ContactClient", "ContactClientLive", "WebSocketClient",
        "WebSocketClientLive", "ChatClient", "ChatClientLive",
        "CoreDataStore", "CoreDataClient",
        "ChatView", "ComposableArchitectureHelpers", "ContactsView"
      ]
    ),

    .target(
      name: "EventView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "EventClient", "InfoPlist", "EventFormView",
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
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "EventView", "HTTPRequestKit", "KeychainService",
        "PathMonitorClient", "PathMonitorClientLive", "UserDefaultsClient"
      ]
    ),

    .target(
      name: "EventFormView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "EventClient", "InfoPlist",
        "PathMonitorClient", "ConversationClient",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HTTPRequestKit", "KeychainService", "ChatClient", "EventClientLive",
        "PathMonitorClientLive", "MapView", "ComposableArchitectureHelpers"
      ]
    ),

//    .testTarget(
//      name: "EventFormViewTests",
//      dependencies: [
//        .product(name: "AddaSharedModels", package: "adda-shared-models"),
//        "EventFormView", "HTTPRequestKit", "KeychainService",
//      ]
//    ),

    .target(
        name: "MyEventsView",
        dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "EventClient", "EventClientLive", "InfoPlist",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HTTPRequestKit", "KeychainService"
        ]
    ),

    .target(
      name: "EventDetailsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "EventClient", "InfoPlist",
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
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "AuthClient", "EventClient", "AttachmentClient",
        "InfoPlist", "UserClient",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HTTPRequestKit", "KeychainService", "AuthenticationView",
        "AttachmentClientLive", "AuthClientLive", "UserClientLive",
        "EventClientLive", "SettingsView", "ComposableArchitectureHelpers",
        "ImagePicker", "MyEventsView"
      ]
      // resources: [.process("Images")]
    ),

    .target(
      name: "SettingsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "UserNotificationClient", "UIApplicationClient", "UserDefaultsClient",
        "KeychainService", "AuthenticationView"
      ]
    ),

    .target(
      name: "MapView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "adda-shared-models"),
        "SwiftUIExtension", "ComposableArchitectureHelpers"
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
