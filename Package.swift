// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mamba",
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
            dependencies: ["CMTimeMakeFromString"],
            path: "mambaSharedFramework/HLS Rapid Parser/HLSStringRef/Library"
        ),
        .target(
            name: "HLSRapidParser",
            dependencies: ["HLSStringRef"],
            path: "mambaSharedFramework/HLS Rapid Parser/Library",
            exclude: [
                "Master Parse Array/PrototypeRapidParseArray.include",
                "Master Parse Array/RapidParser_LookingForEForEXTINFState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForEForEXTState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForHashForEXTINFState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForHashForEXTState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForIForEXTINFState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForNewlineForEXTINFState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForNewLineForEXTState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForNewLineForHashState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForNForEXTINFState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForTForEXTINFState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForXForEXTINFState_ParseArray.include",
                "Master Parse Array/RapidParser_LookingForXForEXTState_ParseArray.include",
                "Master Parse Array/RapidParser_ScanningState_ParseArray.include",
            ]
        ),
        .target(
            name: "CMTimeMakeFromString",
            path: "mambaSharedFramework/HLS Utils/String Util/Library"
        )
    ]
)
