// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CIAeronautical",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "CIAeronautical",
            targets: ["CIAeronautical"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CIAeronautical",
            dependencies: []),
        .testTarget(
            name: "CIAeronauticalTests",
            dependencies: ["CIAeronautical"]),
    ]
)
