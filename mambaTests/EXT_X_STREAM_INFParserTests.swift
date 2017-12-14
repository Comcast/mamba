//
//  EXT_X_STREAM_INFParserTests.swift
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

class EXT_X_STREAM_INFParserTests: XCTestCase {

    func testParserCorrectInputDurationOnly() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!
        
        do {
            let tag = try parser.parseTag("PROGRAM-ID=1, BANDWIDTH=200000\n")
            XCTAssert(tag.valueDictionary[PantosValue.bandwidthBPS.rawValue] == "200000", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.programId.rawValue] == "1", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserNilInput() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!
        
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
    
    func testParserCorrectFullInput() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!
        
        do {
            let tag = try parser.parseTag("BANDWIDTH=560400,AUDIO=\"g104000\",PROGRAM-ID=1,CODECS=\"avc1.4d401f,mp4a.40.5\",RESOLUTION=320x180\n")
            XCTAssert(tag.valueDictionary[PantosValue.bandwidthBPS.rawValue] == "560400", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.programId.rawValue] == "1", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.audioGroup.rawValue] == "\"g104000\"", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.codecs.rawValue] == "\"avc1.4d401f,mp4a.40.5\"", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.resolution.rawValue] == "320x180", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserCorrectExtraTags() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!
        
        do {
            let tag = try parser.parseTag("BANDWIDTH=560400,AUDIO=\"g104000\",PROGRAM-ID=1,CODECS=\"avc1.4d401f,mp4a.40.5\",RESOLUTION=320x180,EXTRA-KEY=EXTRA-VALUE\n")
            XCTAssert(tag.valueDictionary[PantosValue.bandwidthBPS.rawValue] == "560400", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.programId.rawValue] == "1", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.audioGroup.rawValue] == "\"g104000\"", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.codecs.rawValue] == "\"avc1.4d401f,mp4a.40.5\"", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.resolution.rawValue] == "320x180", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary["EXTRA-KEY"] == "EXTRA-VALUE", "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserNoArray() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!
        
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
    
    func testParserNoProgramId() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!
        
        do {
            let tag = try parser.parseTag("PROGRAM-ID=1\n")
            XCTAssert(tag.valueDictionary[PantosValue.programId.rawValue] == "1", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary.count == 1, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserNoBandwidth() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!
        
        do {
            let tag = try parser.parseTag("BANDWIDTH=200000\n")
            XCTAssert(tag.valueDictionary[PantosValue.bandwidthBPS.rawValue] == "200000", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary.count == 1, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserCorrectInputNonNumericProgramId() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!
        
        do {
            let tag = try parser.parseTag("PROGRAM-ID=A, BANDWIDTH=200000\n")
            XCTAssert(tag.valueDictionary[PantosValue.programId.rawValue] == "A", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.bandwidthBPS.rawValue] == "200000", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary.count == 2, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testParserCorrectInputNonNumericBandwidth() {
        let parser = PantosTag.parserFromTag(PantosTag.EXT_X_STREAM_INF)!

        do {
            let tag = try parser.parseTag("PROGRAM-ID=1, BANDWIDTH=A\n")
            XCTAssert(tag.valueDictionary[PantosValue.programId.rawValue] == "1", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary[PantosValue.bandwidthBPS.rawValue] == "A", "Tag did not parse properly")
            XCTAssert(tag.valueDictionary.count == 2, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
}
