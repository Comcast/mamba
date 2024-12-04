// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Package.swift
//  mamba
//
//  Copyright © 2020 Comcast Cable Communications Management, LLC
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PackageDescription

let package = Package(
    name: "mamba",
    products: [
        .library(
            name: "mamba",
            targets: ["mamba"]
        )
    ],
    targets: [
        .target(
            name: "mamba",
            dependencies: [.target(name: "HLSObjectiveC")],
            path: "mambaSharedFramework",
            exclude: [
                "HLS ObjectiveC",
                "PlaylistParserError",
                "mamba.h"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "PlaylistParserError",
            path: "mambaSharedFramework/PlaylistParserError"
        ),
        .target(
            name: "HLSObjectiveC",
            dependencies: ["PlaylistParserError"],
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
