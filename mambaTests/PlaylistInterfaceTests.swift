//
//  PlaylistInterfaceTests.swift
//  mamba
//
//  Created by David Coufal on 3/13/19.
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

class PlaylistInterfaceTests: XCTestCase {
    
    func testPlaylistType() {
        let playlistVOD = parseVariantPlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        let playlistVODNoMarker = parseVariantPlaylist(inFixtureName: "hls_singleMediaFile.txt")
        let playlistLive = parseVariantPlaylist(inFixtureName: "linear_ad_insertion_CONTENT_start_ad.m3u8")
        let playlistEvent = parseVariantPlaylist(inString: "#EXTM3U\n#EXT-X-PLAYLIST-TYPE:EVENT\n#EXTINF:5220,\nhttp://media.example.com/entire.ts\n#EXT-X-ENDLIST")
        
        XCTAssert(playlistVOD.playlistType == .vod, "Expecting a VOD playlist")
        XCTAssert(playlistVODNoMarker.playlistType == .vod, "Expecting a VOD playlist")
        XCTAssert(playlistLive.playlistType == .live, "Expecting a live playlist")
        XCTAssert(playlistEvent.playlistType == .event, "Expecting a event-style playlist")
    }
    
    func testStartTimeEndTime() {
        let playlistVariant = parseVariantPlaylist(inFixtureName: "hls_singleMediaFile.txt")
        
        XCTAssert(playlistVariant.startTime.seconds == 0.0, "Expecting a starttime")
        XCTAssert(playlistVariant.endTime.seconds == 5220, "Expecting a endtime")
    }
    
    func testMediaSegmentGroupsContainingTagsNamed() {
        let playlist = parseVariantPlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        
        let groupByteRange = playlist.mediaSegmentGroups(containingTagsNamed: [MambaStringRef(string:"#EXT-X-BYTERANGE")])
        let groupExtInf = playlist.mediaSegmentGroups(containingTagsNamed: [MambaStringRef(string:"#EXTINF")])
        
        XCTAssert(groupByteRange.count == 1, "Expecting 1 group")
        XCTAssert(groupExtInf.count == 2, "Expecting 2 groups")
    }
    
    func testDuration() {
        let playlistVariant = parseVariantPlaylist(inFixtureName: "hls_singleMediaFile.txt")
        
        XCTAssert(playlistVariant.duration.seconds == 5220, "Expecting a duration")
    }
    
    func testSegmentName() {
        let playlist = parseVariantPlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        
        let segmentName0 = playlist.segmentName(forMediaSequence: 0)
        let segmentName1 = playlist.segmentName(forMediaSequence: 1)
        let segmentName2 = playlist.segmentName(forMediaSequence: 2)
        let segmentName1000 = playlist.segmentName(forMediaSequence: 1000)
        
        XCTAssertNil(segmentName0, "Media Sequence 0 does not exist in this playlist, so this should be nil")
        
        XCTAssertNotNil(segmentName1, "Media Sequence 1 does exist in this playlist, so this should have a value")
        XCTAssertEqual(segmentName1, "http://media.example.com/entire.ts")
        
        XCTAssertNotNil(segmentName2, "Media Sequence 2 does exist in this playlist, so this should have a value")
        XCTAssertEqual(segmentName2, "http://media.example.com/entire1.ts")
        
        XCTAssertNil(segmentName1000, "Media Sequence 1000 does not exist in this playlist, so this should be nil")
    }
    
    func testCanQueryTimeline() {
        let playlistVariant = parseVariantPlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        
        XCTAssertTrue(playlistVariant.canQueryTimeline())
    }
    
    func testTagIndexesForVodPlaylist() {
        let playlist = """
                        #EXTM3U
                        #EXT-X-PLAYLIST-TYPE:VOD
                        #EXT-X-MEDIA-SEQUENCE:0
                        #EXT-X-TARGETDURATION:3
                        #EXT-X-VERSION:3
                        #EXTINF:2.96130,
                        fileSequence0.ts
                        #EXTINF:2.96130,
                        fileSequence1.ts
                        #EXTINF:2.96129,
                        fileSequence2.ts
                        #EXTINF:2.96129,
                        fileSequence3.ts
                        #EXTINF:2.96130,
                        fileSequence4.ts
                        #EXTINF:2.96130,
                        fileSequence5.ts
                        #EXTINF:2.96129,
                        fileSequence6.ts
                        #EXTINF:2.96129,
                        fileSequence7.ts
                        #EXTINF:2.96130,
                        fileSequence8.ts
                        #EXTINF:2.96130,
                        fileSequence9.ts
                        #EXTINF:2.96129,
                        fileSequence10.ts
                        """
        
        let parsed = parseVariantPlaylist(inString: playlist)
        
        let tagIndexes = parsed.tagIndexes(forMediaSequence: 0)
        XCTAssertNotNil(tagIndexes, "Tag indexes should not be nil")
    }
    
    func testTagIndexesForImpliedLivePlaylist() {
        let playlist = """
                        #EXTM3U
                        #EXT-X-MEDIA-SEQUENCE:0
                        #EXT-X-TARGETDURATION:3
                        #EXT-X-VERSION:3
                        #EXTINF:2.96130,
                        fileSequence0.ts
                        #EXTINF:2.96130,
                        fileSequence1.ts
                        #EXTINF:2.96129,
                        fileSequence2.ts
                        #EXTINF:2.96129,
                        fileSequence3.ts
                        #EXTINF:2.96130,
                        fileSequence4.ts
                        #EXTINF:2.96130,
                        fileSequence5.ts
                        #EXTINF:2.96129,
                        fileSequence6.ts
                        #EXTINF:2.96129,
                        fileSequence7.ts
                        #EXTINF:2.96130,
                        fileSequence8.ts
                        #EXTINF:2.96130,
                        fileSequence9.ts
                        #EXTINF:2.96129,
                        fileSequence10.ts
                        """
        
        let parsed = parseVariantPlaylist(inString: playlist)
        
        let tagIndexes = parsed.tagIndexes(forMediaSequence: 0)
        XCTAssertNotNil(tagIndexes, "Tag indexes should not be nil")
    }
}
