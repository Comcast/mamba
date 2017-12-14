//
//  ThirdPartyTagListSupportTests.swift
//  mamba
//
//  Created by David Coufal on 7/11/16.
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

class ThirdPartyTagListSupportTests: XCTestCase {
    
    func testThirdPartyTagList() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "ThirdPartyHLSTagsTestFixture.txt")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let manifest = parseManifest(inString: hlsString, tagTypes:[HLSTagString_ThirdParty1.self, HLSTagString_ThirdParty2.self])
        
        XCTAssert(manifest.tags.count == 7, "Misparsed the HLS")
        
        XCTAssert(manifest.tags[0].tagDescriptor == PantosTag.EXT_X_TARGETDURATION, "Tag did not parse properly")
        XCTAssert(manifest.tags[0].value(forValueIdentifier: PantosValue.targetDurationSeconds) == "10", "Tag did not parse properly")
        
        XCTAssert(manifest.tags[1].tagDescriptor == HLSTagString_ThirdParty1.EXT_THIRD_PARTY1_1, "Tag did not parse properly")
        XCTAssert(manifest.tags[1].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value1) == "TEST_A", "Tag did not parse properly")
        XCTAssert(manifest.tags[1].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value2) == "TEST_B", "Tag did not parse properly")
        
        XCTAssert(manifest.tags[2].tagDescriptor == HLSTagString_ThirdParty1.EXT_THIRD_PARTY1_1, "Tag did not parse properly")
        XCTAssert(manifest.tags[2].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value1) == "TEST_C", "Tag did not parse properly")
        
        XCTAssert(manifest.tags[3].tagDescriptor == HLSTagString_ThirdParty1.EXT_THIRD_PARTY1_2, "Tag did not parse properly")
        XCTAssert(manifest.tags[3].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value2) == "TEST_D", "Tag did not parse properly")
        XCTAssert(manifest.tags[3].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value3) == "TEST_E", "Tag did not parse properly")
        
        XCTAssert(manifest.tags[4].tagDescriptor == HLSTagString_ThirdParty2.EXT_THIRD_PARTY2_1, "Tag did not parse properly")
        XCTAssert(manifest.tags[4].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value1) == "TEST_F", "Tag did not parse properly")
        XCTAssert(manifest.tags[4].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value3) == "TEST_G", "Tag did not parse properly")
        
        XCTAssert(manifest.tags[5].tagDescriptor == HLSTagString_ThirdParty2.EXT_THIRD_PARTY2_1, "Tag did not parse properly")
        XCTAssert(manifest.tags[5].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value1) == "TEST_H", "Tag did not parse properly")
        XCTAssert(manifest.tags[5].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value2) == "TEST_I", "Tag did not parse properly")
        XCTAssert(manifest.tags[5].value(forValueIdentifier: HLSTagValueIdentifier_ThirdParty.Value3) == "TEST_J", "Tag did not parse properly")
        
        XCTAssert(manifest.tags[6].tagDescriptor == PantosTag.EXT_X_ENDLIST, "Tag did not parse properly")
    }
}

