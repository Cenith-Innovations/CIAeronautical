// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CIAeronautical",
    platforms: [.iOS(.v14), .tvOS(.v14), .macOS(.v10_15)],
    products: [
        .library(
            name: "CIAeronautical",
            targets: ["CIAeronautical"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Cenith-Innovations/CIFoundation.git", .upToNextMajor(from: "1.0.4"))
    ],
    targets: [
        .target(
            name: "CIAeronautical",
            dependencies: ["CIFoundation"]),
        .testTarget(
            name: "CIAeronauticalTests",
            dependencies: ["CIAeronautical"]),
    ]
)
