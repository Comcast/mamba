//
//  BasicParserTest.swift
//  mamba
//
//  Created by David Coufal on 3/13/19.
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

class BasicParserTest: XCTestCase {
    
    func testHLS_singleMediaFile() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "hls_singleMediaFile.txt")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let playlist = parseVariantPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 5, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.EXT_X_TARGETDURATION, "Tag did not parse properly")
        XCTAssert(playlist.tags[1].tagDescriptor.toString() == PantosTag.EXT_X_BITRATE.rawValue, "Tag did not parse properly")
        XCTAssert(playlist.tags[2].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[4].tagDescriptor == PantosTag.EXT_X_ENDLIST, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(PantosTag.EXT_X_TARGETDURATION.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[1].tagName! == "#\(PantosTag.EXT_X_BITRATE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[2].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagName == nil, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[4].tagName! == "#\(PantosTag.EXT_X_ENDLIST.toString())", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].value(forValueIdentifier: PantosValue.targetDurationSeconds) == 5220, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[2].duration.seconds == 5220.0, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[3].tagData == "http://media.example.com/entire.ts", "Tag did not parse properly")
        
        let testNilValue: String? = playlist.tags[3].value(forValueIdentifier: PantosValue.targetDurationSeconds)
        XCTAssert(testNilValue == nil, "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(variantPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_bipbopallMasterPlaylist() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "bipbopall.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let playlist = parseMasterPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 8, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
        XCTAssert(playlist.tags[1].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[2].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[4].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
        XCTAssert(playlist.tags[5].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[6].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
        XCTAssert(playlist.tags[7].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(PantosTag.EXT_X_STREAM_INF.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[1].tagName == nil, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[2].tagName! == "#\(PantosTag.EXT_X_STREAM_INF.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagName == nil, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[4].tagName! == "#\(PantosTag.EXT_X_STREAM_INF.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[5].tagName == nil, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[6].tagName! == "#\(PantosTag.EXT_X_STREAM_INF.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[7].tagName == nil, "Tag did not parse properly") // locations do not have tag names
        
        XCTAssert(playlist.tags[0].value(forValueIdentifier: PantosValue.bandwidthBPS) == 200000, "Tag did not parse properly")
        XCTAssert(playlist.tags[0].value(forValueIdentifier: PantosValue.programId) == 1, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[2].value(forValueIdentifier: PantosValue.bandwidthBPS) == 311111, "Tag did not parse properly")
        XCTAssert(playlist.tags[2].value(forValueIdentifier: PantosValue.programId) == 1, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[4].value(forValueIdentifier: PantosValue.bandwidthBPS) == 484444, "Tag did not parse properly")
        XCTAssert(playlist.tags[4].value(forValueIdentifier: PantosValue.programId) == 1, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[6].value(forValueIdentifier: PantosValue.bandwidthBPS) == 737777, "Tag did not parse properly")
        XCTAssert(playlist.tags[6].value(forValueIdentifier: PantosValue.programId) == 1, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[1].tagData == "gear1/prog_index.m3u8", "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagData == "gear2/prog_index.m3u8", "Tag did not parse properly")
        XCTAssert(playlist.tags[5].tagData == "gear3/prog_index.m3u8", "Tag did not parse properly")
        XCTAssert(playlist.tags[7].tagData == "gear4/prog_index.m3u8", "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(masterPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_noHeaderHLS() {
        // we actually do not care if the incoming HLS playlist starts with #EXT3MU
        let hlsString = "#EXTINF:10"
        
        let playlist = parseVariantPlaylist(inString: hlsString)
        XCTAssert(playlist.tags.count == 1, "Unexpected number of tags")
    }
    
    func testHLSSampleMediaFileParser() {
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "hls_sampleMediaFile.txt")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        let playlist = parseVariantPlaylist(inString: hlsString)
        var testNilValue: String? = nil
        
        XCTAssert(playlist.tags.count == 18, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.EXT_X_VERSION, "Tag did not parse properly")
        XCTAssert(playlist.tags[1].tagDescriptor == PantosTag.EXT_X_I_FRAMES_ONLY, "Tag did not parse properly")
        XCTAssert(playlist.tags[2].tagDescriptor == PantosTag.EXT_X_PLAYLIST_TYPE, "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagDescriptor == PantosTag.EXT_X_ALLOW_CACHE, "Tag did not parse properly")
        XCTAssert(playlist.tags[4].tagDescriptor == PantosTag.EXT_X_TARGETDURATION, "Tag did not parse properly")
        XCTAssert(playlist.tags[5].tagDescriptor == PantosTag.EXT_X_MEDIA_SEQUENCE, "Tag did not parse properly")
        XCTAssert(playlist.tags[6].tagDescriptor == PantosTag.EXT_X_PROGRAM_DATE_TIME, "Tag did not parse properly")
        XCTAssert(playlist.tags[7].tagDescriptor == PantosTag.EXT_X_INDEPENDENT_SEGMENTS, "Tag did not parse properly")
        XCTAssert(playlist.tags[8].tagDescriptor == PantosTag.EXT_X_START, "Tag did not parse properly")
        XCTAssert(playlist.tags[9].tagDescriptor == PantosTag.EXT_X_KEY, "Tag did not parse properly")
        XCTAssert(playlist.tags[10].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[11].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[12].tagDescriptor == PantosTag.EXT_X_DISCONTINUITY, "Tag did not parse properly")
        XCTAssert(playlist.tags[13].tagDescriptor == PantosTag.EXT_X_KEY, "Tag did not parse properly")
        XCTAssert(playlist.tags[14].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[15].tagDescriptor == PantosTag.EXT_X_BYTERANGE, "Tag did not parse properly")
        XCTAssert(playlist.tags[16].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[17].tagDescriptor == PantosTag.EXT_X_ENDLIST, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(PantosTag.EXT_X_VERSION.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[1].tagName! == "#\(PantosTag.EXT_X_I_FRAMES_ONLY.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[2].tagName! == "#\(PantosTag.EXT_X_PLAYLIST_TYPE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagName! == "#\(PantosTag.EXT_X_ALLOW_CACHE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[4].tagName! == "#\(PantosTag.EXT_X_TARGETDURATION.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[5].tagName! == "#\(PantosTag.EXT_X_MEDIA_SEQUENCE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[6].tagName! == "#\(PantosTag.EXT_X_PROGRAM_DATE_TIME.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[7].tagName! == "#\(PantosTag.EXT_X_INDEPENDENT_SEGMENTS.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[8].tagName! == "#\(PantosTag.EXT_X_START.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[9].tagName! == "#\(PantosTag.EXT_X_KEY.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[10].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[11].tagName == nil, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[12].tagName! == "#\(PantosTag.EXT_X_DISCONTINUITY.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[13].tagName! == "#\(PantosTag.EXT_X_KEY.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[14].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[15].tagName! == "#\(PantosTag.EXT_X_BYTERANGE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[16].tagName == nil, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[17].tagName! == "#\(PantosTag.EXT_X_ENDLIST.toString())", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].value(forValueIdentifier: PantosValue.version) == "4", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[2].value(forValueIdentifier: PantosValue.playlistType) == "VOD", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[3].value(forValueIdentifier: PantosValue.allowCache) == "NO", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[4].value(forValueIdentifier: PantosValue.targetDurationSeconds) == 5220, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[5].value(forValueIdentifier: PantosValue.sequence) == "1", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[6].value(forValueIdentifier: PantosValue.programDateTime) == "2016-02-19T14:54:23.031+08:00", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[8].value(forValueIdentifier: PantosValue.startTimeOffset) == "0", "Tag did not parse properly")
        testNilValue = playlist.tags[8].value(forValueIdentifier: PantosValue.precise)
        XCTAssert(testNilValue == nil, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[9].value(forValueIdentifier: PantosValue.method) == "NONE", "Tag did not parse properly")
        testNilValue = playlist.tags[9].value(forValueIdentifier: PantosValue.uri)
        XCTAssert(testNilValue == nil, "Tag did not parse properly")
        testNilValue = playlist.tags[9].value(forValueIdentifier: PantosValue.ivector)
        XCTAssert(testNilValue == nil, "Tag did not parse properly")
        testNilValue = playlist.tags[9].value(forValueIdentifier: PantosValue.keyformat)
        XCTAssert(testNilValue == nil, "Tag did not parse properly")
        testNilValue = playlist.tags[9].value(forValueIdentifier: PantosValue.keyformatVersions)
        XCTAssert(testNilValue == nil, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[10].duration.seconds == 5220.0, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[11].tagData == "http://media.example.com/entire.ts", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[13].value(forValueIdentifier: PantosValue.method) == "SAMPLE-AES", "Tag did not parse properly")
        XCTAssert(playlist.tags[13].value(forValueIdentifier: PantosValue.uri) == "https://priv.example.com/key.php?r=52", "Tag did not parse properly")
        XCTAssert(playlist.tags[13].value(forValueIdentifier: PantosValue.ivector) == "0x9c7db8778570d05c3177c349fd9236aa", "Tag did not parse properly")
        XCTAssert(playlist.tags[13].value(forValueIdentifier: PantosValue.keyformat) == "com.apple.streamingkeydelivery", "Tag did not parse properly")
        XCTAssert(playlist.tags[13].value(forValueIdentifier: PantosValue.keyformatVersions) == "1", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[14].duration.seconds == 5220.0, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[15].value(forValueIdentifier: PantosValue.byterange) == "82112@752321", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[16].tagData == "http://media.example.com/entire1.ts", "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(variantPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_UnknownTagArray() {
        
        let unknownTag = "EXT-MADE_UP_TAG_FOR_TEST"
        let unknownPayload = "SomeTestData,MoreTestData"
        let hlsString = "#EXTM3U\n#\(unknownTag):\(unknownPayload)\n#EXT-X-TARGETDURATION:2\n#EXTINF:2"
        
        let playlist = parseVariantPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 3, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(unknownTag)", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagData == unknownPayload, "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(variantPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_UnknownTagSingleValue() {
        
        let unknownTag = "EXT-MADE_UP_TAG_FOR_TEST"
        let unknownPayload = "SomeTestData1"
        let hlsString = "#EXTM3U\n#\(unknownTag):\(unknownPayload)\n#EXT-X-TARGETDURATION:2\n#EXTINF:2"
        
        let playlist = parseVariantPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 3, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(unknownTag)", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagData == unknownPayload, "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(variantPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_UnknownTagDict() {
        
        let unknownTag = "EXT-MADE_UP_TAG_FOR_TEST"
        let unknownPayload = "KeyX=ValueX,KeyY=ValueY"
        let hlsString = "#EXTM3U\n#\(unknownTag):\(unknownPayload)\n#EXT-X-TARGETDURATION:2\n#EXTINF:2"
        
        let playlist = parseVariantPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 3, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(unknownTag)", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagData == unknownPayload, "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(variantPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_UnknownTagEmpty() {
        
        let unknownTag = "EXT-MADE_UP_TAG_FOR_TEST"
        let hlsString = "#EXTM3U\n#\(unknownTag)\n#EXT-X-TARGETDURATION:2\n#EXTINF:2"
        
        let playlist = parseVariantPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 3, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(unknownTag)", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagData == "", "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(variantPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
    
    func testHLSDescriptorCreation() {
        
        XCTAssert(PantosTag.constructTag(tag: PantosTag.Comment.toString())! == PantosTag.Comment, "create should create the correct tag")
        XCTAssert(PantosTag.constructTag(tag: PantosTag.Location.toString())! == PantosTag.Location, "create should create the correct tag")
        XCTAssert(PantosTag.constructTag(tag: PantosTag.UnknownTag.toString())! == PantosTag.UnknownTag, "create should create the correct tag")
        XCTAssert(PantosTag.constructTag(tag: PantosTag.EXTINF.toString())! == PantosTag.EXTINF, "create should create the correct tag")
        XCTAssert(PantosTag.constructTag(tag: PantosTag.EXT_X_VERSION.toString())! == PantosTag.EXT_X_VERSION, "create should create the correct tag")
        XCTAssert(PantosTag.constructTag(tag: PantosTag.EXT_X_STREAM_INF.toString())! == PantosTag.EXT_X_STREAM_INF, "create should create the correct tag")
    }
    
    func testParserWithURL() {
        
        let data = FixtureLoader.load(fixtureName: "hls_sampleMediaFile.txt")
        
        let parser = Parser()
        
        let expectation = self.expectation(description: "parse completion")
        
        var playlist: VariantPlaylistInterface? = nil
        
        let url = URL(string: "http://test.nowhere")!
        
        parser.parse(playlistData: data! as Data,
                     url: url,
                     callback: { result in
                        switch result {
                        case .parseError(let error):
                            XCTFail("testParserWithURL failure \(error)")
                            break
                        case .parsedVariant(let variant):
                            playlist = variant
                            break
                        case .parsedMaster(_):
                            XCTFail("testParserWithURL failure - wrong type")
                            break
                        }
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithURL: \(error!)")
                XCTFail()
            }
        })
        
        XCTAssert(playlist?.url == url, "playlist did not respect passed in url")
    }
    
    func testSimultaneousParsing() {
        
        let data1 = FixtureLoader.load(fixtureName: "hls_sampleMediaFile.txt")
        let data2 = FixtureLoader.load(fixtureName: "hls_sampleMasterFile.txt")
        
        let parser = Parser()
        
        let expectation1 = self.expectation(description: "parse completion 1")
        let expectation2 = self.expectation(description: "parse completion 2")
        
        var playlist1: VariantPlaylistInterface? = nil
        var playlist2: MasterPlaylistInterface? = nil
        
        let url1 = fakePlaylistURL()
        let url2 = fakePlaylistURL()
        
        parser.parse(playlistData: data1! as Data,
                     url: url1,
                     callback: { result in
                        switch result {
                        case .parseError(let error):
                            XCTFail("testParserWithURL failure \(error)")
                            break
                        case .parsedVariant(let variant):
                            playlist1 = variant
                            break
                        case .parsedMaster(_):
                            XCTFail("testParserWithURL failure - wrong type")
                            break
                        }
                        expectation1.fulfill()
        })

        parser.parse(playlistData: data2! as Data,
                     url: url2,
                     callback: { result in
                        switch result {
                        case .parseError(let error):
                            XCTFail("testParserWithURL failure \(error)")
                            break
                        case .parsedVariant(_):
                            XCTFail("testParserWithURL failure - wrong type")
                            break
                        case .parsedMaster(let master):
                            playlist2 = master
                            break
                        }
                        expectation2.fulfill()
        })

        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithoutURL: \(error!)")
                XCTFail()
            }
        })
        
        XCTAssert(playlist1?.tags.count == 18, "Unexpected number of tags")
        XCTAssert(playlist2?.tags.count == 5, "Unexpected number of tags")
    }
    
    func testEmptyDataParse() {
        
        let data = Data()
        
        let parser = Parser()
        
        let expectation = self.expectation(description: "parse completion")
        
        let url = URL(string: "http://test.nowhere")!
        
        parser.parse(playlistData: data as Data,
                     url: url,
                     callback: { result in
                        switch result {
                        case .parseError(_):
                            //expected result
                            break
                        default:
                            XCTFail("testParserWithURL failure - not expecting a playlist")
                            break
                        }
                        expectation.fulfill()
        })

        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithURL: \(error!)")
                XCTFail()
            }
        })
    }
    
    func testNearlyEmptyDataParse() {
        
        let data = " ".data(using: .utf8)!
        
        let parser = Parser()
        
        let expectation = self.expectation(description: "parse completion")
        
        let url = URL(string: "http://test.nowhere")!
        
        parser.parse(playlistData: data as Data,
                     url: url,
                     callback: { result in
                        switch result {
                        case .parseError(_):
                            //expected result
                            break
                        default:
                            XCTFail("testParserWithURL failure - not expecting a playlist")
                            break
                        }
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithURL: \(error!)")
                XCTFail()
            }
        })
    }
    
    func testNewlineDataParse() {
        
        let data = "\n".data(using: .utf8)!
        
        let parser = Parser()
        
        let expectation = self.expectation(description: "parse completion")
        
        let url = URL(string: "http://test.nowhere")!
        
        parser.parse(playlistData: data as Data,
                     url: url,
                     callback: { result in
                        switch result {
                        case .parseError(_):
                            //expected result
                            break
                        default:
                            XCTFail("testParserWithURL failure - not expecting a playlist")
                            break
                        }
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithURL: \(error!)")
                XCTFail()
            }
        })
    }
    
    func testParseInvalidEXTINF_no_colon() {
        
        let playlistString = """
#EXT3MU
#EXTINF
"""
        runParseExpectingFailure(withManfiestString: playlistString)
    }
    
    func testParseInvalidEXTINF_no_data() {
        
        let playlistString = """
#EXT3MU
#EXTINF:
"""
        runParseExpectingFailure(withManfiestString: playlistString)
    }
    
    func testParseInvalidMEDIASEQUENCE_no_colon() {
        
        let playlistString = """
#EXT3MU
#EXT-X-MEDIA-SEQUENCE:
"""
        runParseExpectingFailure(withManfiestString: playlistString)
    }
    
    func testParserWithShortTag() {
        let playlistString = """
#EXT3MU
#EXTINF:5000
a
"""
        let playlist = parseVariantPlaylist(inString: playlistString)
        
        XCTAssert(playlist.tags.count == 3, "Unexpected number of tags")
        XCTAssert(playlist.tags[1].tagDescriptor == PantosTag.EXTINF, "Second tag is not an EXTINF")
        XCTAssert(playlist.tags[2].tagDescriptor == PantosTag.Location, "Third tag is not a Location")
        XCTAssert(playlist.tags[2].tagData.isEqual(to: "a"), "Location tag does not have expected value")
    }
    
    func runParseExpectingFailure(withManfiestString playlistString: String) {
        let url: URL = fakePlaylistURL()
        let parser = Parser()
        let expectation = self.expectation(description: "parse complete")
        
        let data = playlistString.data(using: .utf8)!
        
        parser.parse(playlistData: data as Data,
                     url: url,
                     callback: { result in
                        switch result {
                        case .parseError(_):
                            //expected result
                            break
                        default:
                            XCTFail("testParserWithURL failure - not expecting a playlist")
                            break
                        }
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithURL: \(error!)")
                XCTFail()
            }
        })
    }
}
