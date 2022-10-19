// swift-tools-version: 5.5

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
    .library(name: "Functions", targets: ["Functions"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Functions",
      dependencies: []),
    .testTarget(
      name: "FunctionsTests",
      dependencies: ["Functions"]),
  ]
)
