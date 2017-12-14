//
//  HLSParser_Super8MuxedTests.swift
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

class HLSParser_Super8MuxedTests: XCTestCase {
    
    func testHLS_Super8_1() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "Super8_muxed1_4242.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let manifest = parseManifest(inString: hlsString)
        
        XCTAssert(manifest.tags.count == 27, "Misparsed the HLS")
        
        for i in 0..<4 {
            XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.EXT_X_MEDIA, "Tag did not parse properly")
        }
        for i in 4..<20 {
            if i % 2 == 0 {
                XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
            }
            else {
                XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
            }
        }
        for i in 20..<27 {
            XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF, "Tag did not parse properly")
        }
        
        // do some spot tests of the data
        XCTAssert(manifest.tags[3].value(forValueIdentifier: PantosValue.groupId) == "g147200", "Tag did not parse properly")
        XCTAssert(manifest.tags[14].value(forValueIdentifier: PantosValue.resolution) == "1280x720", "Tag did not parse properly")
        let test: String? = nil
        XCTAssert(manifest.tags[18].value(forValueIdentifier: PantosValue.resolution) == test, "Tag did not parse properly")
        XCTAssert(manifest.tags[24].value(forValueIdentifier: PantosValue.uri) == "IP_720p60_51_SAP_TS/4242/format-hls-track-iframe-bandwidth-1746000-repid-1746000.m3u8", "Tag did not parse properly")
        
        let validationIssues =  HLSMasterManifestValidator.validate(hlsManifest: manifest)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_Super8_2() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "Super8_muxed2_1376214110461.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let manifest = parseManifest(inString: hlsString)
        
        XCTAssert(manifest.tags.count == 26, "Misparsed the HLS")
        
        for i in 0..<18 {
            if i % 2 == 0 {
                XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
            }
            else {
                XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
            }
        }
        for i in 18..<26 {
            XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF, "Tag did not parse properly")
        }
        
        // do some spot tests of the data
        XCTAssert(manifest.tags[0].value(forValueIdentifier: PantosValue.codecs) == "avc1.4d401f,mp4a.40.5", "Tag did not parse properly")
        XCTAssert(manifest.tags[8].value(forValueIdentifier: PantosValue.resolution) == "768x432", "Tag did not parse properly")
        XCTAssert(manifest.tags[20].value(forValueIdentifier: PantosValue.uri) == "c2/1376214110461/1376214110461/format-hls-track-iframe-bandwidth-551794-repid-551794.m3u8", "Tag did not parse properly")
        XCTAssert(manifest.tags[25].value(forValueIdentifier: PantosValue.bandwidthBPS) == "4300000", "Tag did not parse properly")
        
        let validationIssues = HLSMasterManifestValidator.validate(hlsManifest: manifest)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_Super8_3() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "Super8_muxed3_HD_VOD_VDS_TELENOVELA_02152016_LVLH08.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let manifest = parseManifest(inString: hlsString)
        
        XCTAssert(manifest.tags.count == 32, "Misparsed the HLS")
        
        // this file has the "#EXT-X-FAXS-CM", an adobe tag that will not be supported in mamba
        // do some tests around unknown tag formatting
        XCTAssert(manifest.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        XCTAssert(manifest.tags[0].tagName! == "#EXT-X-FAXS-CM", "Tag did not parse correctly")
        XCTAssert(manifest.tags[0].tagData == "MIIV4QYJKoZIhvcNAQcCoIIV0jCCFc4CAQExCzAJBgUrDgMCGgUAMIIKVAYJKoZIhvcNAQcBoIIKRQSCCkEwggo9AgECMIIDjTCCA4kCAQMCAQEELXR2aXYtYTcyNTlmNDQ3MTYzNGJjNWM4MzAwNWZhZGZhMjhmMDg0ZmYxMjc4NzFoMCMMIWNvbS5hZG9iZS5mbGFzaGFjY2Vzcy5yaWdodHMucGxheTBBDCljb20uYWRvYmUuZmxhc2hhY2Nlc3MucmlnaHRzLmxpY2Vuc2VVc2FnZaAUMRIwEAYJKoZIhvcvAwYOoAMBAf+gDQwLNS4zLjEuMjU0ODihCgwIQ09MVU1CVVOjMjEwMC4MKmNvbS5hZG9iZS5mbGFzaGFjY2Vzcy5hdHRyaWJ1dGVzLmFub255bW91czEApYICkjGCAo4wFgwMY29udGVudDp0eXBlMQYEBHR2aXYwGAwKY2ttOnBvbGljeTEKBAhDT0xVTUJVUzAkDBNja206Y2xpZW50U2hvcnROYW1lMQ0EC1AwMjAwMDAwNDE3MCgMDmNrbTpkcm1Qcm9maWxlMRYEFGZsYXNoQWNjZXNzLUNPTFVNQlVTMDMMCWRybTprZXlJZDEmBCQ1YTkyYjBmMy05NDI0LTM3YWItNmI4ZS1mOTkwNGE1MGNmYTUwQAwKY29udGVudDppZDEyBDBuYmMuY29tTkJDVTIwMTYwMjEzMDAwMDE4NDctTkJDVTIwMTYwMjEzMDAwMDE4NDkwQAwQY2ttOmNsaWVudFNlcmlhbDEsBCowMEYwNDM0NEQ1MDYzRDI2MDZGMDU2NDhGRUMzNUMxRUY4RTY5REMyQkQwRAwObWVkaWFDb250ZW50SWQxMgQwbmJjLmNvbU5CQ1UyMDE2MDIxMzAwMDAxODQ3LU5CQ1UyMDE2MDIxMzAwMDAxODQ5MH4MEmNrbTpjbGllbnRJc3N1ZXJEbjFoBGZDTj1QMDIwMDEsIE9VPXVybjpjb21jYXN0OmNjcDpwa2ktY3MtdGQsIE89Q29tY2FzdCBDb252ZXJnZWQgUHJvZHVjdHMgTExDLCBMPVBoaWxhZGVscGhpYSwgU1Q9UEEsIEM9VVMwgYoME2NrbTpjbGllbnRTdWJqZWN0RG4xcwRxQ049UDAyMDAwMDA0MTcsIE9VPXVybjpjb21jYXN0OmNjcDpw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", "Tag did not parse properly")
        
        for i in 1..<5 {
            XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.EXT_X_MEDIA, "Tag did not parse properly")
        }
        for i in 5..<23 {
            if i % 2 == 1 {
                XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
            }
            else {
                XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
            }
        }
        for i in 23..<32 {
            XCTAssert(manifest.tags[i].tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF, "Tag did not parse properly")
        }
        
        // do some spot tests of the data
        XCTAssert(manifest.tags[1].value(forValueIdentifier: PantosValue.type) == "AUDIO", "Tag did not parse properly")
        XCTAssert(manifest.tags[6].tagData == "omg15/482/409/HD_VOD_VDS_TELENOVELA_02152016_LVLH08/format-hls-track-muxed-bandwidth-519178-repid-519178.m3u8", "Tag did not parse properly")
        XCTAssert(manifest.tags[21].value(forValueIdentifier: PantosValue.audioGroup) == "g92797", "Tag did not parse properly")
        XCTAssert(manifest.tags[25].value(forValueIdentifier: PantosValue.resolution) == "512x288", "Tag did not parse properly")
        
        let validationIssues = HLSMasterManifestValidator.validate(hlsManifest: manifest)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
}
