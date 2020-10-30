// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mamba",
    platforms: [
        .iOS(.v12), .tvOS(.v12)
    ],
    products: [
        .library(
            name: "mamba",
            targets: ["mamba"])
    ],
    targets: [
        .target(
            name: "mamba",
            dependencies: ["HLSStringRef", "CMTimeMakeFromString", "HLSRapidParser"],
            path: "mambaSharedFramework",
            exclude: [
                "HLS Rapid Parser/HLSStringRef/Library",
                "HLS Rapid Parser/Library",
                "HLS Utils/String Util/Library"
            ]
        ),
        .target(
            name: "HLSStringRef",
            path: "mambaSharedFramework/HLS Rapid Parser/HLSStringRef/Library"
        ),
        .target(
            name: "HLSRapidParser",
            path: "mambaSharedFramework/HLS Rapid Parser/Library"
        ),
        .target(
            name: "CMTimeMakeFromString",
            path: "mambaSharedFramework/HLS Utils/String Util/Library"
        )
    ]
)
