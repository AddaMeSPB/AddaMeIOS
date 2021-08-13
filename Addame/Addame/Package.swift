// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
  name: "Addame",
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
    .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),
    .library(name: "CombineHelpers", targets: ["CombineHelpers"]),
    .library(name: "ComposableArchitectureHelpers", targets: ["ComposableArchitectureHelpers"])

  ],

  dependencies: [
    .package(name: "AWSSDKSwift", url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.9.0"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.3")),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.21.0"),
    .package(url: "https://github.com/pointfreeco/composable-core-location", from: "0.1.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.1.0"),
    .package(url: "https://github.com/AddaMeSPB/CombineContacts.git", from: "1.0.0"),
    .package(url: "https://github.com/AddaMeSPB/HttpRequest.git", from: "2.2.0")
  ],

  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "UserNotificationClient", "RemoteNotificationsClient", "NotificationHelpers",
        "AuthClient", "AuthClientLive", "AttachmentClient", "ChatClient", "ContactClient",
        "ConversationClient", "EventClient", "UserClient", "WebSocketClient",

        "EventView", "ConversationsView", "ProfileView", "TabsView", "AuthenticationView",
        "SettingsView"
      ]),

    .testTarget(
      name: "AppFeatureTests",
      dependencies: ["AppFeature"]),

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
      ]),

    .target(
      name: "UserNotificationClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]),

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
      ]),

    .target(
      name: "AttachmentClient",
      dependencies: [
        .product(name: "S3", package: "AWSSDKSwift"),
        "SharedModels", "KeychainService", "FoundationExtension",
        "HttpRequest", "InfoPlist"
      ]),
    .target(name: "AttachmentClientLive", dependencies: ["AttachmentClient"]),

    .target(
      name: "AuthClient",
      dependencies: [
        "SharedModels", "InfoPlist", "FoundationExtension",
        "HttpRequest", "PhoneNumberKit"
      ]),
    .target(name: "AuthClientLive", dependencies: ["AuthClient"]),

    .target(
      name: "ChatClient",
      dependencies: [
        "SharedModels", "FoundationExtension", "HttpRequest",
        "InfoPlist", "KeychainService"
      ]),
    .target(name: "ChatClientLive", dependencies: ["ChatClient"]),

    .target(
      name: "ContactClient",
      dependencies: [
        "SharedModels", "InfoPlist", "FoundationExtension",
        "HttpRequest", "PhoneNumberKit", "CombineContacts"
      ]),
    .target(
      name: "ContactClientLive",
      dependencies: ["ContactClient", "CoreDataStore"]),

    .target(
      name: "ConversationClient",
      dependencies: ["FoundationExtension", "HttpRequest", "SharedModels"]),
    .target(
      name: "ConversationClientLive",
      dependencies: ["ConversationClient", "KeychainService", "InfoPlist"]),

    .target(
      name: "EventClient",
      dependencies: ["SharedModels", "HttpRequest", "InfoPlist"]
    ),
    .target(
      name: "EventClientLive",
      dependencies: ["EventClient", "KeychainService"]),

    .target(name: "PathMonitorClient"),
    .target(name: "PathMonitorClientLive", dependencies: ["PathMonitorClient"]),

    .target(
      name: "UserClient",
      dependencies: ["SharedModels", "HttpRequest", "KeychainService", "InfoPlist"]),
    .target(name: "UserClientLive", dependencies: ["UserClient"]),

    .target(
      name: "WebSocketClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "FoundationExtension", "HttpRequest", "SharedModels", "InfoPlist", "KeychainService"
      ]),
    .target(
      name: "WebSocketClientLive",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "WebSocketClient"
      ]),

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
        "HttpRequest", "AuthClientLive"
      ]),

    .target(
      name: "TabsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "AuthClient", "AuthClientLive", "UserClient", "UserClientLive",
        "EventClient", "EventClientLive", "AttachmentClient", "AttachmentClientLive",
        "PathMonitorClient", "PathMonitorClientLive", "ConversationClient", "ConversationClientLive",
        "EventView", "ConversationsView", "ProfileView",
        "SwiftUIExtension", "WebSocketClient", "WebSocketClientLive"
      ]),

    .target(
      name: "ChatView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SharedModels", "InfoPlist", "KeychainService",
        "WebSocketClient", "ConversationClient", "ChatClient",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HttpRequest", "ChatClientLive", "ConversationClientLive",
        "WebSocketClientLive"
      ]
    ),

    .target(
      name: "ConversationsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SharedModels", "InfoPlist", "KeychainService",
        "WebSocketClient", "ChatClient", "ChatClientLive",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HttpRequest", "ConversationClient", "ConversationClientLive",
        "WebSocketClientLive", "ChatView", "ComposableArchitectureHelpers",
        "ContactClient", "ContactClientLive", "ContactsView", "CoreDataClient"
      ]
    ),

    .target(
      name: "ContactsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SharedModels", "AsyncImageLoder", "HttpRequest",
        "ContactClient", "ContactClientLive", "WebSocketClient",
        "WebSocketClientLive", "ChatClient", "ChatClientLive",
        "CoreDataStore", "CoreDataClient",
        "ChatView", "ComposableArchitectureHelpers"
      ]),

    .target(
      name: "EventView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        "SharedModels", "EventClient", "InfoPlist", "EventFormView",
        "PathMonitorClient", "WebSocketClient", "WebSocketClientLive",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HttpRequest", "KeychainService", "ChatClient", "ChatView",
        "PathMonitorClientLive", "EventClientLive", "ComposableArchitectureHelpers",
        "EventDetailsView", "ConversationClient", "ConversationClientLive"
      ]
    ),

    .target(
      name: "EventFormView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        "SharedModels", "EventClient", "InfoPlist",
        "PathMonitorClient", "ConversationClient", "ComposableArchitectureHelpers",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HttpRequest", "KeychainService", "ChatClient", "EventClient", "EventClientLive",
        "PathMonitorClientLive", "ComposableArchitectureHelpers", "MapView", "HttpRequest"
      ]
    ),

    .target(
      name: "EventDetailsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        "SharedModels", "EventClient", "InfoPlist",
        "PathMonitorClient", "ConversationClient",
        "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
        "HttpRequest", "KeychainService", "ChatClient",
        "PathMonitorClientLive", "ComposableArchitectureHelpers", "MapView",
        "ConversationClientLive", "ChatView"
      ]
    ),

    .target(
        name: "ProfileView",
        dependencies: [
          .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          "AuthClient", "EventClient", "AttachmentClient",
          "InfoPlist", "UserClient", "SharedModels",
          "SwiftUIExtension", "FoundationExtension", "AsyncImageLoder",
          "HttpRequest", "KeychainService", "AuthenticationView",
          "AttachmentClientLive", "AuthClientLive", "UserClientLive",
          "EventClientLive"
        ]
    ),

    .target(
      name: "SettingsView",
      dependencies: [
        "UIApplicationClient", "UserDefaultsClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        "UserNotificationClient"
      ]
    ),

    .target(
      name: "MapView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        "SwiftUIExtension", "SharedModels", "ComposableArchitectureHelpers"
      ]
    ),

    // Helpers
    .target(
      name: "NotificationHelpers",
      dependencies: [
        "UserNotificationClient", "RemoteNotificationsClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),

    .target(name: "SwiftUIHelpers"),
    .target(name: "CombineHelpers"),
    .target(
      name: "ComposableArchitectureHelpers",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    )
  ]
)
