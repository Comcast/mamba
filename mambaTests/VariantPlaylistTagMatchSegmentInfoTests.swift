//
//  VariantPlaylistTagMatchSegmentInfoTests.swift
//  mamba
//
//  Created by David Coufal on 6/11/19.
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
import mamba

class VariantPlaylistTagMatchSegmentInfoTests: XCTestCase {
    
    func testBasicFunctionality() {
        
        let testHLS = """
#EXTM3U
#EXT-X-VARIANT-WHOLE-PLAYLIST-SCOPE
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXTINF:3.00,0
segment0.ts
#EXTINF:3.00,1
segment1.ts
#EXTINF:3.00,2
#EXT-X-VARIANT-SEGMENT-SCOPE
segment2.ts
#EXTINF:3.00,3
segment3.ts
#EXTINF:3.00,4
#EXT-X-VARIANT-SEGMENT-SCOPE
#EXT-X-DISCONTINUITY
segment4.ts
#EXTINF:3.00,5
segment5.ts
#EXT-X-ENDLIST
"""
        let playlist = parseVariantPlaylist(inString: testHLS, tagTypes: [VariantMatchTestTag.self])
        
        // testing if the "match in header means the match is for the first fragment" feature works (note this is the default behavior)
        let testMatchHeaderTagsWithFirstFragment = playlist.getPlaylistSegmentMatches(usingPredicate: { $0.tagDescriptor == VariantMatchTestTag.EXT_X_VARIANT_WHOLE_PLAYLIST_SCOPE })
        
        XCTAssertEqual(testMatchHeaderTagsWithFirstFragment.count, 1)
        
        XCTAssertEqual(testMatchHeaderTagsWithFirstFragment[0].containsDiscontinuity, false)
        XCTAssertEqual(testMatchHeaderTagsWithFirstFragment[0].foundInHeader, true)
        XCTAssertEqual(testMatchHeaderTagsWithFirstFragment[0].mediaSequence, 0)
        XCTAssertEqual(testMatchHeaderTagsWithFirstFragment[0].tagGroupIndex, 0)
        XCTAssertEqual(testMatchHeaderTagsWithFirstFragment[0].tagIndex, 0)
        XCTAssertEqual(testMatchHeaderTagsWithFirstFragment[0].tagIndexRangeOfMediaGroup, 4...5)
        switch testMatchHeaderTagsWithFirstFragment[0].playlistTime {
        case .noTimeMatchForNonVODPlaylist:
            XCTFail("Not expecting this value")
        case .timeMatch(let timeRange):
            XCTAssertEqual(timeRange.start, CMTime.zero)
            XCTAssertEqual(timeRange.duration, CMTime(string: "3.0000")!)
        }
        
        // testing if the "match in header means no match" feature works
        let testMatchHeaderTagsWithNothing = playlist.getPlaylistSegmentMatches(usingPredicate: { $0.tagDescriptor == VariantMatchTestTag.EXT_X_VARIANT_WHOLE_PLAYLIST_SCOPE },
                                                                                withMatchesInHeaderMatchingToFirstMediaSegment: false)
        
        XCTAssertEqual(testMatchHeaderTagsWithNothing.count, 0)
        
        // testing more "normal" segment based tags
        let testSegmentTags = playlist.getPlaylistSegmentMatches(usingPredicate: { $0.tagDescriptor == VariantMatchTestTag.EXT_X_VARIANT_SEGMENT_SCOPE })
        
        XCTAssertEqual(testSegmentTags.count, 2)
        
        XCTAssertEqual(testSegmentTags[0].containsDiscontinuity, false)
        XCTAssertEqual(testSegmentTags[0].foundInHeader, false)
        XCTAssertEqual(testSegmentTags[0].mediaSequence, 2)
        XCTAssertEqual(testSegmentTags[0].tagGroupIndex, 2)
        XCTAssertEqual(testSegmentTags[0].tagIndex, 9)
        XCTAssertEqual(testSegmentTags[0].tagIndexRangeOfMediaGroup, 8...10)
        switch testSegmentTags[0].playlistTime {
        case .noTimeMatchForNonVODPlaylist:
            XCTFail("Not expecting this value")
        case .timeMatch(let timeRange):
            XCTAssertEqual(timeRange.start, CMTime(string: "6.0000")!)
            XCTAssertEqual(timeRange.duration, CMTime(string: "3.0000")!)
        }
        
        XCTAssertEqual(testSegmentTags[1].containsDiscontinuity, true)
        XCTAssertEqual(testSegmentTags[1].foundInHeader, false)
        XCTAssertEqual(testSegmentTags[1].mediaSequence, 4)
        XCTAssertEqual(testSegmentTags[1].tagGroupIndex, 4)
        XCTAssertEqual(testSegmentTags[1].tagIndex, 14)
        XCTAssertEqual(testSegmentTags[1].tagIndexRangeOfMediaGroup, 13...16)
        switch testSegmentTags[1].playlistTime {
        case .noTimeMatchForNonVODPlaylist:
            XCTFail("Not expecting this value")
        case .timeMatch(let timeRange):
            XCTAssertEqual(timeRange.start, CMTime(string: "12.0000")!)
            XCTAssertEqual(timeRange.duration, CMTime(string: "3.0000")!)
        }
        
        // quick test of testing more "normal" segment based tags with "match in header means no match"
        let testSegmentTagsHeaderNoMatch = playlist.getPlaylistSegmentMatches(usingPredicate: { $0.tagDescriptor == VariantMatchTestTag.EXT_X_VARIANT_SEGMENT_SCOPE },
                                                                              withMatchesInHeaderMatchingToFirstMediaSegment: false)
        
        XCTAssertEqual(testSegmentTagsHeaderNoMatch.count, 2)
        
        // quick test for tag types that do not appear
        let testSegmentDoesNotAppear = playlist.getPlaylistSegmentMatches(usingPredicate: { $0.tagDescriptor == VariantMatchTestTag.EXT_X_VARIANT_DOES_NOT_APPEAR })
        
        XCTAssertEqual(testSegmentDoesNotAppear.count, 0)
    }
    
