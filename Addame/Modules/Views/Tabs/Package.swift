// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Tabs",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "Tabs",
      targets: ["Tabs"]),
  ],
  dependencies: [
    .package(path: "../Modules/Core/Common"),
    .package(path: "../Modules/Views/ProfileView"),
    .package(path: "../Modules/Views/ChatView"),
    .package(path: "../Modules/Views/EventView")
  ],
  targets: [
    .target(
      name: "Tabs",
      dependencies: [
        "Common", "ProfileView", "ChatView", "EventView",
//        .product(name: "UserClientLive", package: "ProfileView"),
//        .product(name: "AuthClientLive", package: "ProfileView"),
//        .product(name: "EventClient", package: "ProfileView"),
//        .product(name: "AttachmentClient", package: "ProfileView"),
      ]),
    .testTarget(
      name: "TabsTests",
      dependencies: ["Tabs"]),
  ]
)
