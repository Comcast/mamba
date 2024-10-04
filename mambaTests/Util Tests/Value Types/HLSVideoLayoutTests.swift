//
//  HLSVideoLayoutTests.swift
//  mamba
//
//  Created by Robert Galluccio on 9/2/24.
//  Copyright © 2024 Comcast Corporation.
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
//  limitations under the License. All rights reserved.
//

import Foundation
import XCTest
import mamba

class HLSVideoLayoutTests: XCTestCase {
    let empty = ""
    let unrecognizedVideoLayout = "CH-TRI"
    let monoLayout = "CH-MONO"
    let stereoLayout = "CH-STEREO"
    let stereoWithMonoLayout = "CH-STEREO,CH-MONO"
    let monoWithStereoLayout = "CH-MONO,CH-STEREO"
    let monoWithStereoWithUnrecognizedLayout = "CH-MONO,CH-STEREO,CH-TRI"

    func test_empty() {
        XCTAssertNil(HLSVideoLayout(string: empty))
    }

    func test_unrecognizedVideoLayout() {
        guard let videoLayout = HLSVideoLayout(string: unrecognizedVideoLayout) else {
            return XCTFail("Expected to parse REQ-VIDEO-LAYOUT from \(unrecognizedVideoLayout).")
        }
        XCTAssertEqual(videoLayout.layouts, [.unrecognized(unrecognizedVideoLayout)])
        XCTAssertEqual(videoLayout.predominantLayout, .unrecognized(unrecognizedVideoLayout))
        XCTAssertFalse(videoLayout.contains(.chMono))
        XCTAssertFalse(videoLayout.contains(.chStereo))
        XCTAssertTrue(videoLayout.contains(.unrecognized(unrecognizedVideoLayout)))
    }

    func test_monoLayout() {
        guard let videoLayout = HLSVideoLayout(string: monoLayout) else {
            return XCTFail("Expected to parse REQ-VIDEO-LAYOUT from \(monoLayout).")
        }
        XCTAssertEqual(videoLayout.layouts, [.chMono])
        XCTAssertEqual(videoLayout.predominantLayout, .chMono)
        XCTAssertTrue(videoLayout.contains(.chMono))
        XCTAssertFalse(videoLayout.contains(.chStereo))
    }

    func test_stereoLayout() {
        guard let videoLayout = HLSVideoLayout(string: stereoLayout) else {
            return XCTFail("Expected to parse REQ-VIDEO-LAYOUT from \(stereoLayout).")
        }
        XCTAssertEqual(videoLayout.layouts, [.chStereo])
        XCTAssertEqual(videoLayout.predominantLayout, .chStereo)
        XCTAssertFalse(videoLayout.contains(.chMono))
        XCTAssertTrue(videoLayout.contains(.chStereo))
    }

    func test_stereoWithMonoLayout() {
        guard let videoLayout = HLSVideoLayout(string: stereoWithMonoLayout) else {
            return XCTFail("Expected to parse REQ-VIDEO-LAYOUT from \(stereoWithMonoLayout).")
        }
        XCTAssertEqual(videoLayout.layouts, [.chStereo, .chMono])
        XCTAssertEqual(videoLayout.predominantLayout, .chStereo)
        XCTAssertTrue(videoLayout.contains(.chMono))
        XCTAssertTrue(videoLayout.contains(.chStereo))
    }

    func test_monoWithStereoLayout() {
        guard let videoLayout = HLSVideoLayout(string: monoWithStereoLayout) else {
            return XCTFail("Expected to parse REQ-VIDEO-LAYOUT from \(monoWithStereoLayout).")
        }
        XCTAssertEqual(videoLayout.layouts, [.chMono, .chStereo])
        XCTAssertEqual(videoLayout.predominantLayout, .chMono)
        XCTAssertTrue(videoLayout.contains(.chMono))
        XCTAssertTrue(videoLayout.contains(.chStereo))
    }

    func test_monoWithStereoWithUnrecognizedLayout() {
        guard let videoLayout = HLSVideoLayout(string: monoWithStereoWithUnrecognizedLayout) else {
            return XCTFail("Expected to parse REQ-VIDEO-LAYOUT from \(monoWithStereoWithUnrecognizedLayout).")
        }
        XCTAssertEqual(videoLayout.layouts, [.chMono, .chStereo, .unrecognized("CH-TRI")])
        XCTAssertEqual(videoLayout.predominantLayout, .chMono)
        XCTAssertTrue(videoLayout.contains(.chMono))
        XCTAssertTrue(videoLayout.contains(.chStereo))
        XCTAssertTrue(videoLayout.contains(.unrecognized("CH-TRI")))
    }
}
