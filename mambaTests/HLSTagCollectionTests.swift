//
//  HLSTagCollectionTests.swift
//  mamba
//
//  Created by David Coufal on 12/12/17.
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

class HLSTagCollectionTests: XCTestCase {
    
    func testSortedBy() {
        let master = parsePlaylist(inFixtureName: "super8demuxed1_4242.m3u8")

        let tags = master.tags.sortedByResolutionBandwidth().filtered(by: PantosTag.EXT_X_STREAM_INF)
        
        XCTAssert(tags.count == 8)
        
        let tag1_bw: Int = tags[1].value(forValueIdentifier: PantosValue.bandwidthBPS)!
        let tag3_bw: Int = tags[3].value(forValueIdentifier: PantosValue.bandwidthBPS)!
        let tag7_bw: Int = tags[7].value(forValueIdentifier: PantosValue.bandwidthBPS)!
        let tag1_res: HLSResolution = tags[1].value(forValueIdentifier: PantosValue.resolution)!
        let tag3_res: HLSResolution = tags[3].value(forValueIdentifier: PantosValue.resolution)!
        let tag7_res: HLSResolution = tags[7].value(forValueIdentifier: PantosValue.resolution)!
        
        XCTAssert(tag1_bw < tag3_bw)
        XCTAssert(tag1_bw < tag7_bw)
        XCTAssert(tag3_bw < tag7_bw)
        XCTAssert(tag1_res < tag3_res)
        XCTAssert(tag1_res < tag7_res)
        XCTAssert(tag3_res < tag7_res)
    }
}
