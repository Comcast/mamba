//
//  HLSTagTests.swift
//  mamba
//
//  Created by David Coufal on 1/9/17.
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

class HLSTagTests: XCTestCase {
    
    let testNonQuoteEscapedKey = "NON_QUOTE_ESCAPED_TEST_KEY"
    let testQuoteEscapedKey = "QUOTE_ESCAPED_TEST_KEY"
    
    let testValue = "TEST"
    
    let newValueBandwidth = "20000"
    let newValueCodec = "test20.a"
    let newValueTest = "CHANGED_TEST"
    
    func createTag() -> HLSTag {
        
        var tagData = "\(PantosValue.bandwidthBPS.toString())=10000" // a known tag with a non quote escaped value
        tagData += ","
        tagData += "\(PantosValue.codecs.toString())=\"avc01.4a\"" // a known tag with a quote escaped value
        tagData += ","
        tagData += "\(testNonQuoteEscapedKey)=\(testValue)" // a unknown tag with a non quote escaped value
        tagData += ","
        tagData += "\(testQuoteEscapedKey)=\"\(testValue)\"" // a unknown tag with a quote escaped value
        
        let regTags = RegisteredHLSTags()
        let tagParser = regTags.parser(forTag: PantosTag.EXT_X_STREAM_INF)
        
        let parsedValues = try! tagParser.parseTag(fromTagString: tagData)
        
        let tag = HLSTag(tagDescriptor: PantosTag.EXT_X_STREAM_INF,
                         tagData: HLSStringRef(string: tagData),
                         tagName: HLSStringRef(descriptor: PantosTag.EXT_X_STREAM_INF),
                         parsedValues: parsedValues)
        
        return tag
    }
    
    func testQuoteEscapingBehaviors_ChangedValueShouldInherit() {
        
        var tag = createTag()
        
        tag.set(value: newValueBandwidth, forValueIdentifier: PantosValue.bandwidthBPS)
        tag.set(value: newValueCodec, forValueIdentifier: PantosValue.codecs)
        tag.set(value: newValueTest, forKey: testNonQuoteEscapedKey)
        tag.set(value: newValueTest, forKey: testQuoteEscapedKey)
        
        let val1 = tag.valueData(forValueIdentifier: PantosValue.bandwidthBPS)
        let val2 = tag.valueData(forValueIdentifier: PantosValue.codecs)
        let val3 = tag.valueData(forKey: testNonQuoteEscapedKey)
        let val4 = tag.valueData(forKey: testQuoteEscapedKey)
        
        XCTAssert(val1?.quoteEscaped == false, "Did not preserve quote escape from parent")
        XCTAssert(val2?.quoteEscaped == true, "Did not preserve quote escape from parent")
        XCTAssert(val3?.quoteEscaped == false, "Did not preserve quote escape from parent")
        XCTAssert(val4?.quoteEscaped == true, "Did not preserve quote escape from parent")
    }
    
    func testQuoteEscapingBehaviors_ForcedQuoteEscapeShouldTakePriority() {
        
        var tag = createTag()
        
        tag.set(value: newValueBandwidth, forValueIdentifier: PantosValue.bandwidthBPS, shouldBeQuoteEscaped: true)
        tag.set(value: newValueCodec, forValueIdentifier: PantosValue.codecs, shouldBeQuoteEscaped: false)
        tag.set(value: newValueTest, forKey: testNonQuoteEscapedKey, shouldBeQuoteEscaped: true)
        tag.set(value: newValueTest, forKey: testQuoteEscapedKey, shouldBeQuoteEscaped: false)
        
        let val1 = tag.valueData(forValueIdentifier: PantosValue.bandwidthBPS)
        let val2 = tag.valueData(forValueIdentifier: PantosValue.codecs)
        let val3 = tag.valueData(forKey: testNonQuoteEscapedKey)
        let val4 = tag.valueData(forKey: testQuoteEscapedKey)
        
        XCTAssert(val1?.quoteEscaped == true, "Did not preserve quote escape from parent")
        XCTAssert(val2?.quoteEscaped == false, "Did not preserve quote escape from parent")
        XCTAssert(val3?.quoteEscaped == true, "Did not preserve quote escape from parent")
        XCTAssert(val4?.quoteEscaped == false, "Did not preserve quote escape from parent")
    }
    
