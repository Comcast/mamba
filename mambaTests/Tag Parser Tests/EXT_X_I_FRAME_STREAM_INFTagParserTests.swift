//
//  EXT_X_I_FRAME_STREAM_INFTagParserTests.swift
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

class EXT_X_I_FRAME_STREAM_INFTagParserTests: XCTestCase {

    func testMinimalTag() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_I_FRAME_STREAM_INF)
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "BANDWIDTH=328400,URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-iframe-bandwidth-328400-repid-328400.m3u8\"")
            
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.value == "328400", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.value == "IP_720p60_51_SAP_TS/4242/format-hls-track-iframe-bandwidth-328400-repid-328400.m3u8", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testFullTag1() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_I_FRAME_STREAM_INF)
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "BANDWIDTH=328400,PROGRAM-ID=1,CODECS=\"avc1.4d401f\",RESOLUTION=320x180,URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-iframe-bandwidth-328400-repid-328400.m3u8\"")
            
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.value == "328400", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.value == "IP_720p60_51_SAP_TS/4242/format-hls-track-iframe-bandwidth-328400-repid-328400.m3u8", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.programId.rawValue]?.value == "1", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.programId.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.codecs.rawValue]?.value == "avc1.4d401f", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.codecs.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.resolution.rawValue]?.value == "320x180", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.resolution.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testFullTag2() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_I_FRAME_STREAM_INF)
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "BANDWIDTH=328400,PROGRAM-ID=1,CODECS=\"avc1.4d401f\",RESOLUTION=320x180,AUDIO=\"FAKEAUDIOGROUP\",VIDEO=\"FAKEVIDEOGROUP\",URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-iframe-bandwidth-328400-repid-328400.m3u8\"")
            
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.value == "328400", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.value == "IP_720p60_51_SAP_TS/4242/format-hls-track-iframe-bandwidth-328400-repid-328400.m3u8", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.programId.rawValue]?.value == "1", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.programId.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.codecs.rawValue]?.value == "avc1.4d401f", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.codecs.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.resolution.rawValue]?.value == "320x180", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.resolution.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.audioGroup.rawValue]?.value == "FAKEAUDIOGROUP", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.audioGroup.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.videoGroup.rawValue]?.value == "FAKEVIDEOGROUP", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.videoGroup.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }

    func testTagWithSubTitlesAndCC() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_I_FRAME_STREAM_INF)
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "BANDWIDTH=263851,CODECS=\"mp4a.40.2, avc1.4d400d\",RESOLUTION=416x234,AUDIO=\"FAKEAUDIOGROUP\",SUBTITLES=\"FAKESUBTITLESGROUP\",CLOSED-CAPTIONS=\"FAKECLOSEDCAPTIONSGROUP\"")
            
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.value == "263851", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.codecs.rawValue]?.value == "mp4a.40.2, avc1.4d400d", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.codecs.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.resolution.rawValue]?.value == "416x234", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.resolution.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.audioGroup.rawValue]?.value == "FAKEAUDIOGROUP", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.audioGroup.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.subtitlesGroup.rawValue]?.value == "FAKESUBTITLESGROUP", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.subtitlesGroup.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.closedCaptionsGroup.rawValue]?.value == "FAKECLOSEDCAPTIONSGROUP", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.closedCaptionsGroup.rawValue]?.quoteEscaped == true, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testPartialTag() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_I_FRAME_STREAM_INF)
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "BANDWIDTH=328400")
            
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.value == "328400", "Tag did not parse properly")
        }
        catch {
            // Expected
        }
    }

}
