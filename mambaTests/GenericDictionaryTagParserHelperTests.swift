//
//  GenericDictionaryTagParserHelperTests.swift
//  helio
//
//  Created by David Coufal on 7/12/16.
//  Copyright © 2016 Comcast Corporation. This software and its contents are
//  Comcast confidential and proprietary. It cannot be used, disclosed, or
//  distributed without Comcast's prior written permission. Modification of this
//  software is only allowed at the direction of Comcast Corporation. All allowed
//  modifications must be provided to Comcast Corporation. All rights reserved.
//

import XCTest

#if os(iOS)
    @testable import mamba
#else
    @testable import mambaTVOS
#endif

class GenericDictionaryTagParserHelperTests: XCTestCase {
    
    func testGenericDictionaryTagParserHelper1() {
        
        do {
            let result = try GenericDictionaryTagParserHelper.parseTag( fromParsableString: "Key1=Value1,Key2=Value2",
                                                                        tag: dummyTag)
            
            XCTAssert(result.valueDictionary.count == 2, "Misparsed tag body")
            XCTAssert(result.valueDictionary[HLSTagValueIdentifier_GenericDictParserTests.Key1.toString()] == "Value1", "Misparsed tag body")
            XCTAssert(result.valueDictionary[HLSTagValueIdentifier_GenericDictParserTests.Key2.toString()] == "Value2", "Misparsed tag body")
            XCTAssert(result.valueArrayCache == nil, "Misparsed tag body")
        }
        catch HLSParserError.malformedHLSTag(_, _) {
            XCTAssert(false, "Should not throw")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
    
    func testGenericDictionaryTagParserHelper2() {
        
        do {
            let result = try GenericDictionaryTagParserHelper.parseTag( fromParsableString: "Key1=Value1,Key2=Value2",
                                                                        tag: dummyTag)
            
            XCTAssert(result.valueDictionary.count == 2, "Misparsed tag body")
            XCTAssert(result.valueDictionary[HLSTagValueIdentifier_GenericDictParserTests.Key1.toString()] == "Value1", "Misparsed tag body")
            XCTAssert(result.valueDictionary[HLSTagValueIdentifier_GenericDictParserTests.Key2.toString()] == "Value2", "Misparsed tag body")
            XCTAssert(result.valueArrayCache == nil, "Misparsed tag body")
        }
        catch HLSParserError.malformedHLSTag(_, _) {
            XCTAssert(false, "Should not throw")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
    
    func testGenericDictionaryTagParserHelper3() {
        
        do {
            let result = try GenericDictionaryTagParserHelper.parseTag( fromParsableString: "Key2=Value2",
                                                                        tag: dummyTag)
            
            XCTAssert(result.valueDictionary.count == 1, "Misparsed tag body")
            XCTAssert(result.valueArrayCache == nil, "Misparsed tag body")
            XCTAssert(result.valueDictionary[HLSTagValueIdentifier_GenericDictParserTests.Key2.toString()] == "Value2", "Misparsed tag body")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
    
    func testGenericDictionaryTagParserHelper4() {
        
        do {
            let result = try GenericDictionaryTagParserHelper.parseTag( fromParsableString: "",
                                                                        tag: dummyTag)
            
            XCTAssert(result.valueDictionary.count == 0, "Misparsed tag body")
            XCTAssert(result.valueArrayCache == nil, "Misparsed tag body")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
    
    func testGenericDictionaryTagParserHelper5() {
        
        do {
            let result = try GenericDictionaryTagParserHelper.parseTag( fromParsableString: "Key3=\"Value3,Value4\"",
                                                                        tag: dummyTag)
            
            XCTAssert(result.valueDictionary.count == 1, "Misparsed tag body")
            XCTAssert(result.valueArrayCache == nil, "Misparsed tag body")
            XCTAssert(result.valueDictionary[HLSTagValueIdentifier_GenericDictParserTests.Key3.toString()] == "\"Value3,Value4\"", "Misparsed tag body")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
    
    func testGenericDictionaryTagParserHelper6() {
        
        do {
            // base64 encoded "a" is "YQ==". testing bare base64 encoded values, since that can happen sometimes (although it should be escaped)
            // the double equals can cause confusion ...
            let result = try GenericDictionaryTagParserHelper.parseTag( fromParsableString: "Key3=YQ==",
                                                                        tag: dummyTag)
            
            XCTAssert(result.valueDictionary.count == 1, "Misparsed tag body")
            XCTAssert(result.valueArrayCache == nil, "Misparsed tag body")
            XCTAssert(result.valueDictionary[HLSTagValueIdentifier_GenericDictParserTests.Key3.toString()] == "YQ==", "Misparsed tag body")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }

    let dummyTag = PantosTag.EXT_X_TARGETDURATION // doesn't matter what this is set to, the parser only uses it to generate an exception
}

public enum HLSTagValueIdentifier_GenericDictParserTests: String {
    case Key1 = "Key1"
    case Key2 = "Key2"
    case Key3 = "Key3"
}

extension HLSTagValueIdentifier_GenericDictParserTests: HLSTagValueIdentifier {
    public func toString() -> String {
        return self.rawValue
    }
}


