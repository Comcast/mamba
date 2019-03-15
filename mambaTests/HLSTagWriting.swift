//
//  HLSTagWriting.swift
//  mamba
//
//  Created by David Coufal on 10/10/16.
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

class HLSTagWriting: XCTestCase {
    
    static let samplePlaylist = "#EXTM3U\n#EXT-X-KEY:METHOD=AES-128,URI=\"https://priv.example.com/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa\n#EXTINF:2\n"
    
    func testWriteExisting_byString() {
        let playlist = parseVariantPlaylist(inString: HLSTagWriting.samplePlaylist)
        
        let numberValues = playlist.tags[0].numberOfParsedValues()
        var tag = playlist.tags[0]
        
        XCTAssert(playlist.tags[0].value(forKey: PantosValue.method.toString()) == "AES-128", "Should have parsed the playlist correctly")
        
        tag.set(value: "NONE", forKey: PantosValue.method.toString())
        
        XCTAssert(tag.value(forKey: PantosValue.method.toString()) == "NONE", "Should have parsed the playlist correctly")
        XCTAssert(tag.numberOfParsedValues() == numberValues, "Should have same number of parsed values")
    }
    
    func testWriteExisting_byValueIdentifier() {
        let playlist = parseVariantPlaylist(inString: HLSTagWriting.samplePlaylist)
        
        let numberValues = playlist.tags[0].numberOfParsedValues()
        var tag = playlist.tags[0]
        
        XCTAssert(playlist.tags[0].value(forValueIdentifier: PantosValue.method) == "AES-128", "Should have parsed the playlist correctly")
        
        tag.set(value: "NONE", forValueIdentifier: PantosValue.method)
        
        XCTAssert(tag.value(forValueIdentifier: PantosValue.method) == "NONE", "Should have parsed the playlist correctly")
        XCTAssert(tag.numberOfParsedValues() == numberValues, "Should have same number of parsed values")
    }
    
    func testWriteNew_byString() {
        let playlist = parseVariantPlaylist(inString: HLSTagWriting.samplePlaylist)
        
        let numberValues = playlist.tags[0].numberOfParsedValues()
        var tag = playlist.tags[0]
        
        tag.set(value: "TEST_VALUE", forKey: PantosValue.codecs.toString())
        
        XCTAssert(tag.value(forKey: PantosValue.codecs.toString()) == "TEST_VALUE", "Should have parsed the playlist correctly")
        XCTAssert(tag.numberOfParsedValues() == numberValues + 1, "Should have one more parsed value")
    }
    
    func testWriteNew_byValueIdentifier() {
        let playlist = parseVariantPlaylist(inString: HLSTagWriting.samplePlaylist)
        
        let numberValues = playlist.tags[0].numberOfParsedValues()
        var tag = playlist.tags[0]
        
        tag.set(value: "TEST_VALUE", forValueIdentifier: PantosValue.codecs)
        
        XCTAssert(tag.value(forValueIdentifier: PantosValue.codecs) == "TEST_VALUE", "Should have parsed the playlist correctly")
        XCTAssert(tag.numberOfParsedValues() == numberValues + 1, "Should have one more parsed value")
    }
    
}
