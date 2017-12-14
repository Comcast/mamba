//
//  GenericSingleValueTagParserTests.swift
//  mamba
//
//  Created by David Coufal on 7/15/16.
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

class GenericSingleValueTagParserTests: XCTestCase {

    func testParserCorrectInput() {
        let parser = constructTestParser()
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "10")
            
            XCTAssert(valueDictionary[PantosValue.targetDurationSeconds.rawValue]?.value == "10", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserNilInput() {
        let parser = constructTestParser()
        
        do {
            let _ = try parser.parseTag(fromTagString: nil)
            XCTAssert(false, "Parser should throw")
        }
        catch HLSParserError.malformedHLSTag {
            // expected result
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserNonNumberInput() {
        let parser = constructTestParser()
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "a")
            
            XCTAssert(valueDictionary[PantosValue.targetDurationSeconds.rawValue]?.value == "a", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }

    func constructTestParser() -> GenericSingleValueTagParser {
        return GenericSingleValueTagParser(tag: PantosTag.EXT_X_TARGETDURATION,
                                           singleValueIdentifier:PantosValue.targetDurationSeconds)
    }

}
