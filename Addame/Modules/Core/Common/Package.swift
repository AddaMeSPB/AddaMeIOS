// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Common",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "Common",
      targets: ["Common"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git",from: "0.17.0"),
    .package(url: "https://github.com/pointfreeco/composable-core-location", from: "0.1.0")
  ],
  targets: [
    .target(
      name: "Common",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposableCoreLocation", package: "composable-core-location")
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "CommonTests",
      dependencies: ["Common"],
      path: "Tests"
    )
  ]
)
