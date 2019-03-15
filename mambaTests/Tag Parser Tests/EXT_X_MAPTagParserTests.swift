//
//  EXT_X_MAPTagParserTests.swift
//  mamba
//
//  Created by Mohan on 11/22/16.
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

class EXT_X_MAPTagParserTests: XCTestCase {
    
    func testMinimalTag() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_MAP)
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "URI=\"main.mp4\"")
            
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.value == "main.mp4", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
         }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testFullTag() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_MAP)
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "URI=\"main.mp4\",BYTERANGE=\"560@0\"")
            
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.value == "main.mp4", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.byterange.rawValue]?.value == "560@0", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.byterange.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParseNilValue() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_MAP)!
        
        do {
            let _ = try parser.parseTag(fromTagString: nil)
            XCTAssert(false, "Parser should throw")
        }
        catch ParserError.malformedHLSTag {
            //Expected result
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
}
