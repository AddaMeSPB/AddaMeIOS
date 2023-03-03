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
    .library(name: "AttachmentS3Client", targets: ["AttachmentS3Client"]),
    .library(name: "ContactClient", targets: ["ContactClient"]),
    .library(name: "ContactClientLive", targets: ["ContactClientLive"]),
    .library(name: "CoreDataClient", targets: ["CoreDataClient"]),
    .library(name: "DeviceClient", targets: ["DeviceClient"]),
    .library(name: "WebSocketClient", targets: ["WebSocketClient"]),
    .library(name: "WebSocketReducer", targets: ["WebSocketReducer"]),
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
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
    .package(path: "/Users/alif/Developer/Swift/MySideProjects/CommonTCALibraries")
  ],

  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "AttachmentS3Client",
        "EventView", "ConversationsView", "ProfileView", "TabsView",
        "AuthenticationView", "ContactClient",
        "SettingsFeature", "LocationReducer"
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
        "CoreDataStore"
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
      name: "AttachmentS3Client",
      dependencies: [
//        .product(name: "S3", package: "AWSSDKSwift"),
        .product(name: "SotoS3", package: "soto"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
      ]
    ),

    .target(
      name: "ContactClient",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
         "PhoneNumberKit", "CombineContacts"
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
      name: "WebSocketClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient"
      ]
    ),

    .target(
      name: "WebSocketReducer",
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
        "EventView", "ConversationsView", "ProfileView",
        "DeviceClient", "CombineHelpers", "SettingsFeature"
      ]
    ),

    .target(
      name: "ChatView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "AsyncImageLoder", "WebSocketReducer"
      ]
    ),

    .target(
      name: "ConversationsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "AsyncImageLoder",
         "ChatView", "ComposableArchitectureHelpers",
        "ContactClient", "ContactClientLive", "ContactsView", "CoreDataClient"
      ]
    ),

    .target(
      name: "ContactsView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "AsyncImageLoder", "ContactClient", "ContactClientLive",
        "CoreDataStore", "CoreDataClient",
        "ChatView", "ComposableArchitectureHelpers"
      ]
    ),

    .testTarget(
      name: "ContactsViewTests",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        "AsyncImageLoder",
        "ContactClient", "ContactClientLive",
        "CoreDataStore", "CoreDataClient",
        "ChatView", "ComposableArchitectureHelpers", "ContactsView"
      ]
    ),

    .target(
      name: "EventView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "EventFormView",
        "AsyncImageLoder", "ChatView", "HangoutDetailsFeature",
        "ComposableArchitectureHelpers", "LocationReducer"
      ]
    ),
    .testTarget(
      name: "EventViewTests",
      dependencies: [
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "EventView",
      ]
    ),

    .target(
      name: "EventFormView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "APIClient", "AsyncImageLoder", "MapView"
      ]
    ),

//    .testTarget(
//      name: "EventFormViewTests",
//      dependencies: [
//        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
//        "EventFormView",  "KeychainService",
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
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "AsyncImageLoder", "MapView", "ChatView", "APIClient",
        "ComposableArchitectureHelpers"
      ],
      resources: [.process("Resources")]
    ),

    .target(
      name: "ProfileView",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "AddaSharedModels", package: "AddaSharedModels"),
        .product(name: "CommonTCALibraries", package: "CommonTCALibraries"),
        "AsyncImageLoder", "AuthenticationView", "ComposableArchitectureHelpers",
        "ImagePicker", "MyEventsView", "AttachmentS3Client"
      ]
      // resources: [.process("Images")]
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
