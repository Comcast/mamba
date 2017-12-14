//
//  EXT_X_ALLOW_CACHETagParserTests.swift
//  mamba
//
//  Created by Mohan on 7/15/16.
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

class EXT_X_ALLOW_CACHETagParserTests: XCTestCase {

    func testParseCorrectInput() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_ALLOW_CACHE)
 
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "YES")
            XCTAssert(valueDictionary[PantosValue.allowCache.rawValue]?.value == "YES", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "NO")
            XCTAssert(valueDictionary[PantosValue.allowCache.rawValue]?.value == "NO", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParseNilValue() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_ALLOW_CACHE)
        
        do {
            let _ = try parser!.parseTag(fromTagString: nil)
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
