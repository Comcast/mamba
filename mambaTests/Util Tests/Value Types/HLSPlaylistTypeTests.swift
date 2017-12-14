//
//  HLSPlaylistTypeTests.swift
//  mamba
//
//  Created by David Coufal on 8/29/16.
//  Copyright © 2016 Comcast Cable Communications Management, LLC
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

class HLSPlaylistTypeTests: XCTestCase {
    
    func testPlaylistType() {
        let vodType = HLSPlaylistType(playlistType: "VOD")
        
        XCTAssert(vodType != nil, "not created")
        XCTAssert(vodType!.type == HLSPlaylistType.PlaylistType.VOD, "assignment incorrect")
        
        let eventType = HLSPlaylistType(playlistType: "EVENT")
        
        XCTAssert(eventType != nil, "not created")
        XCTAssert(eventType!.type == HLSPlaylistType.PlaylistType.Event, "assignment incorrect")
    }
    
    func testPlaylistType1_Failure() {
        let playlistType = HLSPlaylistType(playlistType: "")
        
        XCTAssert(playlistType == nil, "should not have been created")
    }
    
    func testPlaylistType2_Failure() {
        let playlistType = HLSPlaylistType(playlistType: "a")
        
        XCTAssert(playlistType == nil, "should not have been created")
    }
    
    func testPlaylistType3_Failure() {
        let playlistType = HLSPlaylistType(playlistType: "VOD1")
        
        XCTAssert(playlistType == nil, "should not have been created")
    }
    
    func testPlaylistType4_Failure() {
        let playlistType = HLSPlaylistType(playlistType: "1VOD")
        
        XCTAssert(playlistType == nil, "should not have been created")
    }
    
}
