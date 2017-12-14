//
//  EXTINFParserTests.swift
//  helio
//
//  Created by David Coufal on 6/27/16.
//  Copyright © 2016 Comcast Corporation. This software and its contents are
//  Comcast confidential and proprietary. It cannot be used, disclosed, or
//  distributed without Comcast's prior written permission. Modification of this
//  software is only allowed at the direction of Comcast Corporation. All allowed
//  modifications must be provided to Comcast Corporation. All rights reserved.
//

import XCTest
@testable import helio

class EXTINFParserTests: XCTestCase {
    
    let title = "Game of Thrones"

    func testParserCorrectInputDurationOnly() {
        let parser = EXTINFTagParser()
        
        do {
            let tag = try parser.parseTag("10\n")
            XCTAssert(tag.valueDictionary[PantosValue.durationSeconds.rawValue] == "10", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.title.rawValue] == nil, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserCorrectInputDurationFloat() {
        let parser = EXTINFTagParser()
        
        do {
            let tag = try parser.parseTag("6.006\n")
            XCTAssert(Float(tag.valueDictionary[PantosValue.durationSeconds.rawValue]!) == 6.006, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserCorrectInputDurationTitle() {
        let parser = EXTINFTagParser()
        
        do {
            let tag = try parser.parseTag("1,\(title)\n")
            XCTAssert(tag.valueDictionary[PantosValue.durationSeconds.rawValue] == "1", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.title.rawValue] == title, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserCorrectInputDurationTitleExcessData() {
        let parser = EXTINFTagParser()
        
        do {
            let tag = try parser.parseTag("5001,\(title),\"Another string\",\"yet another string\"\n")
            XCTAssert(tag.valueDictionary[PantosValue.durationSeconds.rawValue] == "5001", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.title.rawValue] == title, "Tag did not parse properly")
            XCTAssert(tag.valueArrayCache?.count == 2, "Tag did not parse properly")
            XCTAssert(tag.valueArrayCache?[0] == "\"Another string\"", "Tag did not parse properly")
            XCTAssert(tag.valueArrayCache?[1] == "\"yet another string\"", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserNilInput() {
        let parser = EXTINFTagParser()
        
        do {
            let _ = try parser.parseTag(nil)
            XCTAssert(false, "Parser should throw")
        }
        catch(HLSParserError.malformedHLSTag(_, _)) {
            // expected result
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserNoArray() {
        let parser = EXTINFTagParser()
        
        do {
            let _ = try parser.parseTag("\n")
            XCTAssert(false, "Parser should throw")
        }
        catch(HLSParserError.malformedHLSTag(_, _)) {
            // expected result
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
}
