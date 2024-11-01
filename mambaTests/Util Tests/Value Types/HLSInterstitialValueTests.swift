//
//  HLSInterstitialValueTests.swift
//  mambaTests
//
//  Created by Migneco, Ray on 10/22/24.
//  Copyright © 2024 Comcast Corporation.
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

final class HLSInterstitialValueTests: XCTestCase {
    
    func testSnapAlignment() {
        var vals = HLSInterstitialAlignment.Snap.allCases
        
        XCTAssertEqual(HLSInterstitialAlignment(values: vals).values.count, 2)
        
        // test de-duping
        vals.append(HLSInterstitialAlignment.Snap.in)
        XCTAssertEqual(HLSInterstitialAlignment(values: vals).values.count, 2)
        
        // create from string
        let inputStr = "IN,OUT"
        XCTAssertEqual(HLSInterstitialAlignment(string: inputStr)?.values.count, 2)
        
        let badInput = "up,down"
        XCTAssertNil(HLSInterstitialAlignment(string: badInput))
    }
    
    func testRestrictions() {
        var vals = HLSInterstitialSeekRestrictions.Restriction.allCases
        
        XCTAssertEqual(HLSInterstitialSeekRestrictions(restrictions: vals).restrictions.count, 2)
        
        // de-dupe
        vals.append(HLSInterstitialSeekRestrictions.Restriction.jump)
        XCTAssertEqual(HLSInterstitialSeekRestrictions(restrictions: vals).restrictions.count, 2)
        
        let inputStr = "SKIP,JUMP"
        XCTAssertEqual(HLSInterstitialSeekRestrictions(string: inputStr)?.restrictions.count, 2)
        
        let badInput = "Forward,Back"
        XCTAssertNil(HLSInterstitialSeekRestrictions(string: badInput))
    }

}
