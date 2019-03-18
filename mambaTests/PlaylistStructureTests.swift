//
//  PlaylistStructureTests.swift
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
@testable import mamba

/*
 We do most of our testing for PlaylistStructure in Playlist tests.
 
 This is to test some edge cases that are impossible to test through Playlist.
 */
class PlaylistStructureTests: XCTestCase {
    
    func testDeleteCrossMediaGroupDelete() {
        
        let playlist = parseVariantPlaylist(inString: sample4SegmentPlaylist)
        
        let structure = VariantPlaylistStructure(withTags: playlist.tags)
        
        // sanity check
        XCTAssert(structure.mediaSegmentGroups.count == 4)
        
        // remove 2 tags from the middle of the playlist
        structure.delete(atRange: 6...7)
        
        XCTAssert(structure.mediaSegmentGroups.count == 3)
    }
    
    func testDeleteOutOfFooter() {
        
        let playlist = parseVariantPlaylist(inString: sampleLargeFooterPlaylist)
        
        let structure = VariantPlaylistStructure(withTags: playlist.tags)
        
        // sanity check
        XCTAssert(structure.footer!.range.count == 3)
        
        // remove 1 tags from the footer
        structure.delete(atIndex: 6)
        
        XCTAssert(structure.footer!.range.count == 2)
    }
    
    func testDeleteEntireFooter() {
        
        let playlist = parseVariantPlaylist(inString: sampleLargeFooterPlaylist)
        
        let structure = VariantPlaylistStructure(withTags: playlist.tags)
        
        // sanity check
        XCTAssert(structure.footer!.range.count == 3)
        
        // remove 3 tags from the footer
        structure.delete(atRange: 5...7)
        
        XCTAssert(structure.footer == nil)
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
