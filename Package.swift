// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mamba",
    products: [
        .library(
            name: "mamba",
            targets: ["mamba"]),
    ],
    targets: [
        .target(
            name: "mamba",
            dependencies: ["HLSObjectiveC"],
            path: "mambaSharedFramework",
            exclude: [
                "HLS ObjectiveC",
            ]
        ),
        .target(
            name: "HLSObjectiveC",
            path: "mambaSharedFramework/HLS ObjectiveC",
            exclude: [
                "PrototypeRapidParseArray.include",
                "RapidParser_LookingForEForEXTINFState_ParseArray.include",
                "RapidParser_LookingForEForEXTState_ParseArray.include",
                "RapidParser_LookingForHashForEXTINFState_ParseArray.include",
                "RapidParser_LookingForHashForEXTState_ParseArray.include",
                "RapidParser_LookingForIForEXTINFState_ParseArray.include",
                "RapidParser_LookingForNewlineForEXTINFState_ParseArray.include",
                "RapidParser_LookingForNewLineForEXTState_ParseArray.include",
                "RapidParser_LookingForNewLineForHashState_ParseArray.include",
                "RapidParser_LookingForNForEXTINFState_ParseArray.include",
                "RapidParser_LookingForTForEXTINFState_ParseArray.include",
                "RapidParser_LookingForXForEXTINFState_ParseArray.include",
                "RapidParser_LookingForXForEXTState_ParseArray.include",
                "RapidParser_ScanningState_ParseArray.include",
            ]
        )

    ]
)
