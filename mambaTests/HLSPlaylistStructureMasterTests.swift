//
//  HLSPlaylistStructureMasterTests.swift
//  mamba
//
//  Created by Philip McMahon on 4/24/17.
//  Copyright © 2017 Comcast Cable Communications Management, LLC
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

class HLSPlaylistStructureMasterTests: XCTestCase {
    
    func testHLSOK() {
        
        let playlistString = FixtureLoader.loadAsString(fixtureName: "hls_master_playlist.m3u8")
        let playlist = parsePlaylist(inString: playlistString!)
        
        XCTAssert(playlist.header?.range.count == 3, "Expecting 3 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 2)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 7, "Expecting 7 media groups")
        for group in playlist.mediaSegmentGroups {
            
            XCTAssert(group.range.count == 2)
            XCTAssert(group.discontinuity == false)
            XCTAssert(!group.timeRange.start.isValid)
            XCTAssert(!group.timeRange.end.isValid)
        }
        
        XCTAssert(playlist.mediaSpans.count == 0)
        XCTAssert(playlist.footer!.range.count == 7)
    }
    
    func testMissingUri() {
    
        let playlist = parsePlaylist(inString: missingUriPlaylist)
        XCTAssert(playlist.header?.range.count == 1, "Expecting 0 header tags")
        XCTAssert(playlist.mediaSegmentGroups.count == 3, "Expecting 3 media groups")
        XCTAssert(playlist.footer == nil)
    }

    private let missingUriPlaylist =
    "#EXTM3U\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=200000\n" +
    "gear1/prog_index.m3u8\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=311111\n" +
    "gear2/prog_index.m3u8\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=484444\n" +
    "gear3/prog_index.m3u8\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=737777\n"
}