    func testQuoteEscapingBehaviors_NewKeyValuesShouldTakeForcedValueOrDefaultToFalse() {
        
        var tag = HLSTag(tagDescriptor: PantosTag.EXT_X_STREAM_INF,
                         tagData: HLSStringRef(),
                         tagName: HLSStringRef(descriptor: PantosTag.EXT_X_STREAM_INF),
                         parsedValues:[:])
        
        tag.set(value: "YES", forValueIdentifier: PantosValue.autoselect) // should get set to shouldBeQuoteEscaped = false
        tag.set(value: "VOD", forValueIdentifier: PantosValue.playlistType, shouldBeQuoteEscaped: false)
        tag.set(value: "en-US", forValueIdentifier: PantosValue.language, shouldBeQuoteEscaped: true)
        tag.set(value: newValueTest, forKey: "DEFAULT_QUOTING_TEST_KEY") // should get set to shouldBeQuoteEscaped = false
        tag.set(value: newValueTest, forKey: testNonQuoteEscapedKey, shouldBeQuoteEscaped: false)
        tag.set(value: newValueTest, forKey: testQuoteEscapedKey, shouldBeQuoteEscaped: true)
        
        let val1 = tag.valueData(forValueIdentifier: PantosValue.autoselect)
        let val2 = tag.valueData(forValueIdentifier: PantosValue.playlistType)
        let val3 = tag.valueData(forValueIdentifier: PantosValue.language)
        let val4 = tag.valueData(forKey: "DEFAULT_QUOTING_TEST_KEY")
        let val5 = tag.valueData(forKey: testNonQuoteEscapedKey)
        let val6 = tag.valueData(forKey: testQuoteEscapedKey)
        
        XCTAssert(val1?.quoteEscaped == false, "Did not preserve quote escape from parent")
        XCTAssert(val2?.quoteEscaped == false, "Did not preserve quote escape from parent")
        XCTAssert(val3?.quoteEscaped == true, "Did not preserve quote escape from parent")
        XCTAssert(val4?.quoteEscaped == false, "Did not preserve quote escape from parent")
        XCTAssert(val5?.quoteEscaped == false, "Did not preserve quote escape from parent")
        XCTAssert(val6?.quoteEscaped == true, "Did not preserve quote escape from parent")
    }
    
    func testTagEqualityAndHash() {
        
        let tag1 = createTag()
        let tag2 = createTag()
        
        let tag3 = HLSTag(tagDescriptor: PantosTag.EXT_X_STREAM_INF,
                          tagData: HLSStringRef(),
                          tagName: HLSStringRef(descriptor: PantosTag.EXT_X_STREAM_INF))
        
        XCTAssert(tag1 == tag2, "Expecting tag equality")
        XCTAssert(tag2 == tag1, "Expecting tag equality")
        XCTAssert(tag1.hashValue == tag2.hashValue, "Expecting tag hash equality")
        
        XCTAssert(tag1 != tag3, "Expecting tag inequality")
        XCTAssert(tag3 != tag1, "Expecting tag inequality")
        XCTAssert(tag1.hashValue != tag3.hashValue, "Expecting tag hash inequality")
    }
    
