// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tAIrot",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "tAIrot", targets: ["tAIrot"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.5.0")),
    ],
    targets: [
        .target(
            name: "tAIrot",
            dependencies: ["Alamofire"]),
        .testTarget(
            name: "tAIrotTests",
            dependencies: ["tAIrot"]),
    ]
)

