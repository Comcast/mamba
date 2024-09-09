//
//  PantosTagTests.swift
//  mamba
//
//  Created by David Coufal on 2/8/17.
//  Copyright © 2017 Comcast Cable Communications Management, LLC
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

class PantosTagTests: XCTestCase {
    
    func testStringRefLookup() {
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_STREAM_INF)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_BYTERANGE)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_PROGRAM_DATE_TIME)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_DISCONTINUITY)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_DISCONTINUITY_SEQUENCE)
        
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_KEY)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXTM3U)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_I_FRAMES_ONLY)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_SESSION_DATA)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_SESSION_KEY)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_CONTENT_STEERING)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_MEDIA_SEQUENCE)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_ALLOW_CACHE)
        
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_VERSION)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_PLAYLIST_TYPE)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_MEDIA)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_I_FRAME_STREAM_INF)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_ENDLIST)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_BITRATE)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_DATERANGE)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_SKIP)

        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_INDEPENDENT_SEGMENTS)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_START)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_TARGETDURATION)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXT_X_MAP)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.EXTINF)
        
        runStringRefLookupTest(onPantosDescriptor: PantosTag.Location)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.Comment)
        runStringRefLookupTest(onPantosDescriptor: PantosTag.UnknownTag)
    }
    
    func runStringRefLookupTest(onPantosDescriptor descriptor: PantosTag) {
        switch (descriptor) {
            
        case .EXT_X_STREAM_INF:
            fallthrough
        case .EXT_X_BYTERANGE:
            fallthrough
        case .EXT_X_PROGRAM_DATE_TIME:
            fallthrough
        case .EXT_X_DISCONTINUITY:
            fallthrough
        case .EXT_X_DISCONTINUITY_SEQUENCE:
            fallthrough
        case .EXT_X_KEY:
            fallthrough
        case .EXTM3U:
            fallthrough
        case .EXT_X_I_FRAMES_ONLY:
            fallthrough
        case .EXT_X_SESSION_DATA:
            fallthrough
        case .EXT_X_SESSION_KEY:
            fallthrough
        case .EXT_X_CONTENT_STEERING:
            fallthrough
        case .EXT_X_MEDIA_SEQUENCE:
            fallthrough
        case .EXT_X_ALLOW_CACHE:
            fallthrough
        case .EXT_X_VERSION:
            fallthrough
        case .EXT_X_PLAYLIST_TYPE:
            fallthrough
        case .EXT_X_MEDIA:
            fallthrough
        case .EXT_X_I_FRAME_STREAM_INF:
            fallthrough
        case .EXT_X_ENDLIST:
            fallthrough
        case .EXT_X_INDEPENDENT_SEGMENTS:
            fallthrough
        case .EXT_X_START:
            fallthrough
        case .EXT_X_TARGETDURATION:
            fallthrough
        case .EXT_X_MAP:
            fallthrough
        case .EXT_X_BITRATE:
            fallthrough
        case .EXTINF:
            fallthrough
        case .EXT_X_DATERANGE:
            fallthrough
        case .EXT_X_SKIP:
            let stringRef = HLSStringRef(string: "#\(descriptor.toString())")
            guard let newDescriptor = PantosTag.constructDescriptor(fromStringRef: stringRef) else {
                XCTFail("PantosTag \(descriptor.toString()) is missing from stringRefLookup table.")
                return
            }
            XCTAssert(descriptor == newDescriptor, "PantosTag \(descriptor.toString()) is not hooked up properly from stringRefLookup table (found \(newDescriptor.toString()) instead).")
            return

        case .Location:
            fallthrough
        case .Comment:
            fallthrough
        case .UnknownTag:
            // do no test, these are not in the stringRefLookup table
            return
            
            // If you get a build failure on this line:
        } // <---- HERE
        // ... you must have added a new tag to the PantosTag enum...
        // Follow these steps to fix:
        // (1) If you have not already, add the new tag to the `tagList` in the `stringRefLookup` lazy calculated varible in PantosTag.
        // (2) Add the new tag to the tested tags in `PantosTagTests.testStringRefLookup` above.
        // (3) Add the new tag to the `PantosTagTests.testStringRefLookup.runStringRefLookupTest` above as well.
        // If you don't do these steps, this tag will not be recognized by the PantosTag, and will be treated like an unknown tag.
    }
    
    func testDISCONTINUITYSEQUENCEValidator() {
        guard let validator = PantosTag.validator(forTag: PantosTag.EXT_X_DISCONTINUITY_SEQUENCE) else {
            XCTFail("Could not find validator for PantosTag.EXT_X_DISCONTINUITY_SEQUENCE")
            return
        }
        let issues = validator.validate(tag: HLSTag(tagDescriptor: PantosTag.EXT_X_DISCONTINUITY_SEQUENCE,
                                                    stringTagData: "0",
                                                    parsedValues: [PantosValue.discontinuitySequence.toString(): HLSValueData(value: "0")]))
        XCTAssertNil(issues, "Expecting no issues from validator")
    }
}
