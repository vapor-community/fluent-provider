// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "FluentProvider",
    products: [
        .library(name: "FluentProvider", targets: ["FluentProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(name: "FluentProvider", dependencies: ["Vapor", "Fluent"]),
        .testTarget(name: "FluentProviderTests", dependencies: ["FluentProvider"])
    ]
)
