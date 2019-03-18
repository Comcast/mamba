//
//  PlaylistStructureMasterTests.swift
//  mamba
//
//  Created by David Coufal on 3/14/19.
//  Copyright © 2019 Comcast Corporation.
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

import XCTest
import CoreMedia

@testable import mamba

class PlaylistStructureMasterTests: XCTestCase {
    
    func testHLSOK() {
        
        let playlistString = FixtureLoader.loadAsString(fixtureName: "hls_master_playlist.m3u8")
        let playlist = parseMasterPlaylist(inString: playlistString!)
        
        
        XCTAssert(playlist.variantTagGroups.count == 7, "Expecting 7 media groups")
        for group in playlist.variantTagGroups {
            XCTAssert(group.range.count == 2)
        }
    }
    
    func testMissingUri() {
        
        let playlist = parseMasterPlaylist(inString: missingUriPlaylist)
        XCTAssert(playlist.variantTagGroups.count == 3, "Expecting 3 media groups")
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
