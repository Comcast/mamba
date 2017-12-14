//
//  EXT_X_MEDIATagParserTests.swift
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

class EXT_X_MEDIATagParserTests: XCTestCase {

    func testMinimalTag() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_MEDIA)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "TYPE=AUDIO,GROUP-ID=\"g104000\",NAME=\"English\"")
            
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.value == "AUDIO", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.value == "g104000", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.value == "English", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.quoteEscaped == true, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }

    func testFullTag1() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_MEDIA)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "TYPE=AUDIO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",ASSOC-LANGUAGE=\"es\",DEFAULT=YES,AUTOSELECT=YES")
            
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.value == "AUDIO", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.value == "g104000", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.value == "English", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.language.toString()]?.value == "en", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.language.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.assocLanguage.toString()]?.value == "es", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.assocLanguage.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.defaultMedia.toString()]?.value == "YES", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.defaultMedia.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.autoselect.toString()]?.value == "YES", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.autoselect.toString()]?.quoteEscaped == false, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }

    func testFullTag2() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_MEDIA)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "TYPE=AUDIO,GROUP-ID=\"g147200\",NAME=\"Spanish\",LANGUAGE=\"es\",URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-sap-bandwidth-147200-repid-147200.m3u8\"")
            
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.value == "AUDIO", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.value == "g147200", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.value == "Spanish", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.language.toString()]?.value == "es", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.language.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.toString()]?.value == "IP_720p60_51_SAP_TS/4242/format-hls-track-sap-bandwidth-147200-repid-147200.m3u8", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.toString()]?.quoteEscaped == true, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }

    func testSubTitlesTag1() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_MEDIA)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English (Forced)\",DEFAULT=NO,AUTOSELECT=NO,FORCED=YES,LANGUAGE=\"en\",URI=\"subtitles/eng_forced/prog_index.m3u8\"")
            
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.value == "SUBTITLES", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.value == "subs", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.value == "English (Forced)", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.language.toString()]?.value == "en", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.language.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.toString()]?.value == "subtitles/eng_forced/prog_index.m3u8", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.autoselect.toString()]?.value == "NO", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.autoselect.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.forced.toString()]?.value == "YES", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.forced.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.defaultMedia.toString()]?.value == "NO", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.defaultMedia.toString()]?.quoteEscaped == false, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
    func testSubTitlesTag2() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_MEDIA)!
        
        do {
            let valueDictionary = try parser.parseTag(fromTagString: "TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"en\",CHARACTERISTICS=\"public.accessibility.transcribes-spoken-dialog, public.accessibility.describes-music-and-sound\",URI=\"subtitles/eng/prog_index.m3u8\"")
            
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.value == "SUBTITLES", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.type.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.value == "subs", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.groupId.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.value == "English", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.name.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.language.toString()]?.value == "en", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.language.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.toString()]?.value == "subtitles/eng/prog_index.m3u8", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.uri.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.characteristics.toString()]?.value == "public.accessibility.transcribes-spoken-dialog, public.accessibility.describes-music-and-sound", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.characteristics.toString()]?.quoteEscaped == true, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.forced.toString()]?.value == "NO", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.forced.toString()]?.quoteEscaped == false, "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.defaultMedia.toString()]?.value == "YES", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.defaultMedia.toString()]?.quoteEscaped == false, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }

}
