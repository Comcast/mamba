//
//  HLSManifestInterfaceTests.swift
//  mamba
//
//  Created by David Coufal on 4/20/17.
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
@testable import mamba

class HLSManifestInterfaceTests: XCTestCase {
    
    func testType() {
        let manifestMaster = parseManifest(inFixtureName: "hls_sampleMasterFile.txt")
        let manifestVariant = parseManifest(inFixtureName: "hls_sampleMediaFile.txt")
        let manifestNoType = parseManifest(inString: "#EXTM3U\n#EXT-X-VERSION:4")
        
        XCTAssert(manifestMaster.type == .master, "Expecting a Master manifest")
        XCTAssert(manifestVariant.type == .media, "Expecting a Variant manifest")
        XCTAssert(manifestNoType.type == .unknown, "Expecting a unknown manifest")
    }

    func testPlaylistType() {
        let manifestMaster = parseManifest(inFixtureName: "hls_sampleMasterFile.txt")
        let manifestVOD = parseManifest(inFixtureName: "hls_sampleMediaFile.txt")
        let manifestVODNoMarker = parseManifest(inFixtureName: "hls_singleMediaFile.txt")
        let manifestLive = parseManifest(inFixtureName: "linear_ad_insertion_CONTENT_start_ad.m3u8")
        let manifestEvent = parseManifest(inString: "#EXTM3U\n#EXT-X-PLAYLIST-TYPE:EVENT\n#EXTINF:5220,\nhttp://media.example.com/entire.ts\n#EXT-X-ENDLIST")
        
        XCTAssert(manifestMaster.playlistType == .unknown, "Expecting a unknown playlist (as this is a master manifest)")
        XCTAssert(manifestVOD.playlistType == .vod, "Expecting a VOD playlist")
        XCTAssert(manifestVODNoMarker.playlistType == .vod, "Expecting a VOD playlist")
        XCTAssert(manifestLive.playlistType == .live, "Expecting a live playlist")
        XCTAssert(manifestEvent.playlistType == .event, "Expecting a event-style playlist")
    }

    func testStartTimeEndTime() {
        let manifestMaster = parseManifest(inFixtureName: "hls_sampleMasterFile.txt")
        let manifestVariant = parseManifest(inFixtureName: "hls_singleMediaFile.txt")
        
        XCTAssert(!manifestMaster.startTime.isValid, "Expecting a non-valid starttime (as this is a master)")
        XCTAssert(!manifestMaster.endTime.isValid, "Expecting a non-valid endtime (as this is a master)")
        XCTAssert(manifestVariant.startTime.seconds == 0.0, "Expecting a starttime")
        XCTAssert(manifestVariant.endTime.seconds == 5220, "Expecting a endtime")
    }
    
    func testMediaFragmentGroupsContainingTagsNamed() {
        let manifest = parseManifest(inFixtureName: "hls_sampleMediaFile.txt")
        
        let groupByteRange = manifest.mediaFragmentGroups(containingTagsNamed: [HLSStringRef(string:"#EXT-X-BYTERANGE")])
        let groupExtInf = manifest.mediaFragmentGroups(containingTagsNamed: [HLSStringRef(string:"#EXTINF")])

        XCTAssert(groupByteRange.count == 1, "Expecting 1 group")
        XCTAssert(groupExtInf.count == 2, "Expecting 2 groups")
    }

    func testDuration() {
        let manifestMaster = parseManifest(inFixtureName: "hls_sampleMasterFile.txt")
        let manifestVariant = parseManifest(inFixtureName: "hls_singleMediaFile.txt")
        
        XCTAssert(!manifestMaster.duration.isValid, "Expecting a zero duration (as this is a master)")
        XCTAssert(manifestVariant.duration.seconds == 5220, "Expecting a duration")
    }
    
    func testFragmentName() {
        let manifest = parseManifest(inFixtureName: "hls_sampleMediaFile.txt")
        
        let fragmentName0 = manifest.fragmentName(forMediaSequence: 0)
        let fragmentName1 = manifest.fragmentName(forMediaSequence: 1)
        let fragmentName2 = manifest.fragmentName(forMediaSequence: 2)
        let fragmentName1000 = manifest.fragmentName(forMediaSequence: 1000)
        
        XCTAssertNil(fragmentName0, "Media Sequence 0 does not exist in this manifest, so this should be nil")
        
        XCTAssertNotNil(fragmentName1, "Media Sequence 1 does exist in this manifest, so this should have a value")
        XCTAssertEqual(fragmentName1, "http://media.example.com/entire.ts")

        XCTAssertNotNil(fragmentName2, "Media Sequence 2 does exist in this manifest, so this should have a value")
        XCTAssertEqual(fragmentName2, "http://media.example.com/entire1.ts")

        XCTAssertNil(fragmentName1000, "Media Sequence 1000 does not exist in this manifest, so this should be nil")
    }
    
    func testCanQueryTimeline() {
        let manifestMaster = parseManifest(inFixtureName: "hls_sampleMasterFile.txt")
        let manifestVariant = parseManifest(inFixtureName: "hls_sampleMediaFile.txt")
        
        XCTAssertFalse(manifestMaster.canQueryTimeline())
        XCTAssertTrue(manifestVariant.canQueryTimeline())
        
        XCTAssertNil(manifestMaster.mediaSequence(forTime: kCMTimeZero))
        XCTAssertNil(manifestMaster.mediaSequence(forTagIndex: 0))
        XCTAssertNil(manifestMaster.timeRange(forTagIndex: 0))
        XCTAssertNil(manifestMaster.timeRange(forMediaSequence: 0))
        XCTAssertNil(manifestMaster.tagIndexes(forTime: kCMTimeZero))
        XCTAssertNil(manifestMaster.tagIndexes(forMediaSequence: 0))
    }
}
