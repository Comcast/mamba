//
//  HLSTagGroupTests.swift
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

class HLSTagGroupTests: XCTestCase {
    
    func testTagGroup() {
        let begin = 34526
        let end = 76352
        let tagGroup = TagGroup(range: begin...end)
        
        XCTAssert(tagGroup.debugDescription.contains("\(begin)"))
        XCTAssert(tagGroup.debugDescription.contains("\(end)"))
        
        XCTAssert(tagGroup.startIndex == begin)
        XCTAssert(tagGroup.endIndex == end)
    }

    func testMediaSegmentTagGroup() {
        let begin = 34526
        let end = 76352
        let mediaSequence = 25635
        let timeRange = CMTimeRange(start: CMTime(seconds: 13.24, preferredTimescale: CMTimeScale.defaultMambaTimeScale), duration: CMTime(seconds: 15.77, preferredTimescale: CMTimeScale.defaultMambaTimeScale))
        
        let tagGroup = MediaSegmentTagGroup(range: begin...end, mediaSequence: mediaSequence, timeRange: timeRange, discontinuity: false)
        
        XCTAssert(tagGroup.debugDescription.contains("\(begin)"))
        XCTAssert(tagGroup.debugDescription.contains("\(end)"))
        XCTAssert(tagGroup.debugDescription.contains("\(mediaSequence)"))
        
        XCTAssert(tagGroup.startIndex == begin)
        XCTAssert(tagGroup.endIndex == end)
        XCTAssert(tagGroup.mediaSequence == mediaSequence)
        XCTAssert(tagGroup.timeRange == timeRange)
        XCTAssert(tagGroup.discontinuity == false)
    }
    
    func testTagSpan() {
        let begin = 34526
        let end = 76352
        let extinfTagData = HLSStringRef(string: "2.002")
        let tag = HLSTag(tagDescriptor: PantosTag.EXTINF, tagData:extinfTagData, tagName: HLSStringRef(string: PantosTag.EXTINF.toString()), duration: extinfTagData.extinfSegmentDuration())
        let tagSpan = TagSpan(parentTag: tag, tagMediaSpan: begin...end)
        
        XCTAssert(tagSpan.debugDescription.contains("\(begin)"))
        XCTAssert(tagSpan.debugDescription.contains("\(end)"))
        
        XCTAssert(tagSpan.startIndex == begin)
        XCTAssert(tagSpan.endIndex == end)
        XCTAssert(tagSpan.parentTag.tagDescriptor == tag.tagDescriptor)
    }
}
