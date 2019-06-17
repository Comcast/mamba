//
//  ResolutionTests.swift
//  mamba
//
//  Created by David Coufal on 8/5/16.
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

class ResolutionTests: XCTestCase {
    
    func testResolution() {
        let resolution1080 = ResolutionValueType(resolution: "1920x1080")
        
        XCTAssert(resolution1080 != nil, "not created")
        XCTAssert(resolution1080!.w == 1920, "assignment incorrect")
        XCTAssert(resolution1080!.h == 1080, "assignment incorrect")
        
        let resolution720 = ResolutionValueType(width: 1280, height: 720)
        
        XCTAssert(resolution720.w == 1280, "assignment incorrect")
        XCTAssert(resolution720.h == 720, "assignment incorrect")
        
        XCTAssertFalse(resolution1080 == resolution720, "equality operators not working")
        XCTAssert(resolution1080 != resolution720, "equality operators not working")
        XCTAssert(resolution1080! > resolution720, "comparision operators not working")
        XCTAssert(resolution1080! >= resolution720, "comparision operators not working")
        XCTAssert(resolution720 < resolution1080!, "comparision operators not working")
        XCTAssert(resolution720 <= resolution1080!, "comparision operators not working")
        
        let resolution1080p = ResolutionValueType(width: 1920, height: 1080)
        
        XCTAssertFalse(resolution1080p == resolution720, "equality operators not working")
        XCTAssert(resolution1080p != resolution720, "equality operators not working")
        XCTAssert(resolution1080p > resolution720, "comparision operators not working")
        XCTAssert(resolution1080p >= resolution720, "comparision operators not working")
        XCTAssert(resolution720 < resolution1080p, "comparision operators not working")
        XCTAssert(resolution720 <= resolution1080p, "comparision operators not working")

        XCTAssert(resolution1080 == resolution1080p, "equality operators not working")
        XCTAssertFalse(resolution1080 != resolution1080p, "equality operators not working")
        XCTAssertFalse(resolution1080! > resolution1080p, "comparision operators not working")
        XCTAssert(resolution1080! >= resolution1080p, "comparision operators not working")
        XCTAssertFalse(resolution1080p < resolution1080!, "comparision operators not working")
        XCTAssert(resolution1080p <= resolution1080!, "comparision operators not working")
    }
    
    func testRatio() {
        let resolution4K = ResolutionValueType(resolution: "3840x2160")!
        let resolution1080 = ResolutionValueType(resolution: "1920x1080")!
        let resolution720 = ResolutionValueType(resolution: "1280x720")!
        let resolution432 = ResolutionValueType(resolution: "768x432")!
        let resolution360 = ResolutionValueType(resolution: "640x360")!
        let resolution288 = ResolutionValueType(resolution: "512x288")!
        let resolution180 = ResolutionValueType(resolution: "320x180")!
        
        XCTAssertTrue(resolution4K.is16x9, "16 x 9 detector not working")
        XCTAssertTrue(resolution1080.is16x9, "16 x 9 detector not working")
        XCTAssertTrue(resolution720.is16x9, "16 x 9 detector not working")
        XCTAssertTrue(resolution432.is16x9, "16 x 9 detector not working")
        XCTAssertTrue(resolution360.is16x9, "16 x 9 detector not working")
        XCTAssertTrue(resolution288.is16x9, "16 x 9 detector not working")
        XCTAssertTrue(resolution180.is16x9, "16 x 9 detector not working")
        XCTAssertFalse(resolution4K.is4x3, "4 x 3 detector not working")
        XCTAssertFalse(resolution1080.is4x3, "4 x 3 detector not working")
        XCTAssertFalse(resolution720.is4x3, "4 x 3 detector not working")
        XCTAssertFalse(resolution432.is4x3, "4 x 3 detector not working")
        XCTAssertFalse(resolution360.is4x3, "4 x 3 detector not working")
        XCTAssertFalse(resolution288.is4x3, "4 x 3 detector not working")
        XCTAssertFalse(resolution180.is4x3, "4 x 3 detector not working")
        XCTAssert(resolution4K.ratio == ResolutionValueType.ratio16x9)
        XCTAssert(resolution1080.ratio == ResolutionValueType.ratio16x9)
        XCTAssert(resolution720.ratio == ResolutionValueType.ratio16x9)
        XCTAssert(resolution432.ratio == ResolutionValueType.ratio16x9)
        XCTAssert(resolution360.ratio == ResolutionValueType.ratio16x9)
        XCTAssert(resolution288.ratio == ResolutionValueType.ratio16x9)
        XCTAssert(resolution180.ratio == ResolutionValueType.ratio16x9)
        
        let resolutionSD = ResolutionValueType(resolution: "640x480")!
        let resolutionEDTV576p = ResolutionValueType(resolution: "768x576")!
        
        XCTAssertTrue(resolutionSD.is4x3, "4 x 3 detector not working")
        XCTAssertTrue(resolutionEDTV576p.is4x3, "4 x 3 detector not working")
        XCTAssertFalse(resolutionSD.is16x9, "4 x 3 detector not working")
        XCTAssertFalse(resolutionEDTV576p.is16x9, "4 x 3 detector not working")
        XCTAssert(resolutionSD.ratio == ResolutionValueType.ratio4x3)
        XCTAssert(resolutionEDTV576p.ratio == ResolutionValueType.ratio4x3)
    }
    
    func testResolution1_Failure() {
        let resolution = ResolutionValueType(resolution: "")
        
        XCTAssert(resolution == nil, "should not have been created")
    }

    func testResolution2_Failure() {
        let resolution = ResolutionValueType(resolution: "a")
        
        XCTAssert(resolution == nil, "should not have been created")
    }

    func testResolution3_Failure() {
        let resolution = ResolutionValueType(resolution: "1080")
        
        XCTAssert(resolution == nil, "should not have been created")
    }

    func testResolution4_Failure() {
        let resolution = ResolutionValueType(resolution: "1920:1080")
        
        XCTAssert(resolution == nil, "should not have been created")
    }

    func testResolution5_Failure() {
        let resolution = ResolutionValueType(resolution: "x1080")
        
        XCTAssert(resolution == nil, "should not have been created")
    }
    
    func testResolution6_Failure() {
        let resolution = ResolutionValueType(resolution: "1920x")
        
        XCTAssert(resolution == nil, "should not have been created")
    }
    
}
