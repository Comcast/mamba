//
//  VariantPlaylistMediaSpanTests.swift
//  mamba
//
//  Created by David Coufal on 3/12/19.
//  Copyright © 2019 Comcast Corporation.
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
//  limitations under the License. All rights reserved.
//

import XCTest

@testable import mamba

class VariantPlaylistMediaSpanTests: XCTestCase {
    
    let X_KEY_1 = "#EXT-X-KEY:METHOD=AES-128,URI=\"https://fake.licensegenerator.wherever\",IV=0xDEADBEEFDEADBEEFDEADBEEF\n"
    let X_KEY_2 = "#EXT-X-KEY:METHOD=NONE\n"
    
    var hlsArray =
        ["#EXTM3U\n",
         "#EXT-X-TARGETDURATION:6\n", // index: 0
            "#EXT-X-VERSION:3\n",
            "#EXT-X-MEDIA-SEQUENCE:0\n",
            "#EXT-X-PLAYLIST-TYPE:VOD\n",
            "#EXT-X-MAP:URI=\"test.mp4\",BYTERANGE=\"610@0\"\n",
            "#EXTINF:5.96430,\n", // index: 6  time range: 0.0 - 5.96430
            "ro650_0.ts\n",
            "#EXTINF:5.96429,\n", // index: 8  time range: 5.96430 - 11.9286
            "ro650_1.ts\n",
            "#EXTINF:5.96429,\n", // index: 10 time range: 11.9286 - 17.8929
            "ro650_2.ts\n",
            "#EXTINF:5.96430,\n", // index: 12 time range: 17.8929 - 23.8572
            "ro650_3.ts\n",
            "#EXTINF:5.96429,\n",// index: 14 time range: 23.8672 - 29.8215
            "ro650_4.ts\n",
            "#EXTINF:5.96429,\n", // index: 16 time range: 29.8215 - 35.7858
            "ro650_5.ts\n",
            "#EXTINF:5.96429,\n", // index: 18 time range: 35.7858 - 41.7501
            "ro650_6.ts\n",
            "#EXTINF:5.96430,\n", // index: 20 time range: 41.7501 - 47.7144
            "ro650_7.ts\n",
            "#EXTINF:5.29696,\n", // index: 22 time range: 47.7144 - 53.01136
            "ro650_8.ts\n",
            "#EXT-X-ENDLIST\n"]
    
    func runTest(hlsString: String, expectedSpans: [MediaGroupIndexRange]) {
        
        let playlist = parseVariantPlaylist(inString: hlsString)
        let validationIssues = PlaylistValidator.validate(variantPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
        
        XCTAssert(playlist.mediaSpans.count == expectedSpans.count, "Expected span count did not equal actual span count")
        for (index, expectedSpan) in expectedSpans.enumerated() {
            
            let span = playlist.mediaSpans[index]
            XCTAssertEqual(span.tagMediaSpan, expectedSpan, "Expected span \(expectedSpan) does not equal actual span \(span)")
        }
    }
    
    func testNoSpan() {
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [])
    }
    
    func testSingleSpanInMediaGroup() {
        hlsArray.insert(X_KEY_1, at: 7)
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [0...8])
    }
    
    func testSingleSpanInHeader() {
        hlsArray.insert(X_KEY_1, at: 3)
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [0...8])
    }
    
    func testMultipleSpansInMediaGroups() {
        hlsArray.insert(X_KEY_1, at: 7)
        hlsArray.insert(X_KEY_2, at: 12)
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [0...1, 2...8])
    }
    
    func testMultipleSpansInHeader() {
        hlsArray.insert(X_KEY_1, at: 2)
        hlsArray.insert(X_KEY_2, at: 3)
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [0...8])
    }
    
    func testSingleSpansInHeaderAndMediaGroup() {
        hlsArray.insert(X_KEY_1, at: 2)
        hlsArray.insert(X_KEY_2, at: 16)
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [0...3, 4...8])
    }
    
    func testMultipleSpansInHeaderAndMediaGroup() {
        hlsArray.insert(X_KEY_1, at: 2)
        hlsArray.insert(X_KEY_2, at: 3)
        hlsArray.insert(X_KEY_1, at: 8)
        hlsArray.insert(X_KEY_2, at: 13)
        hlsArray.insert(X_KEY_1, at: 21)
        let hlsString = hlsArray.joined()
        runTest(hlsString: hlsString, expectedSpans: [0...1, 2...4, 5...8])
    }
}
