import PackageDescription

let package = Package(
    name: "FluentVapor",
    dependencies: [
        .Package(url: "https://github.com/vapor/fluent.git", Version(2,0,0, prereleaseIdentifiers: ["alpha"])),
        .Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["alpha"])),
    ]
)
