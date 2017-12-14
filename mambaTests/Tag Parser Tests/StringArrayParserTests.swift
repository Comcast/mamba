//
//  StringArrayParserTests.swift
//  mamba
//
//  Created by David Coufal on 7/11/16.
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

class StringArrayParserTests: XCTestCase {

    func testStringArrayParser1() {
        let array = StringArrayParser.parseToArray(fromParsableString: "str1")
        
        XCTAssert(array.count == 1, "Unexpected array count")
        XCTAssert(array[0] == "str1", "Did not find expected string")
    }

    func testStringArrayParser2() {
        let array = StringArrayParser.parseToArray(fromParsableString: "str1,str2")
        
        XCTAssert(array.count == 2, "Unexpected array count")
        XCTAssert(array[0] == "str1", "Did not find expected string")
        XCTAssert(array[1] == "str2", "Did not find expected string")
    }

    func testStringArrayParser3() {
        let array = StringArrayParser.parseToArray(fromParsableString: "\"str1\"")
        
        XCTAssert(array.count == 1, "Unexpected array count")
        XCTAssert(array[0] == "\"str1\"", "Did not find expected string")
    }

    func testStringArrayParser4() {
        let array = StringArrayParser.parseToArray(fromParsableString: "\"str1\",\"str2\"")
        
        XCTAssert(array.count == 2, "Unexpected array count")
        XCTAssert(array[0] == "\"str1\"", "Did not find expected string")
        XCTAssert(array[1] == "\"str2\"", "Did not find expected string")
    }

    func testStringArrayParser5() {
        let array = StringArrayParser.parseToArray(fromParsableString: "str1,\"str2,str3\"")
        
        XCTAssert(array.count == 2, "Unexpected array count")
        XCTAssert(array[0] == "str1", "Did not find expected string")
        XCTAssert(array[1] == "\"str2,str3\"", "Did not find expected string")
    }
    
    func testStringArrayParser6() {
        let array = StringArrayParser.parseToArray(fromParsableString: "\"str1,str2\",\"str2,str3\"")
        
        XCTAssert(array.count == 2, "Unexpected array count")
        XCTAssert(array[0] == "\"str1,str2\"", "Did not find expected string")
        XCTAssert(array[1] == "\"str2,str3\"", "Did not find expected string")
    }
    
    func testStringArrayParser7() {
        let array = StringArrayParser.parseToArray(fromParsableString: "\"str1,str2\",str3")
        
        XCTAssert(array.count == 2, "Unexpected array count")
        XCTAssert(array[0] == "\"str1,str2\"", "Did not find expected string")
        XCTAssert(array[1] == "str3", "Did not find expected string")
    }
    
    func testStringArrayParser8() {
        let array = StringArrayParser.parseToArray(fromParsableString: "\"str1,str2\",\"str2,str3\",\"str5,str6\"")
        
        XCTAssert(array.count == 3, "Unexpected array count")
        XCTAssert(array[0] == "\"str1,str2\"", "Did not find expected string")
        XCTAssert(array[1] == "\"str2,str3\"", "Did not find expected string")
        XCTAssert(array[2] == "\"str5,str6\"", "Did not find expected string")
    }
    
    func testStringArrayParser9() {
        let array = StringArrayParser.parseToArray(fromParsableString: ",")
        
        XCTAssert(array.count == 2, "Unexpected array count")
        XCTAssert(array[0] == "", "Did not find expected string")
        XCTAssert(array[1] == "", "Did not find expected string")
    }
    
    func testStringArrayParser10() {
        let array = StringArrayParser.parseToArray(fromParsableString: ",\"\"")
        
        XCTAssert(array.count == 2, "Unexpected array count")
        XCTAssert(array[0] == "", "Did not find expected string")
        XCTAssert(array[1] == "\"\"", "Did not find expected string")
    }
    
    func testStringArrayParser11() {
        let array = StringArrayParser.parseToArray(fromParsableString: ",\"") // slightly misformatted, but we can still parse with the unclosed quote
        
        XCTAssert(array.count == 2, "Unexpected array count")
        XCTAssert(array[0] == "", "Did not find expected string")
        XCTAssert(array[1] == "\"", "Did not find expected string")
    }
    
    func testStringArrayParser12() {
        let array = StringArrayParser.parseToArray(fromParsableString: "")
        XCTAssert(array.count == 0, "Unexpected array count")
    }
    
    func testStringArrayParser13() {
        let array = StringArrayParser.parseToArray(fromParsableString: "\"avc1.4d401f,mp4a.40.5\"", ignoreQuotes: true)
        XCTAssert(array.count == 2, "Unexpected array count")
    }
}
