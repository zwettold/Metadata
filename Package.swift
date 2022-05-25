// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Metadata",
    products: [
        .library(name: "Metadata", targets: ["Metadata"])
    ],
    targets: [
        .target(name: "Metadata", dependencies: []),
        .testTarget(name: "MetadataTests", dependencies: ["Metadata"]),
    ]
)
