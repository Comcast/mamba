//
//  EXT_X_KEYTagParserTests.swift
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

class EXT_X_KEYTagParserTests: XCTestCase {

    func testMinimalTag() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_KEY)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "METHOD=NONE")
            
            XCTAssert(valueDictionary[PantosValue.method.rawValue]?.value == "NONE", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.method.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testTwoTag() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_KEY)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "METHOD=AES-128,URI=\"https://priv.example.com/key.php?r=52\"")
            
            XCTAssert(valueDictionary[PantosValue.method.rawValue]?.value == "AES-128", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.method.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.value == "https://priv.example.com/key.php?r=52", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testThreeTags() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_KEY)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "METHOD=AES-128,URI=\"https://priv.example.com/key.php?r=52\", IV=0x9c7db8778570d05c3177c349fd9236aa")
            
            XCTAssert(valueDictionary[PantosValue.method.rawValue]?.value == "AES-128", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.method.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.value == "https://priv.example.com/key.php?r=52", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.ivector.rawValue]?.value == "0x9c7db8778570d05c3177c349fd9236aa", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.ivector.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }

    func testAllTags() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_KEY)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "METHOD=SAMPLE-AES,URI=\"skd://key65\", IV=0x9c7db8778570d05c3177c349fd9236aa,KEYFORMAT=\"com.apple.streamingkeydelivery\",KEYFORMATVERSIONS=\"1\"")
            
            XCTAssert(valueDictionary[PantosValue.method.rawValue]?.value == "SAMPLE-AES", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.method.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.value == "skd://key65", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.ivector.rawValue]?.value == "0x9c7db8778570d05c3177c349fd9236aa", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.ivector.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.keyformat.rawValue]?.value == "com.apple.streamingkeydelivery", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.keyformat.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.keyformatVersions.rawValue]?.value == "1", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.keyformatVersions.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParseNilValue() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_KEY)!
        
        do {
            let _ = try parser.parseTag(fromTagString: nil)
            XCTAssert(false, "Parser should throw")
        }
        catch HLSParserError.malformedHLSTag {
            //Expected result
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
}
