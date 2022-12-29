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

    .library(name: "AppConfiguration", targets: ["AppConfiguration"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "AsyncImageLoder", targets: ["AsyncImageLoder"]),
    .library(name: "CoreDataStore", targets: ["CoreDataStore"]),
    .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    .library(name: "LocationReducer", targets: ["LocationReducer"]),

    // Client
    .library(name: "APIClient", targets: ["APIClient"]),
    .library(name: "AttachmentClient", targets: ["AttachmentClient"]),
    .library(name: "AttachmentClientLive", targets: ["AttachmentClientLive"]),

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
    .library(name: "UserClient", targets: ["UserClient"]),
    .library(name: "UserClientLive", targets: ["UserClientLive"]),
    .library(name: "WebSocketClient", targets: ["WebSocketClient"]),
    .library(name: "WebSocketClientLive", targets: ["WebSocketClientLive"]),
    .library(name: "LocationSearchClient", targets: ["LocationSearchClient"]),

    // MARK: Views
    .library(name: "AuthenticationView", targets: ["AuthenticationView"]),
    .library(name: "ChatView", targets: ["ChatView"]),
    .library(name: "ConversationsView", targets: ["ConversationsView"]),
    .library(name: "ContactsView", targets: ["ContactsView"]),
    .library(name: "EventView", targets: ["EventView"]),
    .library(name: "HangoutDetailsFeature", targets: ["HangoutDetailsFeature"]),
    .library(name: "EventFormView", targets: ["EventFormView"]),
    .library(name: "ProfileView", targets: ["ProfileView"]),
    .library(name: "TabsView", targets: ["TabsView"]),
    .library(name: "SettingsView", targets: ["SettingsView"]),
    .library(name: "MapView", targets: ["MapView"]),
    .library(name: "MyEventsView", targets: ["MyEventsView"]),
    .library(name: "RegisterFormFeature", targets: ["RegisterFormFeature"]),

    // Helpers
    .library(name: "CombineHelpers", targets: ["CombineHelpers"]),
    .library(name: "ComposableArchitectureHelpers", targets: ["ComposableArchitectureHelpers"]),
    .library(name: "ImagePicker", targets: ["ImagePicker"])

  ],

  dependencies: [
//    .package(name: "AWSSDKSwift", url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.9.0"),
    .package(path: "/Users/alif/Developer/Swift/AddaMe/BackEnd/AddaSharedModels"),
//    .package(url: "https://github.com/AddaMeSPB/AddaSharedModels", .branch("route")),
    .package(url: "https://github.com/soto-project/soto.git", from: "5.13.1"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.3")),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.47.2"),
    .package(url: "https://github.com/pointfreeco/composable-core-location.git", .branch("main")),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.1.0"),
    .package(url: "https://github.com/AddaMeSPB/CombineContacts.git", .branch("async")),
    .package(url: "https://github.com/AddaMeSPB/HTTPRequestKit.git", from: "3.0.0"),
    .package(url: "https://github.com/saroar/swift-composable-presentation.git", .branch("foundation")),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
    .package(path: "/Users/alif/Developer/Swift/MySideProjects/CommonTCALibraries")
  ],

  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "AttachmentClient", "ChatClient",
        "ConversationClient", "EventClient", "WebSocketClient",
        "EventView", "ConversationsView", "ProfileView", "TabsView",
        "AuthenticationView", "SettingsView", "ContactClient",
        "UserClient", "UserClientLive", "SettingsFeature",
        "LocationReducer"
      ]
    ),

    .testTarget(
      name: "AppFeatureTests",
      dependencies: ["AppFeature"]
    ),

    .target(
        name: "AppConfiguration",
        dependencies: [
          .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          .product(name: "AddaSharedModels", package: "AddaSharedModels"),
          .product(name: "CommonTCALibraries", package: "CommonTCALibraries")
        ]
    ),

    // Core
    .target(name: "AsyncImageLoder"),

    .target(
      name: "CoreDataStore",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries")
      ]
    ),

    // MARK: Clients
    .target(
        name: "APIClient",
        dependencies: [
          .product(name: "AddaSharedModels", package: "AddaSharedModels"),
          .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
          "AppConfiguration"
        ]
    ),

    .target(
      name: "CoreDataClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        "CoreDataStore", "ContactClient", "ContactClientLive"
      ]
    ),

    .target(
        name: "DeviceClient",
        dependencies: [
            .product(name: "AddaSharedModels", package: "AddaSharedModels"),
            .product(name: "CommonTCALibraries", package: "CommonTCALibraries")
        ]
    ),

    .target(
      name: "AttachmentClient",
      dependencies: [
//        .product(name: "S3", package: "AWSSDKSwift"),
        .product(name: "SotoS3", package: "soto"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "HTTPRequestKit"
      ]
    ),
    .target(name: "AttachmentClientLive", dependencies: ["AttachmentClient"]),

    .target(
      name: "ChatClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "HTTPRequestKit"
      ]
    ),
    .target(name: "ChatClientLive", dependencies: ["ChatClient"]),

    .target(
      name: "ContactClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "HTTPRequestKit", "PhoneNumberKit", "CombineContacts"
      ]
    ),
    .target(
      name: "ContactClientLive",
      dependencies: [
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "ContactClient", "CoreDataStore"
      ]
    ),

    .target(
      name: "ConversationClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "HTTPRequestKit"
      ]),

    .target(
      name: "ConversationClientLive",
      dependencies: ["ConversationClient"]),

    .target(
      name: "EventClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "HTTPRequestKit"
      ]),

    .target(
      name: "EventClientLive",
      dependencies: ["EventClient"]),

    .target(
      name: "UserClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "HTTPRequestKit"
      ]),

    .target(name: "UserClientLive", dependencies: ["UserClient"]),

    .target(
      name: "WebSocketClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "HTTPRequestKit"
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
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "PhoneNumberKit", "RegisterFormFeature", "SettingsFeature"
      ],
      resources: [
        .process("Resources/PhoneNumberMetadata.json")
      ]
    ),
    .testTarget(
      name: "AuthenticationViewTests",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "AuthenticationView", "PhoneNumberKit"
      ]
    ),

    .target(
        name: "RegisterFormFeature",
        dependencies: [
          .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          .product(name: "AddaSharedModels", package: "AddaSharedModels"),
          .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
          "APIClient", "LocationReducer"
        ]),

    .target(
      name: "TabsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "UserClient", "UserClientLive",
        "EventClient", "EventClientLive", "AttachmentClient", "AttachmentClientLive",
        "ConversationClient",
        "ConversationClientLive",
        "EventView", "ConversationsView", "ProfileView",
        "WebSocketClient", "WebSocketClientLive",
        "DeviceClient", "CombineHelpers"
      ]
    ),

    .target(
      name: "ChatView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "WebSocketClient", "ConversationClient", "ChatClient", "AsyncImageLoder",
        "HTTPRequestKit", "ChatClientLive", "ConversationClientLive",
        "WebSocketClientLive"
      ]
    ),

    .target(
      name: "ConversationsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "WebSocketClient", "ChatClient", "ChatClientLive",
        "AsyncImageLoder",
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
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
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
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
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
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "EventFormView", "WebSocketClient", "WebSocketClientLive",
        "AsyncImageLoder", "ChatView", "HangoutDetailsFeature",
        "ComposableArchitectureHelpers", "LocationReducer"
      ]
    ),
    .testTarget(
      name: "EventViewTests",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "EventView", "HTTPRequestKit"
      ]
    ),

    .target(
      name: "EventFormView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "AsyncImageLoder", "MapView"
      ]
    ),

