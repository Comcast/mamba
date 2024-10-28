//
//  InterstitialTagBuilderTests.swift
//  mambaTests
//
//  Created by Migneco, Ray on 10/23/24.
//  Copyright © 2024 Comcast Corporation.
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


final class InterstitialTagBuilderTests: XCTestCase {
    
    func testTagBuilder() {
        
        let startDate = Date()
        let id: String = "12345"
        let assetUri: String = "http://not.a.real.uri"
        let assetListUri: String = "http://not.a.real.list"
        
        let validator = EXT_X_DATERANGETagValidator()
        
        // test URI
        var tagBuilder = InterstitialTagBuilder(id: id,
                                                startDate: startDate,
                                                assetUri: assetUri)
        
        var tag = decorateAndTest(tagBuilder)
        
        XCTAssertEqual(tag.value(forValueIdentifier: PantosValue.startDate), String.DateFormatter.iso8601MS.string(from: startDate))
        XCTAssertEqual(tag.value<String>(forValueIdentifier: PantosValue.id), id)
        XCTAssertEqual(tag.value<String>(forValueIdentifier: PantosValue.assetUri), assetUri)
        XCTAssertNil(tag.value<String>(forValueIdentifier: PantosValue.assetList))
        
        XCTAssertNil(validator.validate(tag: tag))
        
        // test asset list
        tagBuilder = InterstitialTagBuilder(id: id,
                                            startDate: startDate,
                                            assetList: assetListUri)
        
        tag = decorateAndTest(tagBuilder)
        
        XCTAssertEqual(tag.value<String>(forValueIdentifier: PantosValue.assetList), assetListUri)
        XCTAssertNil(tag.value<String>(forValueIdentifier: PantosValue.assetUri))
        
        XCTAssertNil(validator.validate(tag: tag))
    }
    
    func decorateAndTest(_ tagBuilder: InterstitialTagBuilder) -> HLSTag {
        
        let duration: Double = 10.0
        let alignment = HLSInterstitialAlignment(values: [.in, .out])
        let restrictions = HLSInterstitialSeekRestrictions(restrictions: [.skip, .jump])
        let playoutLimit: Double = 30.0
        let resumeOffset: Double = 5.0
        let timelineStyle = HLSInterstitialTimelineStyle.highlight
        let timelineOccupation = HLSInterstitialTimelineOccupation.point
        let contentVariation = false
        let clientAttributes: [String: LosslessStringConvertible] = ["X-COM-BEACON-URI": "http://not.a.real.beacon",
                                                                     "X-COM-AD-PROVIDER-ID": 100]
        
        let tag = tagBuilder
            .withDuration(duration)
            .withAlignment(alignment)
            .withRestrictions(restrictions)
            .withPlayoutLimit(playoutLimit)
            .withResumeOffset(resumeOffset)
            .withTimelineStyle(timelineStyle)
            .withTimelineOccupation(timelineOccupation)
            .withContentVariation(contentVariation)
            .withClientAttributes(clientAttributes)
            .buildTag()
        
        XCTAssertEqual(tag.value<Double>(forValueIdentifier: PantosValue.duration), duration)
        XCTAssertEqual(tag.value<HLSInterstitialAlignment>(forValueIdentifier: PantosValue.snap), alignment)
        XCTAssertEqual(tag.value<HLSInterstitialSeekRestrictions>(forValueIdentifier: PantosValue.restrict), restrictions)
        XCTAssertEqual(tag.value<Double>(forValueIdentifier: PantosValue.playoutLimit), playoutLimit)
        XCTAssertEqual(tag.value<Double>(forValueIdentifier: PantosValue.resumeOffset), resumeOffset)
        XCTAssertEqual(tag.value<HLSInterstitialTimelineStyle>(forValueIdentifier: PantosValue.timelineStyle), timelineStyle)
        XCTAssertEqual(tag.value<HLSInterstitialTimelineOccupation>(forValueIdentifier: PantosValue.timelineOccupies), timelineOccupation)
        XCTAssertEqual(tag.value<Bool>(forValueIdentifier: PantosValue.contentMayVary), contentVariation)
        
        // check client attributes
        for (k, v) in clientAttributes {
            guard let val = tag.value(forKey: k) else {
                XCTFail("Expected to find value for key \(k)")
                continue
            }
            
            XCTAssertEqual(val, v.description)
        }
        
        return tag
    }

}
