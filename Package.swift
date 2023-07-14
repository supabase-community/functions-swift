// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "functions-swift",
  platforms: [
    .iOS(.v13),
    .macCatalyst(.v13),
    .macOS(.v10_15),
    .watchOS(.v6),
    .tvOS(.v13),
  ],
  products: [
    .library(name: "Functions", targets: ["Functions"])
  ],
  dependencies: [
    .package(url: "https://github.com/WeTransfer/Mocker", from: "3.0.1")
  ],
  targets: [
    .target(
      name: "Functions",
      dependencies: []
    ),
    .testTarget(
      name: "FunctionsTests",
      dependencies: [
        "Functions",
        "Mocker",
      ]
    ),
  ]
)
