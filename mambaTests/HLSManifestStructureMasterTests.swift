//
//  HLSManifestStructureMasterTests.swift
//  mamba
//
//  Created by Philip McMahon on 4/24/17.
//  Copyright © 2017 Comcast Corporation.
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

import XCTest
import CoreMedia

@testable import mamba

class HLSManifestStructureMasterTests: XCTestCase {
    
    func testHLSOK() {
        
        let manifestString = FixtureLoader.loadAsString(fixtureName: "hls_master_manifest.m3u8")
        let manifest = parseManifest(inString: manifestString!)
        
        XCTAssert(manifest.header.range.count == 3, "Expecting 3 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 2)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 7, "Expecting 7 media groups")
        for group in manifest.mediaFragmentGroups {
            
            XCTAssert(group.range.count == 2)
            XCTAssert(group.discontinuity == false)
            XCTAssert(!group.timeRange.start.isValid)
            XCTAssert(!group.timeRange.end.isValid)
        }
        
        XCTAssert(manifest.mediaSpans.count == 0)
        XCTAssert(manifest.footer!.range.count == 7)
    }
    
    func testMissingUri() {
    
        let manifest = parseManifest(inString: missingUriManifest)
        XCTAssert(manifest.header.range.count == 1, "Expecting 0 header tags")
        XCTAssert(manifest.mediaFragmentGroups.count == 3, "Expecting 3 media groups")
        XCTAssert(manifest.footer == nil)
    }

    private let missingUriManifest =
    "#EXTM3U\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=200000\n" +
    "gear1/prog_index.m3u8\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=311111\n" +
    "gear2/prog_index.m3u8\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=484444\n" +
    "gear3/prog_index.m3u8\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=737777\n"
}
