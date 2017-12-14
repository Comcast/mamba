//
//  EXT_X_PROGRAM_DATE_TIMEParserTests.swift
//  mamba
//
//  Created by Mohan on 7/18/16.
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

class EXT_X_PROGRAM_DATE_TIMEParserTests: XCTestCase {

    func testParserCorrectInput() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_PROGRAM_DATE_TIME)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "2010-02-19T14:54:23.031+08:00")
            
            XCTAssert(valueDictionary[PantosValue.programDateTime.rawValue]?.value == "2010-02-19T14:54:23.031+08:00", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
        
    func testParserNilInput() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_PROGRAM_DATE_TIME)
        
        do {
            let _ = try parser!.parseTag(fromTagString: nil) //InCorrect date_time format
            
            XCTAssert(false, "Parser should throw")
        }
        catch HLSParserError.malformedHLSTag {
            // expected result
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
}
