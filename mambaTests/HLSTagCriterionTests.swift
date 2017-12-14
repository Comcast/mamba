//
//  HLSTagCriterionTests.swift
//  mamba
//
//  Created by David Coufal on 12/12/17.
//  Copyright © 2017 Comcast Corporation.
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

import mamba

class HLSTagCriterionTests: XCTestCase {
    
    func test_HLSStringMatchTagCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")
        
        let crit = HLSStringMatchTagCriteron(valueIdentifer: PantosValue.codecs, value: "avc1.4d401f,mp4a.40.5")
        
        XCTAssertTrue(crit.evaluate(tag: manifest.tags[2]), "Expecting a match")
        XCTAssertFalse(crit.evaluate(tag: manifest.tags[1]), "Not expecting a match")
    }
    
    func test_HLSAllTagCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")

        let crit = HLSAllTagCriteron(tagDescriptor: PantosTag.EXT_X_STREAM_INF)

        XCTAssertTrue(crit.evaluate(tag: manifest.tags[2]), "Expecting a match")
        XCTAssertFalse(crit.evaluate(tag: manifest.tags[1]), "Not expecting a match")
    }
    
    func test_HLSHasValueCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")

        let crit = HLSHasValueCriteron(valueIdentifer: PantosValue.bandwidthBPS)

        XCTAssertTrue(crit.evaluate(tag: manifest.tags[2]), "Expecting a match")
        XCTAssertFalse(crit.evaluate(tag: manifest.tags[1]), "Not expecting a match")
    }
    
    func test_HLSHasNoValueCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")

        let crit = HLSHasNoValueCriteron(valueIdentifer: PantosValue.bandwidthBPS)

        XCTAssertFalse(crit.evaluate(tag: manifest.tags[2]), "Expecting a match")
        XCTAssertTrue(crit.evaluate(tag: manifest.tags[1]), "Not expecting a match")
    }
    
    func test_HLSStringMatchTagNameCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")

        let crit = HLSStringMatchTagNameCriteron(tagName: "#EXT-X-STREAM-INF")

        XCTAssertTrue(crit.evaluate(tag: manifest.tags[2]), "Expecting a match")
        XCTAssertFalse(crit.evaluate(tag: manifest.tags[1]), "Not expecting a match")
        XCTAssertFalse(crit.evaluate(tag: manifest.tags[3]), "Not expecting a match")
    }
    
    func test_HLSContainsStringTagCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")

        let crit = HLSContainsStringTagCriteron(valueIdentifer: PantosValue.codecs, containsValue: "avc1.4d401f")

        XCTAssertTrue(crit.evaluate(tag: manifest.tags[2]), "Expecting a match")
        XCTAssertFalse(crit.evaluate(tag: manifest.tags[12]), "Not expecting a match")
        
        let critDoesNotContainValue = HLSContainsStringTagCriteron(valueIdentifer: PantosValue.discontinuitySequence, containsValue: "empty_string")
        
        XCTAssertFalse(critDoesNotContainValue.evaluate(tag: manifest.tags[2]), "Not expecting a match")
    }
    
    func test_HLSDoesNotContainStringTagCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")
        
        let crit = HLSDoesNotContainStringTagCriteron(valueIdentifer: PantosValue.codecs, containsValue: "avc1.4d401f")
        
        XCTAssertTrue(crit.evaluate(tag: manifest.tags[12]), "Expecting a match")
        XCTAssertFalse(crit.evaluate(tag: manifest.tags[2]), "Not expecting a match")
        
        let critDoesNotContainValue = HLSDoesNotContainStringTagCriteron(valueIdentifer: PantosValue.discontinuitySequence, containsValue: "empty_string")
        
        XCTAssertFalse(critDoesNotContainValue.evaluate(tag: manifest.tags[2]), "Not expecting a match")
    }
    
    func test_HLSIntTagCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")

        let crit_equals = HLSIntTagCriteron(valueIdentifer: PantosValue.bandwidthBPS, value: 1397600, comparison: .equals)
        let crit_lessThan = HLSIntTagCriteron(valueIdentifer: PantosValue.bandwidthBPS, value: 1397600, comparison: .lessThan)
        let crit_lessThanOrEquals = HLSIntTagCriteron(valueIdentifer: PantosValue.bandwidthBPS, value: 1397600, comparison: .lessThanOrEquals)
        let crit_greaterThan = HLSIntTagCriteron(valueIdentifer: PantosValue.bandwidthBPS, value: 1397600, comparison: .greaterThan)
        let crit_greaterThanOrEquals = HLSIntTagCriteron(valueIdentifer: PantosValue.bandwidthBPS, value: 1397600, comparison: .greaterThanOrEquals)
        
        let tag_bw_488000 = manifest.tags[2]
        let tag_bw_1397600 = manifest.tags[8]
        let tag_bw_3358400 = manifest.tags[12]
        
        XCTAssertFalse(crit_equals.evaluate(tag: tag_bw_488000), "Not Expecting a match")
        XCTAssertTrue(crit_equals.evaluate(tag: tag_bw_1397600), "Expecting a match")
        XCTAssertFalse(crit_equals.evaluate(tag: tag_bw_3358400), "Not Expecting a match")
        XCTAssertTrue(crit_lessThan.evaluate(tag: tag_bw_488000), "Expecting a match")
        XCTAssertFalse(crit_lessThan.evaluate(tag: tag_bw_1397600), "Not Expecting a match")
        XCTAssertFalse(crit_lessThan.evaluate(tag: tag_bw_3358400), "Not Expecting a match")
        XCTAssertTrue(crit_lessThanOrEquals.evaluate(tag: tag_bw_488000), "Expecting a match")
        XCTAssertTrue(crit_lessThanOrEquals.evaluate(tag: tag_bw_1397600), "Expecting a match")
        XCTAssertFalse(crit_lessThanOrEquals.evaluate(tag: tag_bw_3358400), "Not Expecting a match")
        XCTAssertFalse(crit_greaterThan.evaluate(tag: tag_bw_488000), "Not Expecting a match")
        XCTAssertFalse(crit_greaterThan.evaluate(tag: tag_bw_1397600), "Not Expecting a match")
        XCTAssertTrue(crit_greaterThan.evaluate(tag: tag_bw_3358400), "Expecting a match")
        XCTAssertFalse(crit_greaterThanOrEquals.evaluate(tag: tag_bw_488000), "Not Expecting a match")
        XCTAssertTrue(crit_greaterThanOrEquals.evaluate(tag: tag_bw_1397600), "Expecting a match")
        XCTAssertTrue(crit_greaterThanOrEquals.evaluate(tag: tag_bw_3358400), "Expecting a match")
        
        XCTAssertFalse(crit_equals.evaluate(tag: manifest.tags[1]), "Not Expecting a match")

    }
    
    func test_HLSResolutionTagCriteron() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")
        
        let crit_equals = HLSResolutionTagCriteron(valueIdentifer: PantosValue.resolution, value: HLSResolution(width: 640, height: 360), comparison: .equals)
        let crit_lessThan = HLSResolutionTagCriteron(valueIdentifer: PantosValue.resolution, value: HLSResolution(width: 640, height: 360), comparison: .lessThan)
        let crit_lessThanOrEquals = HLSResolutionTagCriteron(valueIdentifer: PantosValue.resolution, value: HLSResolution(width: 640, height: 360), comparison: .lessThanOrEquals)
        let crit_greaterThan = HLSResolutionTagCriteron(valueIdentifer: PantosValue.resolution, value: HLSResolution(width: 640, height: 360), comparison: .greaterThan)
        let crit_greaterThanOrEquals = HLSResolutionTagCriteron(valueIdentifer: PantosValue.resolution, value: HLSResolution(width: 640, height: 360), comparison: .greaterThanOrEquals)
        
        let tag_res_320x180 = manifest.tags[2]
        let tag_res_640x360 = manifest.tags[8]
        let tag_res_1280x720 = manifest.tags[12]
        
        XCTAssertFalse(crit_equals.evaluate(tag: tag_res_320x180), "Not Expecting a match")
        XCTAssertTrue(crit_equals.evaluate(tag: tag_res_640x360), "Expecting a match")
        XCTAssertFalse(crit_equals.evaluate(tag: tag_res_1280x720), "Not Expecting a match")
        XCTAssertTrue(crit_lessThan.evaluate(tag: tag_res_320x180), "Expecting a match")
        XCTAssertFalse(crit_lessThan.evaluate(tag: tag_res_640x360), "Not Expecting a match")
        XCTAssertFalse(crit_lessThan.evaluate(tag: tag_res_1280x720), "Not Expecting a match")
        XCTAssertTrue(crit_lessThanOrEquals.evaluate(tag: tag_res_320x180), "Expecting a match")
        XCTAssertTrue(crit_lessThanOrEquals.evaluate(tag: tag_res_640x360), "Expecting a match")
        XCTAssertFalse(crit_lessThanOrEquals.evaluate(tag: tag_res_1280x720), "Not Expecting a match")
        XCTAssertFalse(crit_greaterThan.evaluate(tag: tag_res_320x180), "Not Expecting a match")
        XCTAssertFalse(crit_greaterThan.evaluate(tag: tag_res_640x360), "Not Expecting a match")
        XCTAssertTrue(crit_greaterThan.evaluate(tag: tag_res_1280x720), "Expecting a match")
        XCTAssertFalse(crit_greaterThanOrEquals.evaluate(tag: tag_res_320x180), "Not Expecting a match")
        XCTAssertTrue(crit_greaterThanOrEquals.evaluate(tag: tag_res_640x360), "Expecting a match")
        XCTAssertTrue(crit_greaterThanOrEquals.evaluate(tag: tag_res_1280x720), "Expecting a match")
    }
    
    func test_HLSTagCriteria() {
        let manifest = parseManifest(inFixtureName: "hls_ad_master_manifest.m3u8")

        let crit_bandwidth_is_1397600 = HLSIntTagCriteron(valueIdentifer: PantosValue.bandwidthBPS, value: 1397600, comparison: .equals)
        let crit_codecs_contains_avc1_4d401f = HLSContainsStringTagCriteron(valueIdentifer: PantosValue.codecs, containsValue: "avc1.4d401f")
        
        let crit_res_is_640x360 = HLSResolutionTagCriteron(valueIdentifer: PantosValue.resolution, value: HLSResolution(width: 640, height: 360), comparison: .equals)

        // this criteria is for BW == 1397600 AND codecs includes  "avc1.4d401f"
        let crit_bw_1397600_AND_codecs_4d401f = HLSTagCriteria(criteria: [crit_bandwidth_is_1397600, crit_codecs_contains_avc1_4d401f])

        // this criteria is for ((BW == 1397600 AND codecs includes  "avc1.4d401f") OR resolution is 640x360)
        let crit = HLSTagCriteria(criteria: [crit_bw_1397600_AND_codecs_4d401f, crit_res_is_640x360], matchType: .matchAtLeastOne)
        
        XCTAssertTrue(crit.evaluate(tag: manifest.tags[8]), "Expecting a match")
        XCTAssertFalse(crit.evaluate(tag: manifest.tags[2]), "Expecting a match")
    }
}
