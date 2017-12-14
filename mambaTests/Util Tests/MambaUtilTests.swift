//
//  MambaUtilTests.swift
//  mamba
//
//  Created by David Coufal on 7/14/16.
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

class MambaUtilTests: XCTestCase {
    
    // MARK: String tests
    
    func testTrim() {
        let sampleString = "This is a test sentence."
        
        XCTAssert(" \(sampleString) ".trim() == sampleString, "trim() did not trim off white space")
        XCTAssert("\n\(sampleString)\n".trim() == sampleString, "trim() did not trim off newlines")
        XCTAssert("\r\(sampleString)\r".trim() == sampleString, "trim() did not trim off newlines")
        XCTAssert(" \r\n \n \(sampleString) \r\n \n".trim() == sampleString, "trim() did not trim off newlines")
    }
    
    // MARK: Date Tests
    
    func testISO8601Parsing_milliseconds() {
        let str = "2010-02-19T14:54:23.031+03:00"
        evaluateDate(str.parseISO8601Date(), hourOffset: 3)
    }
    
    func testISO8601Parsing_noMilliseconds() {
        let str = "2010-02-19T14:54:23+01:00"
        evaluateDate(str.parseISO8601Date(), hourOffset: 1)
    }

    func testISO8601Parsing_timeZone_minutes() {
        let str = "2010-02-19T14:54:23+01:30"
        evaluateDate(str.parseISO8601Date(), hourOffset: 1, minuteOffset: 30)
    }

    func testISO8601Parsing_timeZoneZ() {
        let str = "2010-02-19T14:54:23Z"
        evaluateDate(str.parseISO8601Date(), hourOffset: 0)
    }
    
    func testISO8601Parsing_timeZoneHours() {
        let str = "2010-02-19T14:54:23+02"
        evaluateDate(str.parseISO8601Date(), hourOffset: 2)
    }
    
    func testISO8601Parsing_timeZoneNegativeHours() {
        let str = "2010-02-19T14:54:23-02"
        evaluateDate(str.parseISO8601Date(), hourOffset: -2)
    }
    
    func testISO8601Parsing_junkData_Failure() {
        let non8601DateString1 = "clearly not a date"
        let non8601Date1 = non8601DateString1.parseISO8601Date()
        
        XCTAssertNil(non8601Date1, "Parsing of 8601 date should fail")
    }

    func testISO8601Parsing_emptyString_Failure() {
        let non8601DateString1 = ""
        let non8601Date1 = non8601DateString1.parseISO8601Date()
        
        XCTAssertNil(non8601Date1, "Parsing of 8601 date should fail")
    }
    
    func testISO8601Parsing_noTimeZone_Failure() {
        let non8601DateString1 = "2010-02-19T14:54:23"
        let non8601Date1 = non8601DateString1.parseISO8601Date()
        
        XCTAssertNil(non8601Date1, "Parsing of 8601 date should fail")
    }
    
    func testISO8601Parsing_justADate_Failure() {
        let non8601DateString1 = "2010-02-19"
        let non8601Date1 = non8601DateString1.parseISO8601Date()
        
        XCTAssertNil(non8601Date1, "Parsing of 8601 date should fail")
    }
    
    // MARK: Convenience String Init
    
    func testConvenienceString() {
        let desc = String(describing: PantosTag.EXTINF)
        XCTAssert(PantosTag(rawValue: desc) == PantosTag.EXTINF, "Round trip HLSTagDescriptor->String->HLSTagDescriptor did not work")
        let val = String(describing: PantosValue.Comment_Text)
        XCTAssert(PantosValue(rawValue: val) == PantosValue.Comment_Text, "Round trip HLSTagValueIdentifier->String->HLSTagValueIdentifier did not work")
    }
    
    // MARK: Date Tests - common functions
    
    // note that the hour and minute offsets are pretty dumb, so you have to select your test cases carefully
    func evaluateDate(_ date: Date?, hourOffset: Int, minuteOffset: Int = 0) {
        let calendar = Calendar.current
        
        XCTAssert(date != nil, "date should have parsed")
        
        let calComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .timeZone]
        let components = calendar.dateComponents(calComponents, from: date!)
        
        XCTAssert(components.year == 2010, "date did not parse as expected")
        XCTAssert(components.month == 2, "date did not parse as expected")
        XCTAssert(components.day == 19, "date did not parse as expected")
        XCTAssert(components.hour == 7 - hourOffset, "date did not parse as expected")
        XCTAssert(components.minute == 54 - minuteOffset, "date did not parse as expected")
        XCTAssert(components.second == 23, "date did not parse as expected")
        XCTAssert(components.timeZone == TimeZone.current, "date did not parse as expected") // if this fails, comment it out. Swift 3 made "localTimeZone" go away, and I'm just assuming that "current" is a replacement
    }
    
}
