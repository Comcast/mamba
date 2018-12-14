//
//  HLSCodecArrayTests.swift
//  mamba
//
//  Created by David Coufal on 10/11/16.
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

class HLSCodecArrayTests: XCTestCase {
    
    func testHLSCodecArray() {
        let codecs1 = runTestsOn(codecString: "avc1.4d401f,mp4a.40.5")
        
        let codecs2 = HLSCodecArray(string: "avc1.4d401f,mp4a.40.5")
        let codecs3 = HLSCodecArray(string: "avc1.640029,mp4a.40.5")
        
        XCTAssertTrue(codecs1 == codecs2, "Equality operation should function")
        XCTAssertTrue(codecs1 != codecs3, "Equality operation should function")
        
        let codecs4 = HLSCodecArray(string: "")
        
        XCTAssertNil(codecs4, "Should have been created")
        
        let codecs5 = HLSCodecArray(string: "mp4a.40.5")
        XCTAssertTrue(codecs5?.containsAudio() ?? false, "Should contain audio")
        XCTAssertFalse(codecs5?.containsVideo() ?? false, "Should contain video")
        XCTAssertTrue(codecs5?.containsAudioOnly() ?? false, "Should contain only audio")
    }
    
    func testHLSCodecArrayWithSpaces() {
        let _ = runTestsOn(codecString: "avc1.4d401f, mp4a.40.5")
    }

    func testAudioVideoCodecDetection() {
        // audio + video
        runAVTest(onCodecString: "avc1.4d401f,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        // audio only
        runAVTest(onCodecString: "mp4a.40.5", expectingAudioOnly: true, expectingVideo: false, expectingAudio: true)
        // video only
        runAVTest(onCodecString: "avc1.4d401f", expectingAudioOnly: false, expectingVideo: true, expectingAudio: false)
        
        // testing different audio codec strings
        runAVTest(onCodecString: "avc1.4d401f,ec-3", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "avc1.4d401f,ac-3", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "avc1.4d401f,mp3", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)

        // testing different video codec strings
        runAVTest(onCodecString: "mp4v.20.9,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "svc,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "mvc1.800030,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "sevc,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "s263,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "hvc1.1.c.L120.90,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "vp9,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        
        // testing two video codecs
        runAVTest(onCodecString: "avc1.4d401f,hvc1.1.c.L120.90,mp4a.40.5", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "avc1.4d401f,hvc1.1.c.L120.90", expectingAudioOnly: false, expectingVideo: true, expectingAudio: false)
        // testing two audio codecs
        runAVTest(onCodecString: "avc1.4d401f,mp4a.40.5,ec-3", expectingAudioOnly: false, expectingVideo: true, expectingAudio: true)
        runAVTest(onCodecString: "mp4a.40.5,ec-3", expectingAudioOnly: true, expectingVideo: false, expectingAudio: true)
    }
    
    func runAVTest(onCodecString codecString: String,
                   expectingAudioOnly: Bool,
                   expectingVideo: Bool,
                   expectingAudio: Bool) {
        
        let codecs = HLSCodecArray(string: codecString)
        
        XCTAssert(codecs?.containsAudioOnly() == expectingAudioOnly, "Expecting a audio only value of \(expectingAudioOnly) for codecs: \"\(codecString)\"")
        XCTAssert(codecs?.containsVideo() == expectingVideo, "Expecting a video value of \(expectingVideo) for codecs: \"\(codecString)\"")
        XCTAssert(codecs?.containsAudio() == expectingAudio, "Expecting a audio value of \(expectingAudio) for codecs: \"\(codecString)\"")
    }
    
    func runTestsOn(codecString: String) -> HLSCodecArray {
        let codecs1 = HLSCodecArray(string: codecString)
        
        XCTAssertNotNil(codecs1, "Should have been created")
        XCTAssert(codecs1?.codecs.count == 2, "Should have two codecs")
        XCTAssert(codecs1?.codecs[0].codecDescriptor == "avc1.4d401f", "Should match first codec")
        XCTAssert(codecs1?.codecs[1].codecDescriptor == "mp4a.40.5", "Should match second codec")
        
        XCTAssertTrue(codecs1?.containsAudio() ?? false, "Should contain audio")
        XCTAssertTrue(codecs1?.containsVideo() ?? false, "Should contain video")
        XCTAssertFalse(codecs1?.containsAudioOnly() ?? false, "Should not contain only audio")
        
        return codecs1!
    }

    
}
