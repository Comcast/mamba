//
//  HLSPlaylistInterfaceTests.swift
//  mamba
//
//  Created by David Coufal on 4/20/17.
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

class HLSPlaylistInterfaceTests: XCTestCase {
    
    func testType() {
        let playlistMaster = parsePlaylist(inFixtureName: "hls_sampleMasterFile.txt")
        let playlistVariant = parsePlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        let playlistNoType = parsePlaylist(inString: "#EXTM3U\n#EXT-X-VERSION:4")
        
        XCTAssert(playlistMaster.type == .master, "Expecting a Master playlist")
        XCTAssert(playlistVariant.type == .media, "Expecting a Variant playlist")
        XCTAssert(playlistNoType.type == .unknown, "Expecting a unknown playlist")
    }

    func testPlaylistType() {
        let playlistMaster = parsePlaylist(inFixtureName: "hls_sampleMasterFile.txt")
        let playlistVOD = parsePlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        let playlistVODNoMarker = parsePlaylist(inFixtureName: "hls_singleMediaFile.txt")
        let playlistLive = parsePlaylist(inFixtureName: "linear_ad_insertion_CONTENT_start_ad.m3u8")
        let playlistEvent = parsePlaylist(inString: "#EXTM3U\n#EXT-X-PLAYLIST-TYPE:EVENT\n#EXTINF:5220,\nhttp://media.example.com/entire.ts\n#EXT-X-ENDLIST")
        
        XCTAssert(playlistMaster.playlistType == .unknown, "Expecting a unknown playlist (as this is a master playlist)")
        XCTAssert(playlistVOD.playlistType == .vod, "Expecting a VOD playlist")
        XCTAssert(playlistVODNoMarker.playlistType == .vod, "Expecting a VOD playlist")
        XCTAssert(playlistLive.playlistType == .live, "Expecting a live playlist")
        XCTAssert(playlistEvent.playlistType == .event, "Expecting a event-style playlist")
    }

    func testStartTimeEndTime() {
        let playlistMaster = parsePlaylist(inFixtureName: "hls_sampleMasterFile.txt")
        let playlistVariant = parsePlaylist(inFixtureName: "hls_singleMediaFile.txt")
        
        XCTAssert(!playlistMaster.startTime.isValid, "Expecting a non-valid starttime (as this is a master)")
        XCTAssert(!playlistMaster.endTime.isValid, "Expecting a non-valid endtime (as this is a master)")
        XCTAssert(playlistVariant.startTime.seconds == 0.0, "Expecting a starttime")
        XCTAssert(playlistVariant.endTime.seconds == 5220, "Expecting a endtime")
    }
    
    func testMediaSegmentGroupsContainingTagsNamed() {
        let playlist = parsePlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        
        let groupByteRange = playlist.mediaSegmentGroups(containingTagsNamed: [HLSStringRef(string:"#EXT-X-BYTERANGE")])
        let groupExtInf = playlist.mediaSegmentGroups(containingTagsNamed: [HLSStringRef(string:"#EXTINF")])

        XCTAssert(groupByteRange.count == 1, "Expecting 1 group")
        XCTAssert(groupExtInf.count == 2, "Expecting 2 groups")
    }

    func testDuration() {
        let playlistMaster = parsePlaylist(inFixtureName: "hls_sampleMasterFile.txt")
        let playlistVariant = parsePlaylist(inFixtureName: "hls_singleMediaFile.txt")
        
        XCTAssert(!playlistMaster.duration.isValid, "Expecting a zero duration (as this is a master)")
        XCTAssert(playlistVariant.duration.seconds == 5220, "Expecting a duration")
    }
    
    func testSegmentName() {
        let playlist = parsePlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        
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
        let playlistMaster = parsePlaylist(inFixtureName: "hls_sampleMasterFile.txt")
        let playlistVariant = parsePlaylist(inFixtureName: "hls_sampleMediaFile.txt")
        
        XCTAssertFalse(playlistMaster.canQueryTimeline())
        XCTAssertTrue(playlistVariant.canQueryTimeline())
        
        XCTAssertNil(playlistMaster.mediaSequence(forTime: CMTime.zero))
        XCTAssertNil(playlistMaster.mediaSequence(forTagIndex: 0))
        XCTAssertNil(playlistMaster.timeRange(forTagIndex: 0))
        XCTAssertNil(playlistMaster.timeRange(forMediaSequence: 0))
        XCTAssertNil(playlistMaster.tagIndexes(forTime: CMTime.zero))
        XCTAssertNotNil(playlistMaster.tagIndexes(forMediaSequence: 0))
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
        
        let parsed = parsePlaylist(inString: playlist)
        
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
        
        let parsed = parsePlaylist(inString: playlist)
        
        let tagIndexes = parsed.tagIndexes(forMediaSequence: 0)
        XCTAssertNotNil(tagIndexes, "Tag indexes should not be nil")
    }
}
