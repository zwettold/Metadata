// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Metadata",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(name: "Metadata", targets: ["Metadata"])
    ],
    targets: [
        .target(name: "Metadata", dependencies: []),
        .testTarget(name: "MetadataTests", dependencies: ["Metadata"]),
    ]
)
