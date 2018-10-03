//
//  CMTimeMakeFromStringTests.swift
//  mamba
//
//  Created by Andrew Morrow on 8/7/17.
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
import mamba

class CMTimeMakeFromStringTests: XCTestCase {
    func testNull() {
        let time = mamba_CMTimeMakeFromString(nil, 0, nil)
        XCTAssert(!time.isValid)
    }
    
    func testParseInteger() {
        let time = mamba_CMTimeMakeFromString("1234", 0, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, 1234)
    }
    
    func testParseNegativeInteger() {
        let time = mamba_CMTimeMakeFromString("-1234", 0, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, -1234)
    }
    
    func testParseDecimal() {
        let time = mamba_CMTimeMakeFromString("2.002", 3, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, 2002)
    }
    
    func testParseSmallDecimal() {
        let time = mamba_CMTimeMakeFromString("0.002", 3, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, 2)
    }
    
    func testParseNegativeDecimal() {
        let time = mamba_CMTimeMakeFromString("-2.002", 3, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, -2002)
    }
    
    func testParseSmallNegativeDecimal() {
        let time = mamba_CMTimeMakeFromString("-0.002", 3, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, -2)
    }
    
    func testIgnoreWhitespace() {
        let time = mamba_CMTimeMakeFromString("                   \n2.002       ", 3, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, 2002)
    }
    
    func testIgnoreTrailingText() {
        let time = mamba_CMTimeMakeFromString("2.002,this is an EXTINF comment", 3, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, 2002)
    }
    
    func testSmallFloat() {
        let time = mamba_CMTimeMakeFromString("1.0", 5, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, 100000)
    }

    func testRejectBadFormats() {
        var time: CMTime
        
        time = mamba_CMTimeMakeFromString("", 3, nil)
        XCTAssert(!time.isValid)
        
        time = mamba_CMTimeMakeFromString("-", 3, nil)
        XCTAssert(!time.isValid)
        
        time = mamba_CMTimeMakeFromString("-.002", 3, nil)
        XCTAssert(!time.isValid)
        
        time = mamba_CMTimeMakeFromString(".002", 3, nil)
        XCTAssert(!time.isValid)
        
        time = mamba_CMTimeMakeFromString("2.", 3, nil)
        XCTAssert(!time.isValid)
        
        time = mamba_CMTimeMakeFromString("some words", 3, nil)
        XCTAssert(!time.isValid)
        
        time = mamba_CMTimeMakeFromString("2.words", 3, nil)
        XCTAssert(!time.isValid)
        
        time = mamba_CMTimeMakeFromString("2.-002", 3, nil)
        XCTAssert(!time.isValid)
    }
    
    func testOverflow() {
        let time = mamba_CMTimeMakeFromString("999999999999999999999999999999", 3, nil)
        XCTAssert(time.isNumeric)
        XCTAssertLessThan(time.value, 0, "Overflowed value should wrap around and be less than 0")
    }
    
    func testDecimalTruncation() {
        let time = mamba_CMTimeMakeFromString("0.999999999999999999999999999", 3, nil)
        XCTAssert(time.isNumeric)
        XCTAssertEqual(time.value, 999)
    }
    
    func testBadPrecision() {
        let time = mamba_CMTimeMakeFromString("2.002", 15, nil)
        XCTAssert(!time.isValid)
    }
    
    func testMinMax() {
        let maxString = String(Int64.max)
        let maxTime = mamba_CMTimeMakeFromString(maxString, 0, nil)
        XCTAssert(maxTime.isNumeric)
        XCTAssertEqual(maxTime.value, Int64.max)
        
        let minString = String(Int64.min)
        let minTime = mamba_CMTimeMakeFromString(minString, 0, nil)
        XCTAssert(minTime.isNumeric)
        XCTAssertEqual(minTime.value, Int64.min)
    }
}
