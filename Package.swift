// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mamba",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "mamba",
            targets: ["mamba"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "mamba",
            dependencies: ["HLSStringRef", "CMTimeMakeFromString", "HLSRapidParser"],
            path: "mambaSharedFramework",
            exclude: ["mamba.h", "HLS Utils/String Util/Library", "HLS Rapid Parser/HLSStringRef/Library", "HLS Rapid Parser/Library",
                      "HLS Rapid Parser/Master Parse Array"]
        ),
        .target(
            name: "HLSStringRef",
            dependencies: ["CMTimeMakeFromString"],
            path: "mambaSharedFramework/HLS Rapid Parser/HLSStringRef/Library"
        ),
        .target(
            name: "CMTimeMakeFromString",
            path: "mambaSharedFramework/HLS Utils/String Util/Library"
        ),
        .target(
            name: "HLSRapidParser",
            path: "mambaSharedFramework/HLS Rapid Parser/Library"
        ),
        
    ]
)
