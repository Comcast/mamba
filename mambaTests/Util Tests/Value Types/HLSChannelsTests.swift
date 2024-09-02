//
//  HLSChannelsTests.swift
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
@testable import mamba

class HLSChannelsTests: XCTestCase {
    let empty = ""
    let invalidCount = "ONE"
    let sixChannel = "6"
    let twelveChannelJoc = "12/JOC"
    let twelveChannelJocAndUnknownSpatialCoding = "12/JOC,SPECIAL"
    let sixChannelWithEmptySpatialIdentifier = "6/-"
    let twelveChannelUnknownSpatialWithDashInName = "12/VERY-SPATIAL"
    let sixChannelNoSpatialWithDownmix = "6/-/DOWNMIX"
    let sixChannelNoSpatialWithBinauralAndImmersive = "6/-/BINAURAL,IMMERSIVE"
    let twelveChannelJocAndImmersive = "12/JOC/IMMERSIVE"
    let sixChannelUnknownSpecialUsageIdentifier = "6/-/NEW-IDENTIFIER"

    func test_empty() {
        let actualChannels = HLSChannels(string: empty)
        XCTAssertNil(actualChannels)
    }

    func test_invalidCount() {
        let actualChannels = HLSChannels(string: invalidCount)
        XCTAssertNil(actualChannels)
    }

    func test_sixChannel() {
        let actualChannels = HLSChannels(string: sixChannel)
        let expectedChannels = HLSChannels(
            count: 6,
            spatialAudioCodingIdentifiers: [],
            specialUsageIdentifiers: []
        )
        XCTAssertEqual(expectedChannels, actualChannels)
    }

    func test_twelveChannelJoc() {
        let actualChannels = HLSChannels(string: twelveChannelJoc)
        let expectedChannels = HLSChannels(
            count: 12,
            spatialAudioCodingIdentifiers: ["JOC"],
            specialUsageIdentifiers: []
        )
        XCTAssertEqual(expectedChannels, actualChannels)
    }

    func test_twelveChannelJocAndUnknownSpatialCoding() {
        let actualChannels = HLSChannels(string: twelveChannelJocAndUnknownSpatialCoding)
        let expectedChannels = HLSChannels(
            count: 12,
            spatialAudioCodingIdentifiers: ["JOC", "SPECIAL"],
            specialUsageIdentifiers: []
        )
        XCTAssertEqual(expectedChannels, actualChannels)
    }

    func test_sixChannelWithEmptySpatialIdentifier() {
        let actualChannels = HLSChannels(string: sixChannelWithEmptySpatialIdentifier)
        let expectedChannels = HLSChannels(
            count: 6,
            spatialAudioCodingIdentifiers: [],
            specialUsageIdentifiers: []
        )
        XCTAssertEqual(expectedChannels, actualChannels)
    }

    func test_twelveChannelUnknownSpatialWithDashInName() {
        let actualChannels = HLSChannels(string: twelveChannelUnknownSpatialWithDashInName)
        let expectedChannels = HLSChannels(
            count: 12,
            spatialAudioCodingIdentifiers: ["VERY-SPATIAL"],
            specialUsageIdentifiers: []
        )
        XCTAssertEqual(expectedChannels, actualChannels)
    }

    func test_sixChannelNoSpatialWithDownmix() {
        let actualChannels = HLSChannels(string: sixChannelNoSpatialWithDownmix)
        let expectedChannels = HLSChannels(
            count: 6,
            spatialAudioCodingIdentifiers: [],
            specialUsageIdentifiers: [.downmix]
        )
        XCTAssertEqual(expectedChannels, actualChannels)
    }

    func test_sixChannelNoSpatialWithBinauralAndImmersive() {
        let actualChannels = HLSChannels(string: sixChannelNoSpatialWithBinauralAndImmersive)
        let expectedChannels = HLSChannels(
            count: 6,
            spatialAudioCodingIdentifiers: [],
            specialUsageIdentifiers: [.binaural, .immersive]
        )
        XCTAssertEqual(expectedChannels, actualChannels)
    }

    func test_twelveChannelJocAndImmersive() {
        let actualChannels = HLSChannels(string: twelveChannelJocAndImmersive)
        let expectedChannels = HLSChannels(
            count: 12,
            spatialAudioCodingIdentifiers: ["JOC"],
            specialUsageIdentifiers: [.immersive]
        )
        XCTAssertEqual(expectedChannels, actualChannels)
    }

    // In the case that we don't recognize the special usage identifier, I think it is better to fail parsing the entire
    // CHANNELS attribute, as otherwise we risk misleading the user of the library into thinking that the special usage
    // is less than it actually is.
    func test_sixChannelUnknownSpecialUsageIdentifier() {
        let actualChannels = HLSChannels(string: sixChannelUnknownSpecialUsageIdentifier)
        XCTAssertNil(actualChannels)
    }
}
