//
//  HLSPlaylistStructureAndEditingTests.swift
//  mamba
//
//  Created by David Coufal on 4/10/17.
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

class HLSPlaylistStructureAndEditingTests: XCTestCase {
    
    func testHLSWithNoXKeys() {
        let playlist = parsePlaylist(inString: sampleVariantPlaylist_NoXKeys)
        
        XCTAssert(playlist.header?.range.count == 3, "Expecting 3 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 2)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 17)
        XCTAssert(playlist.footer?.endIndex == 17)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 4)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == true)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 3)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[3].startIndex == 11)
        XCTAssert(playlist.mediaSegmentGroups[3].endIndex == 12)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 15)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 16)
        
        XCTAssert(playlist.mediaSpans.count == 0)
    }
    
    func testHLSWithXKeys() {
        let playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        XCTAssert(playlist.header?.range.count == 4, "Expecting 4 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 3)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 20)
        XCTAssert(playlist.footer?.endIndex == 20)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 4)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == true)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 5)
        XCTAssert(playlist.mediaSegmentGroups[3].startIndex == 13)
        XCTAssert(playlist.mediaSegmentGroups[3].endIndex == 15)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 18)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 19)
        
        XCTAssert(playlist.mediaSpans.count == 3)
        XCTAssert(playlist.mediaSpans[0].parentTag == playlist.tags[3])
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(playlist.mediaSpans[1].parentTag == playlist.tags[10])
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(playlist.mediaSpans[2].parentTag == playlist.tags[13])
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.count == 3)
        
        let mediaSpan0Tags = playlist.tags[playlist.mediaSpans[0].tagMediaSpan]
        let mediaSpan1Tags = playlist.tags[playlist.mediaSpans[1].tagMediaSpan]
        let mediaSpan2Tags = playlist.tags[playlist.mediaSpans[2].tagMediaSpan]
        
        XCTAssert(mediaSpan0Tags.count == playlist.mediaSpans[0].tagMediaSpan.count)
        XCTAssert(mediaSpan1Tags.count == playlist.mediaSpans[1].tagMediaSpan.count)
        XCTAssert(mediaSpan2Tags.count == playlist.mediaSpans[2].tagMediaSpan.count)
    }
    
    func testHLSWithMissingEXTINF_MissingFooter() {
        let playlist = parsePlaylist(inString: sampleVariantPlaylist_NoFooter)
        
        XCTAssert(playlist.header?.range.count == 3)
        XCTAssert(playlist.footer == nil)
        XCTAssert(playlist.mediaSegmentGroups.count == 6)
    }
    
    func testHLSWithMissingEXTINF_CustomMediaSequence() {
        let playlist = parsePlaylist(inString: sampleVariantPlaylist_MediaSequenceStartsAt2)

        XCTAssert(playlist.header?.range.count == 4)
        XCTAssert(playlist.footer?.range.count == 1)
        XCTAssert(playlist.mediaSegmentGroups.count == 6)
        
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 7)
    }
    
    func testHLSInsertSingleTag() {
        var playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the playlist structure to force a build and set us in the .clean state
        XCTAssert(playlist.mediaSegmentGroups.count > 0)
        
        let tag = HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Just a comment tag"))
        
        playlist.insert(tag: tag, atIndex: 8)
        
        XCTAssert(playlist.header?.range.count == 4, "Expecting 4 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 3)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 21)
        XCTAssert(playlist.footer?.endIndex == 21)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 5)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == true)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 5)
        XCTAssert(playlist.mediaSegmentGroups[3].startIndex == 14)
        XCTAssert(playlist.mediaSegmentGroups[3].endIndex == 16)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 19)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 20)
        
        XCTAssert(playlist.mediaSpans.count == 3)
        XCTAssert(playlist.mediaSpans[0].parentTag == playlist.tags[3])
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(playlist.mediaSpans[1].parentTag == playlist.tags[11])
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(playlist.mediaSpans[2].parentTag == playlist.tags[14])
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSInsertMultipleTags() {
        var playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the playlist structure to force a build and set us in the .clean state
        XCTAssert(playlist.mediaSegmentGroups.count > 0)
        
        let tags = [HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Test Comment Number 1")),
                    HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Test Comment Number 2"))]
        
        playlist.insert(tags: tags, atIndex: 8)
        
        XCTAssert(playlist.header?.range.count == 4, "Expecting 4 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 3)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 22)
        XCTAssert(playlist.footer?.endIndex == 22)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 6)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == true)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 5)
        XCTAssert(playlist.mediaSegmentGroups[3].startIndex == 15)
        XCTAssert(playlist.mediaSegmentGroups[3].endIndex == 17)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 20)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 21)
        
        XCTAssert(playlist.mediaSpans.count == 3)
        XCTAssert(playlist.mediaSpans[0].parentTag == playlist.tags[3])
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(playlist.mediaSpans[1].parentTag == playlist.tags[12])
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(playlist.mediaSpans[2].parentTag == playlist.tags[15])
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSMulitpleInserts() {
        var playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the playlist structure to force a build and set us in the .clean state
        XCTAssert(playlist.mediaSegmentGroups.count > 0)
        
        let tag1 = HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Test Comment Number 1"))
        let tag2 = HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Test Comment Number 2"))
        
        playlist.insert(tag: tag2, atIndex: 8)
        playlist.insert(tag: tag1, atIndex: 8)
        
        XCTAssert(playlist.header?.range.count == 4, "Expecting 4 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 3)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 22)
        XCTAssert(playlist.footer?.endIndex == 22)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 6)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == true)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 5)
        XCTAssert(playlist.mediaSegmentGroups[3].startIndex == 15)
        XCTAssert(playlist.mediaSegmentGroups[3].endIndex == 17)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 20)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 21)
        
        XCTAssert(playlist.mediaSpans.count == 3)
        XCTAssert(playlist.mediaSpans[0].parentTag == playlist.tags[3])
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(playlist.mediaSpans[1].parentTag == playlist.tags[12])
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(playlist.mediaSpans[2].parentTag == playlist.tags[15])
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    
    func testHLSDeleteSingleTag() {
        var playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the playlist structure to force a build and set us in the .clean state
        XCTAssert(playlist.mediaSegmentGroups.count > 0)
        
        playlist.delete(atIndex: 7) // This deletes the DISCONTINUITY tag in sampleVariantPlaylist_frag1
        
        XCTAssert(playlist.header?.range.count == 4, "Expecting 4 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 3)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 19)
        XCTAssert(playlist.footer?.endIndex == 19)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 5)
        XCTAssert(playlist.mediaSegmentGroups[3].startIndex == 12)
        XCTAssert(playlist.mediaSegmentGroups[3].endIndex == 14)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 17)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 18)
        
        XCTAssert(playlist.mediaSpans.count == 3)
        XCTAssert(playlist.mediaSpans[0].parentTag == playlist.tags[3])
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(playlist.mediaSpans[1].parentTag == playlist.tags[9])
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(playlist.mediaSpans[2].parentTag == playlist.tags[12])
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSDeleteSingleTagFromDirtyState() {
        var playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        playlist.delete(atIndex: 7) // This deletes the DISCONTINUITY tag in sampleVariantPlaylist_frag1
        
        XCTAssert(playlist.header?.range.count == 4, "Expecting 4 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 3)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 19)
        XCTAssert(playlist.footer?.endIndex == 19)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 5)
        XCTAssert(playlist.mediaSegmentGroups[3].startIndex == 12)
        XCTAssert(playlist.mediaSegmentGroups[3].endIndex == 14)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 17)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 18)
        
        XCTAssert(playlist.mediaSpans.count == 3)
        XCTAssert(playlist.mediaSpans[0].parentTag == playlist.tags[3])
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(playlist.mediaSpans[1].parentTag == playlist.tags[9])
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(playlist.mediaSpans[2].parentTag == playlist.tags[12])
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSDeleteMultipleTags() {
        var playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the playlist structure to force a build and set us in the .clean state
        XCTAssert(playlist.mediaSegmentGroups.count > 0)
        
        playlist.delete(atRange: 7...8) // This deletes the DISCONTINUITY and BYTERANGE tags in sampleVariantPlaylist_frag1
        
        XCTAssert(playlist.header?.range.count == 4, "Expecting 4 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 3)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 18)
        XCTAssert(playlist.footer?.endIndex == 18)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 5)
        XCTAssert(playlist.mediaSegmentGroups[3].startIndex == 11)
        XCTAssert(playlist.mediaSegmentGroups[3].endIndex == 13)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 16)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 17)
        
        XCTAssert(playlist.mediaSpans.count == 3)
        XCTAssert(playlist.mediaSpans[0].parentTag == playlist.tags[3])
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(playlist.mediaSpans[1].parentTag == playlist.tags[8])
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(playlist.mediaSpans[2].parentTag == playlist.tags[11])
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSMultipleDeletes() {
        
        let sampleDeletableComments =
            "#EXTM3U\n" +
                "#EXT-X-VERSION:4\n" +
                "#EXT-X-PLAYLIST-TYPE:VOD\n" +
                "#EXT-X-TARGETDURATION:2\n" +
                "#TestCommentToBeDeleted1\n" +
                "#TestCommentToBeDeleted2\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/segment1.ts\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/segment2.ts\n" +
        "#EXT-X-ENDLIST\n"
        
        var playlist = parsePlaylist(inString: sampleDeletableComments)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the playlist structure to force a build and set us in the .clean state
        XCTAssert(playlist.header?.range.count == 5, "Expecting 5 header tags")
        
        // This deletes the comment tags
        playlist.delete(atIndex: 3)
        playlist.delete(atIndex: 3)
        
        XCTAssert(playlist.header?.range.count == 3, "Expecting 3 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 2)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 7)
        XCTAssert(playlist.footer?.endIndex == 7)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 2, "Expecting 6 media groups")
    }
    
    func testHLSCrossGroupDelete() {
        
        var playlist = parsePlaylist(inString: sample4SegmentPlaylist)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        XCTAssert(playlist.mediaSegmentGroups.count == 4, "Expecting 4 groups")
        
        // This deletes the middle two media groups
        playlist.delete(atRange: 5...8)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 2, "Expecting 2 groups")
    }
    
    func testHLSInsertNewMediaGroups() {
        var playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the playlist structure to force a build and set us in the .clean state
        XCTAssert(playlist.mediaSegmentGroups.count > 0)
        
        let extinfTagData = HLSStringRef(string: "2.002")
        let tags = [HLSTag(tagDescriptor: PantosTag.EXTINF, tagData:extinfTagData, tagName: HLSStringRef(string: PantosTag.EXTINF.toString()), duration: extinfTagData.extinfSegmentDuration()),
                    HLSTag(tagDescriptor: PantosTag.Location, tagData:HLSStringRef(string: "http://not-a-real.url/adSegment1.ts")),
                    HLSTag(tagDescriptor: PantosTag.EXTINF, tagData:extinfTagData, tagName: HLSStringRef(string: PantosTag.EXTINF.toString()), duration: extinfTagData.extinfSegmentDuration()),
                    HLSTag(tagDescriptor: PantosTag.Location, tagData:HLSStringRef(string: "http://not-a-real.url/adSegment2.ts"))] // insert two new media groups
        
        playlist.insert(tags: tags, atIndex: 10) // inserting between segment 2 and 3
        
        XCTAssert(playlist.header?.range.count == 4, "Expecting 4 header tags")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 3)
        
        XCTAssert(playlist.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(playlist.footer?.startIndex == 24)
        XCTAssert(playlist.footer?.endIndex == 24)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 8, "Expecting 8 media groups")
        XCTAssert(playlist.mediaSegmentGroups[0].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[1].range.count == 4)
        XCTAssert(playlist.mediaSegmentGroups[2].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[3].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[4].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[5].range.count == 3)
        XCTAssert(playlist.mediaSegmentGroups[6].range.count == 2)
        XCTAssert(playlist.mediaSegmentGroups[7].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[0]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[1]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[2]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[3]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[4]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[5]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[6]), "Found an invalid media segment group")
        XCTAssertTrue(runTestForMediaGroupValidity(playlist: playlist, mediaGroup: playlist.mediaSegmentGroups[7]), "Found an invalid media segment group")
        XCTAssert(playlist.mediaSegmentGroups[0].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[1].discontinuity == true)
        XCTAssert(playlist.mediaSegmentGroups[2].discontinuity == false)
        XCTAssert(playlist.mediaSegmentGroups[0].mediaSequence == 0)
        XCTAssert(playlist.mediaSegmentGroups[5].mediaSequence == 5)
        XCTAssert(playlist.mediaSegmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(playlist.mediaSegmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[3].timeRange.start.seconds - 5.004) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[3].timeRange.end.seconds - 7.006) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[4].timeRange.start.seconds - 7.006) < 0.002)
        XCTAssert(fabs(playlist.mediaSegmentGroups[4].timeRange.end.seconds - 9.008) < 0.002)
        XCTAssert(playlist.mediaSegmentGroups[0].startIndex == 4)
        XCTAssert(playlist.mediaSegmentGroups[0].endIndex == 5)
        XCTAssert(playlist.mediaSegmentGroups[5].startIndex == 17)
        XCTAssert(playlist.mediaSegmentGroups[5].endIndex == 19)
        XCTAssert(playlist.mediaSegmentGroups[7].startIndex == 22)
        XCTAssert(playlist.mediaSegmentGroups[7].endIndex == 23)
        
        XCTAssert(playlist.mediaSpans.count == 3)
        XCTAssert(playlist.mediaSpans[0].parentTag == playlist.tags[3])
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.upperBound == 3)
        XCTAssert(playlist.mediaSpans[1].parentTag == playlist.tags[14])
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.lowerBound == 4)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.upperBound == 4)
        XCTAssert(playlist.mediaSpans[2].parentTag == playlist.tags[17])
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.lowerBound == 5)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.upperBound == 7)
        XCTAssert(playlist.mediaSpans[0].tagMediaSpan.count == 4)
        XCTAssert(playlist.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(playlist.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func runTestForMediaGroupValidity(playlist: HLSPlaylist, mediaGroup: MediaSegmentTagGroup) -> Bool {
        let tags = playlist.tags(forMediaGroup: mediaGroup)
        if tags.filter({ $0.tagDescriptor == PantosTag.EXTINF }).count != 1 {
            return false
        }
        if tags.filter({ $0.tagDescriptor == PantosTag.Location }).count != 1 {
            return false
        }
        return true
    }
    
    func testHLS_MissingEXTINF() {
        let playlist = parsePlaylist(inString: sampleVariantPlaylist_MissingEXTINF)
        
        XCTAssert(playlist.header?.range.count == 9, "Expecting 9 header tags, as structurally-unparsable playlists are treated as 'all header'")
        XCTAssert(playlist.header?.startIndex == 0)
        XCTAssert(playlist.header?.endIndex == 8)
        
        XCTAssert(playlist.mediaSegmentGroups.count == 0, "Expecting no groups")
        
        XCTAssert(playlist.mediaSpans.count == 0, "Expecting no spans")
        
        XCTAssert(playlist.footer == nil, "Expecting nil footer")
    }
    
    func testHLSMapping() {
        
        let fakeSegment = "http://not-a-real.url/fake_segment.ts"
        
        var playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        // access the playlist structure to force a build and set us in the .clean state
        XCTAssert(playlist.mediaSegmentGroups.count > 0)
        
        do {
            try playlist.transform({ tag in
                if tag.tagDescriptor == PantosTag.Location {
                    return HLSTag(tagDescriptor: PantosTag.Location, tagData: HLSStringRef(string: fakeSegment))
                }
                return tag
            })
        }
        catch {
            XCTFail("testHLSMapping failed: \(error)")
        }
        
        XCTAssert(playlist.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        let locationTags = playlist.tags.filter { $0.tagDescriptor == PantosTag.Location }
        
        for locationTag in locationTags {
            XCTAssert(locationTag.tagData == fakeSegment, "Expected a changed Location")
        }
    }
    
    func testCopyOnWrite() {
        
        var playlist1 = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        let playlist2 = playlist1
        
        XCTAssert(playlist1.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist2.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist1.mediaSegmentGroups[1].range.count == 4)
        XCTAssert(playlist2.mediaSegmentGroups[1].range.count == 4)
        
        XCTAssert(playlist1.tags.count == playlist2.tags.count, "Expecting same count")
        
        let tag = HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Just a comment tag"))
        
        playlist1.insert(tag: tag, atIndex: 8)
        
        XCTAssert(playlist1.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist2.mediaSegmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(playlist1.mediaSegmentGroups[1].range.count == 5)
        XCTAssert(playlist2.mediaSegmentGroups[1].range.count == 4)
        
        XCTAssert(playlist1.tags.count == playlist2.tags.count + 1, "Expecting an added tag")
    }
    
    func testMediaGroupByObjectAndByIndex() {
        
        let playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        let groupIndex = 1
        
        let group = playlist.mediaSegmentGroups[groupIndex]
        
        let tagsByGroup = Array(playlist.tags(forMediaGroup: group))
        let tagsByIndex = Array(playlist.tags(forMediaGroupIndex: groupIndex))
        
        XCTAssert(tagsByGroup.count == tagsByIndex.count, "Expecting the same tags")
        for (index, _) in tagsByGroup.enumerated() {
            XCTAssert(tagsByGroup[index].tagDescriptor == tagsByIndex[index].tagDescriptor, "Expecting the same tag at index \(index)")
            XCTAssert(tagsByGroup[index].tagData == tagsByIndex[index].tagData, "Expecting the same tag at index \(index)")
        }
    }
    
    func testOutOfRangeMediaGroupAccess() {
        
        let playlist = parsePlaylist(inString: sampleVariantPlaylist_XKeys)
        
        let outOfRangeMediaGroupIndex = Int.max
        
        let tagsFromInvalidGroup = Array(playlist.tags(forMediaGroupIndex: outOfRangeMediaGroupIndex))
        
        XCTAssert(tagsFromInvalidGroup.count == 0, "There should be no tags in nonexistant groups")
    }
    
    func testAllHeader() {
        let playlist = parsePlaylist(inString: sampleVariantPlaylist_header)
        
        XCTAssert(playlist.header?.range.count == 3, "Should have a header")
        XCTAssert(playlist.mediaSegmentGroups.count == 0, "Should have no groups")
        XCTAssert(playlist.footer == nil, "Should have no footer")
        XCTAssert(playlist.mediaSpans.count == 0, "Should have no spans")
    }
    
    func testSpanTagInHeader() {
        
        let sampleSpanInHeader =
            "#EXTM3U\n" +
                "#EXT-X-VERSION:4\n" +
                "#EXT-X-KEY:METHOD=AES-128,URI=\"https://not.a.server.nowhere/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa/\n" +
                "#EXT-X-PLAYLIST-TYPE:VOD\n" +
                "#EXT-X-TARGETDURATION:2\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/segment1.ts\n" +
                "#EXT-X-KEY:METHOD=NONE\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/segment2.ts\n" +
        "#EXT-X-ENDLIST\n"
        
        let playlist = parsePlaylist(inString: sampleSpanInHeader)
        
        XCTAssert(playlist.header?.range.count == 4, "Should have a header")
        XCTAssert(playlist.mediaSegmentGroups.count == 2, "Should have 2 groups")
        XCTAssert(playlist.footer?.range.count == 1, "Should have a footer")
        XCTAssert(playlist.mediaSpans.count == 2, "Should have 2 spans")
    }
    
    func testSpanTagInFirstMediaGroup() {
        
        let sampleSpanInHeader =
            "#EXTM3U\n" +
                "#EXT-X-VERSION:4\n" +
                "#EXT-X-PLAYLIST-TYPE:VOD\n" +
                "#EXT-X-TARGETDURATION:2\n" +
                "#EXTINF:2.002,\n" +
                "#EXT-X-KEY:METHOD=AES-128,URI=\"https://not.a.server.nowhere/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa/\n" +
                "http://not.a.server.nowhere/segment1.ts\n" +
                "#EXT-X-KEY:METHOD=NONE\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/segment2.ts\n" +
        "#EXT-X-ENDLIST\n"
        
        let playlist = parsePlaylist(inString: sampleSpanInHeader)
        
        XCTAssert(playlist.header?.range.count == 3, "Should have a header")
        XCTAssert(playlist.mediaSegmentGroups.count == 2, "Should have 2 groups")
        XCTAssert(playlist.footer?.range.count == 1, "Should have a footer")
        XCTAssert(playlist.mediaSpans.count == 2, "Should have 2 spans")
    }

    func testDeltaUpdateCorrectlyCalculatesMediaSequencesInTagGroups() {
        let playlist = parsePlaylist(inString: sampleDeltaUpdatePlaylist)

        XCTAssertEqual(playlist.header?.range.count, 5, "Should have a header including 'server-control' and 'skip'")
        XCTAssertEqual(playlist.mediaSegmentGroups.count, 6, "Should have 6 remaining groups")
        for i in 0..<6 {
            guard playlist.mediaSegmentGroups.indices.contains(i) else {
                return XCTFail("Should have media segment group at index \(i)")
            }
            let group = playlist.mediaSegmentGroups[i]
            XCTAssertEqual(
                group.mediaSequence,
                i + 5,
                "Should have media sequence value equal to index (\(i)) + initial media sequence (1) + skipped (4)"
            )
        }
        XCTAssertNil(playlist.footer, "Should have no footer")
        XCTAssertEqual(playlist.mediaSpans.count, 0, "Should have no spans (no key tags)")
    }
}


// Calculated HLS fixtures

fileprivate let sampleVariantPlaylist_NoXKeys =
    sampleVariantPlaylist_header +
        sampleVariantPlaylist_frag1 +
        sampleVariantPlaylist_frag2 +
        sampleVariantPlaylist_frag3 +
sampleVariantPlaylist_footer

fileprivate let sampleVariantPlaylist_XKeys =
    sampleVariantPlaylist_header +
        sampleVariantPlaylist_encryption_key +
        sampleVariantPlaylist_frag1 +
        sampleVariantPlaylist_clear_key +
        sampleVariantPlaylist_frag2 +
        sampleVariantPlaylist_encryption_key +
        sampleVariantPlaylist_frag3 +
sampleVariantPlaylist_footer

fileprivate let sampleVariantPlaylist_NoFooter =
    sampleVariantPlaylist_header +
        sampleVariantPlaylist_frag1 +
        sampleVariantPlaylist_frag2 +
sampleVariantPlaylist_frag3

fileprivate let sampleVariantPlaylist_MediaSequenceStartsAt2 =
    sampleVariantPlaylist_header +
        "#EXT-X-MEDIA-SEQUENCE:2\n" +
        sampleVariantPlaylist_frag1 +
        sampleVariantPlaylist_frag2 +
        sampleVariantPlaylist_frag3 +
sampleVariantPlaylist_footer

// HLS segments for above calculated HLS fixtures

fileprivate let hlsStartTag = "#EXTM3U\n"

fileprivate let sampleVariantPlaylist_header =
    hlsStartTag +
        "#EXT-X-VERSION:4\n" +
        "#EXT-X-PLAYLIST-TYPE:VOD\n" +
"#EXT-X-TARGETDURATION:2\n"

fileprivate let sampleVariantPlaylist_frag1 =
    "#EXTINF:2.002\n" +
        "http://not.a.server.nowhere/segment1.ts\n" +
        "#EXTINF:1.0\n" +
        "#EXT-X-DISCONTINUITY\n" +
        "#EXT-X-BYTERANGE:82112@752321\n" +
"http://not.a.server.nowhere/segment2.ts\n"

fileprivate let sampleVariantPlaylist_frag2 =
    "#EXTINF:2.002,\n" +
"http://not.a.server.nowhere/segment3.ts\n"

fileprivate let sampleVariantPlaylist_frag3 =
    "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment4.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment5.ts\n" +
        "#EXTINF:2.002,\n" +
"http://not.a.server.nowhere/segment6.ts\n"


fileprivate let sampleVariantPlaylist_footer =
"#EXT-X-ENDLIST\n"

fileprivate let sampleVariantPlaylist_encryption_key =
"#EXT-X-KEY:METHOD=AES-128,URI=\"https://not.a.server.nowhere/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa/\n"

fileprivate let sampleVariantPlaylist_clear_key =
"#EXT-X-KEY:METHOD=NONE\n"


// Standalone test HLS fixtures

fileprivate let sampleVariantPlaylist_MissingEXTINF =
    "#EXTM3U\n" +
        "#EXT-X-VERSION:4\n" +
        "#EXT-X-PLAYLIST-TYPE:VOD\n" +
        "#EXT-X-TARGETDURATION:2\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment4.ts\n" +
        "http://not.a.server.nowhere/segment5.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment6.ts\n" +
"#EXT-X-ENDLIST\n"

let sample4SegmentPlaylist =
    "#EXTM3U\n" +
        "#EXT-X-VERSION:4\n" +
        "#EXT-X-PLAYLIST-TYPE:VOD\n" +
        "#EXT-X-TARGETDURATION:2\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment1.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment2.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment3.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment4.ts\n" +
"#EXT-X-ENDLIST\n"

let sampleDeltaUpdatePlaylist =
    "#EXTM3U\n" +
        "#EXT-X-VERSION:9\n" +
        "#EXT-X-MEDIA-SEQUENCE:1\n" +
        "#EXT-X-SERVER-CONTROL:CAN-SKIP-UNTIL=12\n" +
        "#EXT-X-TARGETDURATION:2\n" +
        "#EXT-X-SKIP:SKIPPED-SEGMENTS=4\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment5.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment6.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment7.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment8.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/segment9.ts\n" +
        "#EXTINF:2.002,\n" +
"http://not.a.server.nowhere/segment10.ts\n"
