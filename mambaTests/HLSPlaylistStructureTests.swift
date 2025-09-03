//
//  HLSPlaylistStructureTests.swift
//  mamba
//
//  Created by David Coufal on 4/14/17.
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
@testable import mamba

/*
 We do most of our testing for HLSPlaylistStructure in HLSPlaylist tests.
 
 This is to test some edge cases that are impossible to test through HLSPlaylist.
 */
class HLSPlaylistStructureTests: XCTestCase {
    
    func testDeleteCrossMediaGroupDelete() {
        
        let playlist = parsePlaylist(inString: sample4SegmentPlaylist)
        
        let structure = HLSPlaylistStructure(withTags: playlist.tags)
        
        // sanity check
        XCTAssert(structure.mediaSegmentGroups.count == 4)
        
        // remove 2 tags from the middle of the playlist
        structure.delete(atRange: 6...7)
        
        XCTAssert(structure.mediaSegmentGroups.count == 3)
    }
    
    func testDeleteOutOfFooter() {
        
        let playlist = parsePlaylist(inString: sampleLargeFooterPlaylist)
        
        let structure = HLSPlaylistStructure(withTags: playlist.tags)
        
        // sanity check
        XCTAssert(structure.footer!.range.count == 3)
        
        // remove 1 tags from the footer
        structure.delete(atIndex: 6)
        
        XCTAssert(structure.footer!.range.count == 2)
    }
    
    func testDeleteEntireFooter() {
        
        let playlist = parsePlaylist(inString: sampleLargeFooterPlaylist)
        
        let structure = HLSPlaylistStructure(withTags: playlist.tags)
        
        // sanity check
        XCTAssert(structure.footer!.range.count == 3)
        
        // remove 3 tags from the footer
        structure.delete(atRange: 5...7)
        
        XCTAssert(structure.footer == nil)
    }
    
    func testEmptyPlaylist() {
        
        let playlist = parsePlaylist(inString: "#EXTM3U")
        
        let structure = HLSPlaylistStructure(withTags: playlist.tags)
        
        XCTAssertNil(structure.footer)
        XCTAssert(structure.mediaSegmentGroups.count == 0)
        XCTAssertNil(structure.header)
    }
    
    // This validates the early return logic in generateMediaSpans() for empty mediaSegmentGroups.
    func testNoMediaSegmentsScenario() {
        print("Starting test: testNoMediaSegmentsScenario")
        let hlsArray = [
            "#EXTM3U\n",
            "#EXT-X-TARGETDURATION:6\n",
            "#EXT-X-VERSION:3\n",
            "#EXT-X-MEDIA-SEQUENCE:0\n",
            "#EXT-X-PLAYLIST-TYPE:VOD\n",
            "#EXT-X-KEY:METHOD=NONE\n",
            "#EXT-X-MAP:URI=\"test.mp4\",BYTERANGE=\"610@0\"\n"
        ]
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [])
        print("Finished test: testNoMediaSegmentsScenario")
    }
    
    // Covers an edge case crash where an EXT-X-KEY appears in the header, but the playlist has no media segments.
    func testKeyInHeaderWithNoMediaSegmentsDoesNotCrash() {
        print("Starting test: testKeyInHeaderWithNoMediaSegmentsDoesNotCrash")
        let hlsArray = [
            "#EXTM3U\n",
            "#EXT-X-VERSION:3\n",
            "#EXT-X-KEY:METHOD=AES-128,URI=\"enc.key\"\n",
            "#EXT-X-ENDLIST\n"
        ]
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [])
        print("Finished test: testKeyInHeaderWithNoMediaSegmentsDoesNotCrash")
    }

    // Validates that an EXT-X-KEY tag appearing after the last media segment (in the footer) does not crash generateMediaSpans() or create invalid spans. This seems to occur with DAI
    func testFooterOnlyKeyDoesNotCrashOrAppend() {
        print("Starting test: testFooterOnlyKeyDoesNotCrashOrAppend")
        let hlsArray = [
            "#EXTM3U\n",
            "#EXT-X-VERSION:3\n",
            "#EXT-X-TARGETDURATION:6\n",
            "#EXTINF:6.0,\n",
            "segment1.ts\n",
            "#EXT-X-KEY:METHOD=AES-128,URI=\"footer.key\"\n",
            "#EXT-X-ENDLIST\n"
        ]
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [])
        print("Finished test: testFooterOnlyKeyDoesNotCrashOrAppend")
    }
}

// unusual/malformed playlist to test footer deletion
let sampleLargeFooterPlaylist = """
#EXTM3U
#EXT-X-VERSION:4
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-TARGETDURATION:2
#EXTINF:2.002,
http://not.a.server.nowhere/segment1.ts
#EXT-X-ENDLIST
#EXT-X-ENDLIST
#EXT-X-ENDLIST
"""
