//
//  String+Helio.swift
//  mamba
//
//  Created by David Coufal on 12/12/17.
//  Copyright © 2017 Comcast Corporation.
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

class String_HelioTests: XCTestCase {
    
    func testHLSTagDescriptor() {
        
        let descriptor = PantosTag.EXT_X_ALLOW_CACHE
        let string = descriptor.toString()
        let dummyString = "dummyString"
        
        XCTAssertTrue(String(tagDescriptor: descriptor) == string)
        
        XCTAssertTrue(string == descriptor)
        XCTAssertTrue(descriptor == string)
        XCTAssertFalse(string != descriptor)
        XCTAssertFalse(descriptor != string)
        
        XCTAssertFalse(dummyString == descriptor)
        XCTAssertFalse(descriptor == dummyString)
        XCTAssertTrue(dummyString != descriptor)
        XCTAssertTrue(descriptor != dummyString)
    }

    func testHLSTagValueIdentifier() {
        
        let valueid = PantosValue.bandwidthBPS
        let string = valueid.toString()
        let dummyString = "dummyString"
        
        XCTAssertTrue(String(valueIdentifier: valueid) == string)
        
        XCTAssertTrue(string == valueid)
        XCTAssertTrue(valueid == string)
        XCTAssertFalse(string != valueid)
        XCTAssertFalse(valueid != string)
        
        XCTAssertFalse(dummyString == valueid)
        XCTAssertFalse(valueid == dummyString)
        XCTAssertTrue(dummyString != valueid)
        XCTAssertTrue(valueid != dummyString)
    }
    
    func testTrim() {
        
        let testString = "testString"
        let spaces = "  \(testString) "
        let quotes = "\"\(testString)\""
        
        XCTAssert(testString == spaces.trim())
        XCTAssert(testString == quotes.trimDoubleQuotes())
    }

}
