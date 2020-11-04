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
                "HLS Rapid Parser/Master Parse Array",
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
            path: "mambaSharedFramework/HLS Rapid Parser/Library"
        ),
        .target(
            name: "CMTimeMakeFromString",
            path: "mambaSharedFramework/HLS Utils/String Util/Library"
        ),
//        .target(
//            name: "RapidParserMasterParseArray",
//            path: "mambaSharedFramework/HLS Rapid Parser/Master Parse Array",
//            exclude: [
//                "PrototypeRapidParseArray.include",
//                "RapidParser_LookingForEForEXTINFState_ParseArray.include",
//                "RapidParser_LookingForEForEXTState_ParseArray.include",
//                "RapidParser_LookingForHashForEXTINFState_ParseArray.include",
//                "RapidParser_LookingForHashForEXTState_ParseArray.include",
//                "RapidParser_LookingForIForEXTINFState_ParseArray.include",
//                "RapidParser_LookingForNewlineForEXTINFState_ParseArray.include",
//                "RapidParser_LookingForNewLineForEXTState_ParseArray.include",
//                "RapidParser_LookingForNewLineForHashState_ParseArray.include",
//                "RapidParser_LookingForNForEXTINFState_ParseArray.include",
//                "RapidParser_LookingForTForEXTINFState_ParseArray.include",
//                "RapidParser_LookingForXForEXTINFState_ParseArray.include",
//                "RapidParser_LookingForXForEXTState_ParseArray.include",
//                "RapidParser_ScanningState_ParseArray.include",
//            ]
//        )
    ]
)