//    .testTarget(
//      name: "EventFormViewTests",
//      dependencies: [
//        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
//        "EventFormView", "HTTPRequestKit", "KeychainService",
//      ]
//    ),

    .target(
        name: "MyEventsView",
        dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "AsyncImageLoder", "APIClient"
        ]
    ),

    .target(
      name: "HangoutDetailsFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "EventClient", "AsyncImageLoder", "HTTPRequestKit", "ChatClient",
        "MapView", "ChatView", "APIClient",
        "ConversationClient", "ConversationClientLive", "ComposableArchitectureHelpers"
      ],
      resources: [.process("Resources")]
    ),

    .target(
      name: "ProfileView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
         "EventClient", "AttachmentClient",
        "UserClient", "AsyncImageLoder",
        "HTTPRequestKit", "AuthenticationView",
        "AttachmentClientLive", "UserClientLive",
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
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "AuthenticationView"
      ]
    ),

    .target(
      name: "SettingsFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "LocationReducer"
      ]),

    .target(
      name: "MapView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        "ComposableArchitectureHelpers"
      ]
    ),
    .testTarget(
      name: "MapViewTests",
      dependencies: ["MapView"]
    ),

    // Helpers

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
    ),

    .target(
        name: "LocationReducer",
        dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
            .product(name: "ComposableCoreLocation", package: "composable-core-location"),
            "AddaSharedModels"
        ]
    )


  ]
)
