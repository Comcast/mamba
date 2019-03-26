//
//  StringDictionaryParserTests.swift
//  mamba
//
//  Created by David Coufal on 7/8/16.
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

class StringDictionaryParserTests: XCTestCase {
    
    func testStringDictionaryParser0() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=value1")
            
            XCTAssert(dict.count == 1, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == false, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser1() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1\"")
            
            XCTAssert(dict.count == 1, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser2() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=value1,key2=value2")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == false, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value2", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == false, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }

    func testStringDictionaryParser3() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=value1,key2=\"value2,value3\"")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == false, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value2,value3", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }

    func testStringDictionaryParser4() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1,value2\",key2=value3")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1,value2", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == false, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser5() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1,value2\",key2=\"value3,value4\"")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1,value2", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3,value4", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }

    func testStringDictionaryParser6() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1,value2,value3\",key2=\"value3,value4\"")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1,value2,value3", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3,value4", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser7() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1,value2\",key2=value3,key3=\"value5,value6\"")
            
            XCTAssert(dict.count == 3, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1,value2", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == false, "Did not find expected pair")
            XCTAssert(dict["key3"]?.value == "value5,value6", "Did not find expected pair")
            XCTAssert(dict["key3"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser8() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=value1,key2=\"value3,value4\",key3=\"value5,value6\"")
            
            XCTAssert(dict.count == 3, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == false, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3,value4", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key3"]?.value == "value5,value6", "Did not find expected pair")
            XCTAssert(dict["key3"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser9() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1,value2\",key2=\"value3,value4\",key3=value5")
            
            XCTAssert(dict.count == 3, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1,value2", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3,value4", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key3"]?.value == "value5", "Did not find expected pair")
            XCTAssert(dict["key3"]?.quoteEscaped == false, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser10() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text=\"text,text") // slightly misformatted, but we can deal with the missing closing quote
            
            XCTAssert(dict.count == 1, "Unexpected dict count")
            XCTAssert(dict["text"]?.value == "\"text,text", "Did not find expected pair")
            XCTAssert(dict["text"]?.quoteEscaped == false, "Did not find expected pair")
       }
        catch {
            // expected
        }
    }
    
    func testStringDictionaryParser11() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1=value2\"")
            
            XCTAssert(dict.count == 1, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1=value2", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser12() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=value1,key2=\"value2=value3\"")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == false, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value2=value3", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser13() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1=value2\",key2=\"value3=value4\"")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1=value2", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3=value4", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser14() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1=value2\",key2=\"value3\",key3=\"value4=value5\"")
            
            XCTAssert(dict.count == 3, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1=value2", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key3"]?.value == "value4=value5", "Did not find expected pair")
            XCTAssert(dict["key3"]?.quoteEscaped == true, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser15() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "key1=\"value1,value2\",key2=\"value3=value4,value5=value6\",key3=value7")
            
            XCTAssert(dict.count == 3, "Unexpected dict count")
            XCTAssert(dict["key1"]?.value == "value1,value2", "Did not find expected pair")
            XCTAssert(dict["key1"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key2"]?.value == "value3=value4,value5=value6", "Did not find expected pair")
            XCTAssert(dict["key2"]?.quoteEscaped == true, "Did not find expected pair")
            XCTAssert(dict["key3"]?.value == "value7", "Did not find expected pair")
            XCTAssert(dict["key3"]?.quoteEscaped == false, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser16() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text1=,text2=text3")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["text1"]?.value == "", "Did not find expected pair")
            XCTAssert(dict["text1"]?.quoteEscaped == false, "Did not find expected pair")
            XCTAssert(dict["text2"]?.value == "text3", "Did not find expected pair")
            XCTAssert(dict["text2"]?.quoteEscaped == false, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser17() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text1=text2,text3=")
            
            XCTAssert(dict.count == 2, "Unexpected dict count")
            XCTAssert(dict["text1"]?.value == "text2", "Did not find expected pair")
            XCTAssert(dict["text1"]?.quoteEscaped == false, "Did not find expected pair")
            XCTAssert(dict["text3"]?.value == "", "Did not find expected pair")
            XCTAssert(dict["text3"]?.quoteEscaped == false, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParser18() {
        do {
            let dict = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text1=")
            
            XCTAssert(dict.count == 1, "Unexpected dict count")
            XCTAssert(dict["text1"]?.value == "", "Did not find expected pair")
            XCTAssert(dict["text1"]?.quoteEscaped == false, "Did not find expected pair")
        }
        catch {
            XCTAssert(false, "should not throw")
        }
    }
    
    func testStringDictionaryParserFailure1() {
        do {
            let _ = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text")
            
            XCTAssert(false, "should throw")
        }
        catch {
            // expected
        }
    }
    
    func testStringDictionaryParserFailure2() {
        do {
            let _ = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text,")
            
            XCTAssert(false, "should throw")
        }
        catch {
            // expected
        }
    }
    
    func testStringDictionaryParserFailure3() {
        do {
            let _ = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text,text")
            
            XCTAssert(false, "should throw")
        }
        catch {
            // expected
        }
    }

    func testStringDictionaryParserFailure4() {
        do {
            let _ = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text=text,text")
            
            XCTAssert(false, "should throw")
        }
        catch {
            // expected
        }
    }
    
    func testStringDictionaryParserFailure5() {
        do {
            let _ = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text,text=text")
            
            XCTAssert(false, "should throw")
        }
        catch {
            // expected
        }
    }
    
    func testStringDictionaryParserFailure6() {
        do {
            let _ = try StringDictionaryParser.parseToTagDictionary(fromParsableString: "text=text,text,text=text")
            
            XCTAssert(false, "should throw")
        }
        catch {
            // expected
        }
    }
    
}
