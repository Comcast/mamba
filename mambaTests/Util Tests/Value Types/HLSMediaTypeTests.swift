//
//  HLSMediaTypeTests.swift
//  mamba
//
//  Created by David Coufal on 8/19/16.
//  Copyright © 2016 Comcast Corporation.
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

class HLSMediaTypeTests: XCTestCase {

    func testMediaType() {
        let videoType = HLSMediaType(mediaType: "VIDEO")
        
        XCTAssert(videoType != nil, "not created")
        XCTAssert(videoType!.type == HLSMediaType.Media.Video, "assignment incorrect")
        
        let audioType = HLSMediaType(mediaType: "AUDIO")
        
        XCTAssert(audioType != nil, "not created")
        XCTAssert(audioType!.type == HLSMediaType.Media.Audio, "assignment incorrect")
    }
    
    func testMediaType1_Failure() {
        let mediaType = HLSMediaType(mediaType: "")
        
        XCTAssert(mediaType == nil, "should not have been created")
    }
    
    func testMediaType2_Failure() {
        let mediaType = HLSMediaType(mediaType: "a")
        
        XCTAssert(mediaType == nil, "should not have been created")
    }
    
    func testMediaType3_Failure() {
        let mediaType = HLSMediaType(mediaType: "VIDEO1")
        
        XCTAssert(mediaType == nil, "should not have been created")
    }
    
    func testMediaType4_Failure() {
        let mediaType = HLSMediaType(mediaType: "1VIDEO")
        
        XCTAssert(mediaType == nil, "should not have been created")
    }
    
}