    func testTimesForLivePlaylist() {
        let testHLS = """
#EXTM3U
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXTINF:3.00,0
segment0.ts
#EXTINF:3.00,1
segment1.ts
#EXTINF:3.00,2
#EXT-X-VARIANT-SEGMENT-SCOPE
segment2.ts
#EXTINF:3.00,3
segment3.ts
#EXTINF:3.00,4
#EXT-X-VARIANT-SEGMENT-SCOPE
#EXT-X-DISCONTINUITY
segment4.ts
#EXTINF:3.00,5
segment5.ts
"""
        let playlist = parseVariantPlaylist(inString: testHLS, tagTypes: [VariantMatchTestTag.self])

        let testSegmentTags = playlist.getPlaylistSegmentMatches(usingPredicate: { $0.tagDescriptor == VariantMatchTestTag.EXT_X_VARIANT_SEGMENT_SCOPE })
        
        XCTAssertEqual(testSegmentTags.count, 2)
        
        XCTAssertEqual(testSegmentTags[0].containsDiscontinuity, false)
        XCTAssertEqual(testSegmentTags[0].foundInHeader, false)
        XCTAssertEqual(testSegmentTags[0].mediaSequence, 2)
        XCTAssertEqual(testSegmentTags[0].tagGroupIndex, 2)
        XCTAssertEqual(testSegmentTags[0].tagIndex, 7)
        XCTAssertEqual(testSegmentTags[0].tagIndexRangeOfMediaGroup, 6...8)
        switch testSegmentTags[0].playlistTime {
        case .noTimeMatchForNonVODPlaylist:
            // expected
            break
        case .timeMatch(_):
            XCTFail("Not expecting this value")
        }
        
        XCTAssertEqual(testSegmentTags[1].containsDiscontinuity, true)
        XCTAssertEqual(testSegmentTags[1].foundInHeader, false)
        XCTAssertEqual(testSegmentTags[1].mediaSequence, 4)
        XCTAssertEqual(testSegmentTags[1].tagGroupIndex, 4)
        XCTAssertEqual(testSegmentTags[1].tagIndex, 12)
        XCTAssertEqual(testSegmentTags[1].tagIndexRangeOfMediaGroup, 11...14)
        switch testSegmentTags[1].playlistTime {
        case .noTimeMatchForNonVODPlaylist:
            // expected
            break
        case .timeMatch(_):
            XCTFail("Not expecting this value")
        }
    }
    
    func testEmptyPlaylist() {
        let testHLS = """
#EXTM3U
#EXT-X-VARIANT-WHOLE-PLAYLIST-SCOPE
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXT-X-ENDLIST
"""
        let playlist = parseVariantPlaylist(inString: testHLS, tagTypes: [VariantMatchTestTag.self])
        
        let testSegmentTags = playlist.getPlaylistSegmentMatches(usingPredicate: { $0.tagDescriptor == VariantMatchTestTag.EXT_X_VARIANT_WHOLE_PLAYLIST_SCOPE })
        
        XCTAssertEqual(testSegmentTags.count, 0)
    }
}

fileprivate enum VariantMatchTestTag: String {
    
    case EXT_X_VARIANT_WHOLE_PLAYLIST_SCOPE = "EXT-X-VARIANT-WHOLE-PLAYLIST-SCOPE"
    case EXT_X_VARIANT_SEGMENT_SCOPE = "EXT-X-VARIANT-SEGMENT-SCOPE"
    case EXT_X_VARIANT_DOES_NOT_APPEAR = "EXT-X-VARIANT-DOES-NOT-APPEAR"
}

extension VariantMatchTestTag: PlaylistTagDescriptor {
    
    public static func constructTag(tag: String) -> PlaylistTagDescriptor? {
        return VariantMatchTestTag(rawValue: tag)
    }
    
    public func toString() -> String {
        return self.rawValue
    }
    
    public func isEqual(toTagDescriptor tagDescriptor: PlaylistTagDescriptor) -> Bool {
        guard let tag = tagDescriptor as? VariantMatchTestTag else {
            return false
        }
        return tag.rawValue == self.rawValue
    }
    
    public static func parser(forTag tag: PlaylistTagDescriptor) -> PlaylistTagParser? {
        guard let _ = VariantMatchTestTag(rawValue: tag.toString()) else {
            return nil
        }
        return GenericNoDataTagParser(tag: tag)
    }
    
    public static func writer(forTag tag: PlaylistTagDescriptor) -> PlaylistTagWriter? {
        return nil
    }
    
    public static func validator(forTag tag: PlaylistTagDescriptor) -> PlaylistTagValidator? {
        return nil
    }
    
    public func scope() -> PlaylistTagDescriptorScope {
        switch self {
        case .EXT_X_VARIANT_SEGMENT_SCOPE:
            return .mediaSegment
        case .EXT_X_VARIANT_WHOLE_PLAYLIST_SCOPE:
            return .wholePlaylist
        case .EXT_X_VARIANT_DOES_NOT_APPEAR:
            return .mediaSegment
        }
    }
    
    public func type() -> PlaylistTagDescriptorType {
        return .noValue
    }
    
    public static func constructDescriptor(fromStringRef string: MambaStringRef) -> PlaylistTagDescriptor? {
        var tagName = string.stringValue()
        tagName.remove(at: tagName.startIndex)
        return constructTag(tag: tagName)
    }
}