    func testTagConvenienceExtensions() {
        
        let testManifestString = """
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=1000000,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=1280x720
dummy1.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1000000,CODECS="mp4a.40.5"
dummy3.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1000000,CODECS="avc1.4d401f",RESOLUTION=1280x720
dummy5.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1000000,CODECS="avc1.4d401f,mp4a.40.5"
dummy7.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1893200,CODECS="avc1.4d401f"
dummy9.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=3019200,RESOLUTION=1280x720
dummy11.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=3922800
dummy13.m3u8
"""
        let manifest = parseManifest(inString: testManifestString)
        
        let tag_audiocodec_videocodec_resolution = manifest.tags[0]
        let tag_audiocodec = manifest.tags[2]
        let tag_videocodec_resolution = manifest.tags[4]
        let tag_audiocodec_videocodec = manifest.tags[6]
        let tag_videocodec = manifest.tags[8]
        let tag_resolution = manifest.tags[10]
        let tag_nostreamdata = manifest.tags[12]
        
        XCTAssert(tag_audiocodec_videocodec_resolution.codecs() != nil)
        XCTAssert(tag_audiocodec_videocodec_resolution.bandwidth() != nil)
        XCTAssert(tag_audiocodec_videocodec_resolution.resolution() != nil)
        XCTAssert(tag_audiocodec_videocodec_resolution.isAudioOnlyStream() == .FALSE)
        XCTAssert(tag_audiocodec_videocodec_resolution.isVideoStream() == .TRUE)
        XCTAssert(tag_audiocodec_videocodec_resolution.isAudioVideoStream() == .TRUE)

        XCTAssert(tag_audiocodec.codecs() != nil)
        XCTAssert(tag_audiocodec.bandwidth() != nil)
        XCTAssert(tag_audiocodec.resolution() == nil)
        XCTAssert(tag_audiocodec.isAudioOnlyStream() == .TRUE)
        XCTAssert(tag_audiocodec.isVideoStream() == .FALSE)
        XCTAssert(tag_audiocodec.isAudioVideoStream() == .FALSE)

        XCTAssert(tag_videocodec_resolution.codecs() != nil)
        XCTAssert(tag_videocodec_resolution.bandwidth() != nil)
        XCTAssert(tag_videocodec_resolution.resolution() != nil)
        XCTAssert(tag_videocodec_resolution.isAudioOnlyStream() == .FALSE)
        XCTAssert(tag_videocodec_resolution.isVideoStream() == .TRUE)
        XCTAssert(tag_videocodec_resolution.isAudioVideoStream() == .FALSE)

        XCTAssert(tag_audiocodec_videocodec.codecs() != nil)
        XCTAssert(tag_audiocodec_videocodec.bandwidth() != nil)
        XCTAssert(tag_audiocodec_videocodec.resolution() == nil)
        XCTAssert(tag_audiocodec_videocodec.isAudioOnlyStream() == .FALSE)
        XCTAssert(tag_audiocodec_videocodec.isVideoStream() == .TRUE)
        XCTAssert(tag_audiocodec_videocodec.isAudioVideoStream() == .TRUE)

        XCTAssert(tag_videocodec.codecs() != nil)
        XCTAssert(tag_videocodec.bandwidth() != nil)
        XCTAssert(tag_videocodec.resolution() == nil)
        XCTAssert(tag_videocodec.isAudioOnlyStream() == .FALSE)
        XCTAssert(tag_videocodec.isVideoStream() == .TRUE)
        XCTAssert(tag_videocodec.isAudioVideoStream() == .FALSE)

        XCTAssert(tag_resolution.codecs() == nil)
        XCTAssert(tag_resolution.bandwidth() != nil)
        XCTAssert(tag_resolution.resolution() != nil)
        XCTAssert(tag_resolution.isAudioOnlyStream() == .FALSE)
        XCTAssert(tag_resolution.isVideoStream() == .TRUE)
        XCTAssert(tag_resolution.isAudioVideoStream() == .INDETERMINATE)

        XCTAssert(tag_nostreamdata.codecs() == nil)
        XCTAssert(tag_nostreamdata.bandwidth() != nil)
        XCTAssert(tag_nostreamdata.resolution() == nil)
        XCTAssert(tag_nostreamdata.isAudioOnlyStream() == .INDETERMINATE)
        XCTAssert(tag_nostreamdata.isVideoStream() == .INDETERMINATE)
        XCTAssert(tag_nostreamdata.isAudioVideoStream() == .INDETERMINATE)
        
        let tag_location = manifest.tags[1] // non #EXT-X-STREAM-INF tag
        
        XCTAssert(tag_location.codecs() == nil)
        XCTAssert(tag_location.bandwidth() == nil)
        XCTAssert(tag_location.resolution() == nil)
        XCTAssert(tag_location.isAudioOnlyStream() == .FALSE)
        XCTAssert(tag_location.isVideoStream() == .FALSE)
        XCTAssert(tag_location.isAudioVideoStream() == .FALSE)
    }
}
