//
//  HLSParserTest.swift
//  mamba
//
//  Created by David Coufal on 6/8/16.
//  Copyright © 2016 Comcast Cable Communications Management, LLC This software and its contents are
//  Comcast confidential and proprietary. It cannot be used, disclosed, or
//  distributed without Comcast's prior written permission. Modification of this
//  software is only allowed at the direction of Comcast Cable Communications Management, LLC All allowed
//  modifications must be provided to Comcast Cable Communications Management, LLC
//

import XCTest

@testable import mamba

class HLSParserTest: XCTestCase {
    
    func testHLS_singleMediaFile() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "hls_singleMediaFile.txt")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let playlist = parsePlaylist(inString: hlsString)
        
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
        
        XCTAssert(playlist.tags[0].value(forValueIdentifier: PantosValue.targetDurationSeconds) == 10, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[2].duration.seconds == 5220.0, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[3].tagData == "http://media.example.com/entire.ts", "Tag did not parse properly")
        
        let testNilValue: String? = playlist.tags[3].value(forValueIdentifier: PantosValue.targetDurationSeconds)
        XCTAssert(testNilValue == nil, "Tag did not parse properly")
        
        let validationIssues = HLSMasterPlaylistValidator.validate(hlsPlaylist: playlist)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_bipbopallMasterPlaylist() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "bipbopall.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let playlist = parsePlaylist(inString: hlsString)
        
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
        
        let validationIssues = HLSMasterPlaylistValidator.validate(hlsPlaylist: playlist)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_noHeaderHLS() {
        // we actually do not care if the incoming HLS playlist starts with #EXT3MU
        let hlsString = "#EXT-X-TARGETDURATION:10"
        
        let playlist = parsePlaylist(inString: hlsString)
        XCTAssert(playlist.tags.count == 1, "Unexpected number of tags")
    }
    
    func testHLSSampleMediaFileParser() {
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "hls_sampleMediaFile.txt")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        let playlist = parsePlaylist(inString: hlsString)
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
        
        XCTAssert(playlist.tags[4].value(forValueIdentifier: PantosValue.targetDurationSeconds) == 10, "Tag did not parse properly")
        
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
        
        let validationIssues = HLSMasterPlaylistValidator.validate(hlsPlaylist: playlist)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
    
    func testHLSVariantPlaylistWithDaterangeMetadata() {
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "hls_variant_playlist_with_daterange_metadata.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        let playlist = parsePlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 30, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.EXT_X_VERSION, "Tag did not parse properly")
        XCTAssert(playlist.tags[1].tagDescriptor == PantosTag.EXT_X_TARGETDURATION, "Tag did not parse properly")
        XCTAssert(playlist.tags[2].tagDescriptor == PantosTag.EXT_X_MEDIA_SEQUENCE, "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagDescriptor == PantosTag.EXT_X_DISCONTINUITY_SEQUENCE, "Tag did not parse properly")
        XCTAssert(playlist.tags[4].tagDescriptor == PantosTag.EXT_X_PROGRAM_DATE_TIME, "Tag did not parse properly")
        XCTAssert(playlist.tags[5].tagDescriptor == PantosTag.EXT_X_KEY, "Tag did not parse properly")
        XCTAssert(playlist.tags[6].tagDescriptor == PantosTag.EXT_X_MAP, "Tag did not parse properly")
        XCTAssert(playlist.tags[7].tagDescriptor == PantosTag.EXT_X_DATERANGE, "Tag did not parse properly")
        XCTAssert(playlist.tags[8].tagDescriptor == PantosTag.EXT_X_DATERANGE, "Tag did not parse properly")
        XCTAssert(playlist.tags[9].tagDescriptor == PantosTag.EXT_X_DATERANGE, "Tag did not parse properly")
        XCTAssert(playlist.tags[10].tagDescriptor == PantosTag.EXT_X_DATERANGE, "Tag did not parse properly")
        XCTAssert(playlist.tags[11].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[12].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[13].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[14].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[15].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[16].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[17].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[18].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[19].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[20].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[21].tagDescriptor == PantosTag.EXT_X_DATERANGE, "Tag did not parse properly")
        XCTAssert(playlist.tags[22].tagDescriptor == PantosTag.EXT_X_DATERANGE, "Tag did not parse properly")
        XCTAssert(playlist.tags[23].tagDescriptor == PantosTag.EXT_X_DATERANGE, "Tag did not parse properly")
        XCTAssert(playlist.tags[24].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[25].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[26].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[27].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        XCTAssert(playlist.tags[28].tagDescriptor == PantosTag.EXTINF, "Tag did not parse properly")
        XCTAssert(playlist.tags[29].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(PantosTag.EXT_X_VERSION.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[1].tagName! == "#\(PantosTag.EXT_X_TARGETDURATION.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[2].tagName! == "#\(PantosTag.EXT_X_MEDIA_SEQUENCE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[3].tagName! == "#\(PantosTag.EXT_X_DISCONTINUITY_SEQUENCE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[4].tagName! == "#\(PantosTag.EXT_X_PROGRAM_DATE_TIME.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[5].tagName! == "#\(PantosTag.EXT_X_KEY.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[6].tagName! == "#\(PantosTag.EXT_X_MAP.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[7].tagName! == "#\(PantosTag.EXT_X_DATERANGE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[8].tagName! == "#\(PantosTag.EXT_X_DATERANGE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[9].tagName! == "#\(PantosTag.EXT_X_DATERANGE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[10].tagName! == "#\(PantosTag.EXT_X_DATERANGE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[11].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssertNil(playlist.tags[12].tagName, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[13].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssertNil(playlist.tags[14].tagName, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[15].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssertNil(playlist.tags[16].tagName, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[17].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssertNil(playlist.tags[18].tagName, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[19].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssertNil(playlist.tags[20].tagName, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[21].tagName! == "#\(PantosTag.EXT_X_DATERANGE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[22].tagName! == "#\(PantosTag.EXT_X_DATERANGE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[23].tagName! == "#\(PantosTag.EXT_X_DATERANGE.toString())", "Tag did not parse properly")
        XCTAssert(playlist.tags[24].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssertNil(playlist.tags[25].tagName, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[26].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssertNil(playlist.tags[27].tagName, "Tag did not parse properly") // locations do not have tag names
        XCTAssert(playlist.tags[28].tagName! == "#\(PantosTag.EXTINF.toString())", "Tag did not parse properly")
        XCTAssertNil(playlist.tags[29].tagName, "Tag did not parse properly") // locations do not have tag names
        
        // Check that values are obtained correctly for all EXT-X-DATERANGE tags
        // #EXT-X-DATERANGE:ID="3-0x20-1585221432",START-DATE="2020-03-26T11:17:12.17Z",END-DATE="2020-03-26T11:26:25.123Z",SCTE35-IN=0xFC3039000000000000000000050680888462C900230221435545490000000300A00E1270636B5F45503030363739343031303331382104053ABE0441
        XCTAssertEqual(playlist.tags[7].value(forValueIdentifier: PantosValue.id), "3-0x20-1585221432", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[7].value(forValueIdentifier: PantosValue.startDate), "2020-03-26T11:17:12.17Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[7].value(forValueIdentifier: PantosValue.endDate), "2020-03-26T11:26:25.123Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[7].value(forValueIdentifier: PantosValue.scte35In), "0xFC3039000000000000000000050680888462C900230221435545490000000300A00E1270636B5F45503030363739343031303331382104053ABE0441", "Tag did not parse properly")
        // #EXT-X-DATERANGE:ID="1-0x22-1585221985",START-DATE="2020-03-26T11:26:25.122Z",PLANNED-DURATION=30.000,SCTE35-OUT=0xFC303E000000000000000000050680888462C900280226435545490000000100E000002932E00E1270636B5F4550303036373934303130333138220404EDA3A9F9
        XCTAssertEqual(playlist.tags[8].value(forValueIdentifier: PantosValue.id), "1-0x22-1585221985", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[8].value(forValueIdentifier: PantosValue.startDate), "2020-03-26T11:26:25.122Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[8].value(forValueIdentifier: PantosValue.plannedDuration), 30.000, "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[8].value(forValueIdentifier: PantosValue.scte35Out), "0xFC303E000000000000000000050680888462C900280226435545490000000100E000002932E00E1270636B5F4550303036373934303130333138220404EDA3A9F9", "Tag did not parse properly")
        // #EXT-X-DATERANGE:ID="5-0x30-1585221985",START-DATE="2020-03-26T11:26:25.122Z",PLANNED-DURATION=30.000,SCTE35-OUT=0xFC303E000000000000000000050680888462C900280226435545490000000500E000002932E00E1270636B5F455030303637393430313033313830040475A00967
        XCTAssertEqual(playlist.tags[9].value(forValueIdentifier: PantosValue.id), "5-0x30-1585221985", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[9].value(forValueIdentifier: PantosValue.startDate), "2020-03-26T11:26:25.122Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[9].value(forValueIdentifier: PantosValue.plannedDuration), 30.000, "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[9].value(forValueIdentifier: PantosValue.scte35Out), "0xFC303E000000000000000000050680888462C900280226435545490000000500E000002932E00E1270636B5F455030303637393430313033313830040475A00967", "Tag did not parse properly")
        // #EXT-X-DATERANGE:ID="2-0x10-1585219520",START-DATE="2020-03-26T10:45:20.894Z",PLANNED-DURATION=2713.000,SCTE35-OUT=0xFC303E0000000000000000000506807B4C487A00280226435545490000000200E0000E8DBD100E1270636B5F45503030363739343031303331381001018E5BFFD0
        XCTAssertEqual(playlist.tags[10].value(forValueIdentifier: PantosValue.id), "2-0x10-1585219520", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[10].value(forValueIdentifier: PantosValue.startDate), "2020-03-26T10:45:20.894Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[10].value(forValueIdentifier: PantosValue.plannedDuration), 2713.000, "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[10].value(forValueIdentifier: PantosValue.scte35Out), "0xFC303E0000000000000000000506807B4C487A00280226435545490000000200E0000E8DBD100E1270636B5F45503030363739343031303331381001018E5BFFD0", "Tag did not parse properly")
        // #EXT-X-DATERANGE:ID="1-0x22-1585221985",START-DATE="2020-03-26T11:26:25.122Z",END-DATE="2020-03-26T11:26:55.119Z",SCTE35-IN=0xFC303900000000000000000005068088AD947A00230221435545490000000100A00E1270636B5F455030303637393430313033313823040432668403
        XCTAssertEqual(playlist.tags[21].value(forValueIdentifier: PantosValue.id), "1-0x22-1585221985", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[21].value(forValueIdentifier: PantosValue.startDate), "2020-03-26T11:26:25.122Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[21].value(forValueIdentifier: PantosValue.endDate), "2020-03-26T11:26:55.119Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[21].value(forValueIdentifier: PantosValue.scte35In), "0xFC303900000000000000000005068088AD947A00230221435545490000000100A00E1270636B5F455030303637393430313033313823040432668403", "Tag did not parse properly")
        // #EXT-X-DATERANGE:ID="5-0x30-1585221985",START-DATE="2020-03-26T11:26:25.122Z",END-DATE="2020-03-26T11:26:55.119Z",SCTE35-IN=0xFC303900000000000000000005068088AD947A00230221435545490000000500A00E1270636B5F4550303036373934303130333138310404A150BE8C
        XCTAssertEqual(playlist.tags[22].value(forValueIdentifier: PantosValue.id), "5-0x30-1585221985", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[22].value(forValueIdentifier: PantosValue.startDate), "2020-03-26T11:26:25.122Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[22].value(forValueIdentifier: PantosValue.endDate), "2020-03-26T11:26:55.119Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[22].value(forValueIdentifier: PantosValue.scte35In), "0xFC303900000000000000000005068088AD947A00230221435545490000000500A00E1270636B5F4550303036373934303130333138310404A150BE8C", "Tag did not parse properly")
        // #EXT-X-DATERANGE:ID="3-0x20-1585222015",START-DATE="2020-03-26T11:26:55.119Z",PLANNED-DURATION=218.000,SCTE35-OUT=0xFC303E00000000000000000005068088AD947A00280226435545490000000300E000012B60A00E1270636B5F45503030363739343031303331382005058B0ADF75
        XCTAssertEqual(playlist.tags[23].value(forValueIdentifier: PantosValue.id), "3-0x20-1585222015", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[23].value(forValueIdentifier: PantosValue.startDate), "2020-03-26T11:26:55.119Z", "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[23].value(forValueIdentifier: PantosValue.plannedDuration), 218.000, "Tag did not parse properly")
        XCTAssertEqual(playlist.tags[23].value(forValueIdentifier: PantosValue.scte35Out), "0xFC303E00000000000000000005068088AD947A00280226435545490000000300E000012B60A00E1270636B5F45503030363739343031303331382005058B0ADF75", "Tag did not parse properly")
        
        let validationIssues = HLSVariantPlaylistValidator.validate(hlsPlaylist: playlist)
        XCTAssertNil(validationIssues, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_UnknownTagArray() {
        
        let unknownTag = "EXT-MADE_UP_TAG_FOR_TEST"
        let unknownPayload = "SomeTestData,MoreTestData"
        let hlsString = "#EXTM3U\n#\(unknownTag):\(unknownPayload)"
        
        let playlist = parsePlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 1, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(unknownTag)", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagData == unknownPayload, "Tag did not parse properly")
        
        let validationIssues = HLSMasterPlaylistValidator.validate(hlsPlaylist: playlist)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_UnknownTagSingleValue() {
        
        let unknownTag = "EXT-MADE_UP_TAG_FOR_TEST"
        let unknownPayload = "SomeTestData1"
        let hlsString = "#EXTM3U\n#\(unknownTag):\(unknownPayload)"
        
        let playlist = parsePlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 1, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(unknownTag)", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagData == unknownPayload, "Tag did not parse properly")
        
        let validationIssues = HLSMasterPlaylistValidator.validate(hlsPlaylist: playlist)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_UnknownTagDict() {
        
        let unknownTag = "EXT-MADE_UP_TAG_FOR_TEST"
        let unknownPayload = "KeyX=ValueX,KeyY=ValueY"
        let hlsString = "#EXTM3U\n#\(unknownTag):\(unknownPayload)"
        
        let playlist = parsePlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 1, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(unknownTag)", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagData == unknownPayload, "Tag did not parse properly")
        
        let validationIssues = HLSMasterPlaylistValidator.validate(hlsPlaylist: playlist)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_UnknownTagEmpty() {
        
        let unknownTag = "EXT-MADE_UP_TAG_FOR_TEST"
        let hlsString = "#EXTM3U\n#\(unknownTag)"
        
        let playlist = parsePlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 1, "Misparsed the HLS")
        
        XCTAssert(playlist.tags[0].tagDescriptor == PantosTag.UnknownTag, "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagName! == "#\(unknownTag)", "Tag did not parse properly")
        
        XCTAssert(playlist.tags[0].tagData == "", "Tag did not parse properly")
        
        let validationIssues = HLSMasterPlaylistValidator.validate(hlsPlaylist: playlist)
        XCTAssert((validationIssues != nil) ? validationIssues!.count == 0 : true, "Should be no issues in the HLS fixtures")
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

        let parser = HLSParser()
        
        let expectation = self.expectation(description: "parse completion")
        
        var playlist: HLSPlaylist? = nil
        
        let url = URL(string: "http://test.nowhere")!
        
        parser.parse(playlistData: data! as Data,
                     url: url,
                     success: { (m) in
                        playlist = m
                        expectation.fulfill()
        },
                     failure: { (error) in
                        XCTFail("testParserWithURL failure")
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
        
        let parser = HLSParser()
        
        let expectation1 = self.expectation(description: "parse completion 1")
        let expectation2 = self.expectation(description: "parse completion 2")
        
        var playlist1: HLSPlaylist? = nil
        var playlist2: HLSPlaylist? = nil
        
        let url1 = fakePlaylistURL()
        let url2 = fakePlaylistURL()
        
        parser.parse(playlistData: data1! as Data,
                     url: url1,
                     success: { (m) in
                        playlist1 = m
                        expectation1.fulfill()
        },
                     failure: { (error) in
                        XCTFail("testParserWithoutURL failure")
                        expectation1.fulfill()
        })
        
        parser.parse(playlistData: data2! as Data,
                     url: url2,
                     success: { (m) in
                        playlist2 = m
                        expectation2.fulfill()
        },
                     failure: { (error) in
                        XCTFail("testParserWithoutURL failure")
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
        
        let parser = HLSParser()
        
        let expectation = self.expectation(description: "parse completion")
        
        var playlist: HLSPlaylist? = nil
        
        let url = URL(string: "http://test.nowhere")!
        
        parser.parse(playlistData: data,
                     url: url,
                     success: { (m) in
                        playlist = m
                        expectation.fulfill()
        },
                     failure: { (error) in
                        XCTFail("testParserWithURL failure")
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithURL: \(error!)")
                XCTFail()
            }
        })
        
        XCTAssert(playlist?.tags.count == 0, "playlist should be empty")
    }
    
    func testNearlyEmptyDataParse() {
        
        let data = " ".data(using: .utf8)!
        
        let parser = HLSParser()
        
        let expectation = self.expectation(description: "parse completion")
        
        var playlist: HLSPlaylist? = nil
        
        let url = URL(string: "http://test.nowhere")!
        
        parser.parse(playlistData: data,
                     url: url,
                     success: { (m) in
                        playlist = m
                        expectation.fulfill()
        },
                     failure: { (error) in
                        XCTFail("testParserWithURL failure")
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithURL: \(error!)")
                XCTFail()
            }
        })
        
        XCTAssertNotNil(playlist, "playlist should exist")
    }
    
    func testNewlineDataParse() {
        
        let data = "\n".data(using: .utf8)!
        
        let parser = HLSParser()
        
        let expectation = self.expectation(description: "parse completion")
        
        var playlist: HLSPlaylist? = nil
        
        let url = URL(string: "http://test.nowhere")!
        
        parser.parse(playlistData: data,
                     url: url,
                     success: { (m) in
                        playlist = m
                        expectation.fulfill()
        },
                     failure: { (error) in
                        XCTFail("testParserWithURL failure")
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in testParserWithURL: \(error!)")
                XCTFail()
            }
        })
        
        XCTAssertNotNil(playlist, "playlist should exist")
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
        let playlist = parsePlaylist(inString: playlistString)
        
        XCTAssert(playlist.tags.count == 3, "Unexpected number of tags")
        XCTAssert(playlist.tags[1].tagDescriptor == PantosTag.EXTINF, "Second tag is not an EXTINF")
        XCTAssert(playlist.tags[2].tagDescriptor == PantosTag.Location, "Third tag is not a Location")
        XCTAssert(playlist.tags[2].tagData.isEqual(to: "a"), "Location tag does not have expected value")
    }
    
    func runParseExpectingFailure(withManfiestString playlistString: String) {
        let url: URL = fakePlaylistURL()
        let parser = HLSParser()
        let expectation = self.expectation(description: "parse complete")
        
        let data = playlistString.data(using: .utf8)!
        
        parser.parse(playlistData: data,
                     url: url,
                     success: { (m) in
                        XCTFail("Expecting failure with playlist: \(playlistString)")
                        expectation.fulfill()
        },
                     failure: { (error) in
                        // expected result
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: { error in
            if (error != nil) {
                XCTFail("Timeout error: \(String(describing: error))")
            }
        })
    }
}
