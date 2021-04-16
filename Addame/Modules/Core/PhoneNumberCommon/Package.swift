// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PhoneNumberCommon",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "PhoneNumberCommon",
      targets: ["PhoneNumberCommon"]),
  ],
  dependencies: [
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.3"))
  ],
  targets: [
    .target(
      name: "PhoneNumberCommon",
      dependencies: [
        .product(
          name: "PhoneNumberKit",
          package: "PhoneNumberKit"
        ),
      ]),
    .testTarget(
      name: "PhoneNumberCommonTests",
      dependencies: ["PhoneNumberCommon"]),
  ]
)
