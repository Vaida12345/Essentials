// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Essentials",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "Essentials", targets: ["Essentials"])
    ], targets: [
        .target(name: "Essentials", path: "Sources"),
        .testTarget(name: "EssentialsTests", dependencies: ["Essentials"], path: "Tests")
    ]
)
