// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Essentials",
    products: [
        .library(name: "Essentials", targets: ["Essentials"])
    ], targets: [
        .target(name: "Essentials", path: "Sources"),
        .testTarget(name: "EssentialsTests", dependencies: ["Essentials"], path: "Tests")
    ]
)
