//
//  HLSValidatorTests.swift
//  mamba
//
//  Created by Mohan on 8/9/16.
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

class HLSValidatorTests: XCTestCase {

    var EXT_X_MEDIA_txt = ["#EXTM3U\n",
               "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n",
               "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"g147200\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n",
               "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"g104000\",NAME=\"Spanish\",LANGUAGE=\"es\",URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-sap-bandwidth-104000-repid-104000.m3u8\n",
               "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"g147200\",NAME=\"Spanish\",LANGUAGE=\"es\",URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-sap-bandwidth-147200-repid-147200.m3u8\n",
               "#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English (Forced)\",DEFAULT=NO,AUTOSELECT=NO,FORCED=YES,LANGUAGE=\"en\",URI=\"subtitles/eng_forced/prog_index.m3u8\"\n",
               "#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"en\",CHARACTERISTICS=\"public.accessibility.transcribes-spoken-dialog, public.accessibility.describes-music-and-sound\",URI=\"subtitles/eng/prog_index.m3u8\"\n"]
    
    var EXT_X_MEDIA_SEQUENCE_txt = ["#EXTM3U\n",
                                    "#EXT-X-VERSION:4\n",
                                    "#EXT-X-I-FRAMES-ONLY\n",
                                    "#EXT-X-PLAYLIST-TYPE:VOD\n",
                                    "#EXT-X-ALLOW-CACHE:NO\n",
                                    "#EXT-X-TARGETDURATION:10\n",
                                    "#EXT-X-MEDIA-SEQUENCE:1\n",
                                    "#EXT-X-PROGRAM-DATE-TIME:2016-02-19T14:54:23.031+08:00\n",
                                    "#EXT-X-KEY:METHOD=NONE\n",
                                    "#EXTINF:10,1\n",
                                    "http://media.example.com/entire.ts\n",
                                    "#EXT-X-DISCONTINUITY\n",
                                    "#EXT-X-KEY:METHOD=AES-128,URI=\"https://priv.example.com/key.php\"?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa\n",
                                    "#EXTINF:10,2\n",
                                    "#EXT-X-BYTERANGE:82112@752321\n",
                                    "http://media.example.com/entire1.ts\n",
                                    "#EXT-X-ENDLIST"]
    
    let EXT_X_MEDIA_SEQUENCE2_txt = ["#EXTM3U\n",
                                     "#EXT-X-VERSION:6\n",
                                     "#EXT-X-TARGETDURATION:11\n",
                                     "#EXT-X-MEDIA-SEQUENCE:0\n",
                                     "#EXT-X-START:TIME-OFFSET=30,PRECISE=YES\n",
                                     "#EXT-X-PLAYLIST-TYPE:VOD\n",
                                     "#EXTINF:9.9766,1\n",
                                     "#EXT-X-BYTERANGE:326744@0\n",
                                     "main.ts\n",
                                     "#EXTINF:9.1,2\n",
                                     "#EXT-X-BYTERANGE:326368@326744\n",
                                     "main.ts\n",
                                     "#EXTINF:10,3\n",
                                     "#EXT-X-BYTERANGE:327120@653112\n",
                                     "main.ts\n",
                                     "#EXTINF:9,4\n",
                                     "#EXT-X-BYTERANGE:326556@980232\n",
                                     "main.ts\n",
                                     "#EXTINF:10,5\n",
                                     "#EXT-X-BYTERANGE:326368@1306788\n",
                                     "main.ts\n",
                                     "#EXTINF:9.5,6\n",
                                     "#EXT-X-BYTERANGE:327684@1633156\n",
                                     "main.ts\n",
                                     "#EXTINF:9.3,6\n",
                                     "#EXT-X-BYTERANGE:327684@1633156\n",
                                     "main.ts\n"]
    
    var AudioVideoGroup_txt = ["#EXTM3U\n",
                               "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"es\",ASSOC-LANGUAGE=\"es\",DEFAULT=YES,AUTOSELECT=YES\n",
                               "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"g147200\",NAME=\"English\",LANGUAGE=\"es\",ASSOC-LANGUAGE=\"es\",DEFAULT=YES,AUTOSELECT=YES\n",
                               "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"g104000\",NAME=\"Spanish\",LANGUAGE=\"es\",ASSOC-LANGUAGE=\"es\",URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-sap-bandwidth-104000-repid-104000.m3u8\"\n",
                               "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"g147200\",NAME=\"Spanish\",LANGUAGE=\"es\",ASSOC-LANGUAGE=\"es\",URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-sap-bandwidth-147200-repid-147200.m3u8\"\n",
                               "#EXT-X-STREAM-INF:BANDWIDTH=560400,AUDIO=\"g104000\",PROGRAM-ID=1,CODECS=\"avc1.4d401f,mp4a.40.5\",RESOLUTION=320x180,SUBTITLES=\"subs\"\n",
                               "IP_720p60_51_SAP_TS/4242/format-hls-track-muxed-bandwidth-560400-repid-560400.m3u8\n",
                               "#EXT-X-STREAM-INF:BANDWIDTH=788800,AUDIO=\"g147200\",PROGRAM-ID=1,CODECS=\"avc1.4d401f,mp4a.40.5\",RESOLUTION=320x180,SUBTITLES=\"subs\"\\n",
                               "IP_720p60_51_SAP_TS/4242/format-hls-track-muxed-bandwidth-788800-repid-788800.m3u8\n",
                               "#EXT-X-STREAM-INF:BANDWIDTH=1072000,AUDIO=\"g147200\",PROGRAM-ID=1,CODECS=\"avc1.4d401f,mp4a.40.5\",RESOLUTION=512x288\n",
                               "IP_720p60_51_SAP_TS/4242/format-hls-track-muxed-bandwidth-1072000-repid-1072000.m3u8\n",
                               "#EXT-X-STREAM-INF:BANDWIDTH=1426400,AUDIO=\"g147200\",PROGRAM-ID=1,CODECS=\"avc1.4d401f,mp4a.40.5\",RESOLUTION=640x360\n",
                               "IP_720p60_51_SAP_TS/4242/format-hls-track-muxed-bandwidth-1426400-repid-1426400.m3u8\n",
                               "#EXT-X-STREAM-INF:BANDWIDTH=2064400,AUDIO=\"g147200\",PROGRAM-ID=1,CODECS=\"avc1.4d401f,mp4a.40.5\",RESOLUTION=768x432\n",
                               "IP_720p60_51_SAP_TS/4242/format-hls-track-muxed-bandwidth-2064400-repid-2064400.m3u8\n",
                               "#EXT-X-STREAM-INF:BANDWIDTH=3190400,AUDIO=\"g147200\",PROGRAM-ID=1,CODECS=\"avc1.4d4020,mp4a.40.5\",RESOLUTION=1280x720\n",
                               "IP_720p60_51_SAP_TS/4242/format-hls-track-muxed-bandwidth-3190400-repid-3190400.m3u8\n",
                               "#EXT-X-STREAM-INF:BANDWIDTH=4529600,AUDIO=\"g147200\",PROGRAM-ID=1,CODECS=\"avc1.640029,mp4a.40.5\",RESOLUTION=1280x720\n",
                               "IP_720p60_51_SAP_TS/4242/format-hls-track-muxed-bandwidth-4529600-repid-4529600.m3u8\n",
                               "#EXT-X-STREAM-INF:BANDWIDTH=104000,AUDIO=\"g104000\",PROGRAM-ID=1,CODECS=\"mp4a.40.5\"\n",
                               "IP_720p60_51_SAP_TS/4242/format-hls-track-audio-bandwidth-104000-repid-104000.m3u8"]
    
    let SubtitlesAndCCGroup_txt = ["#EXTM3U\n",
                                   "#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"en\",CHARACTERISTICS=\"public.accessibility.transcribes-spoken-dialog, public.accessibility.describes-music-and-sound\",URI=\"subtitles/eng/prog_index.m3u8\"\n",
                                   "#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English (Forced)\",DEFAULT=NO,AUTOSELECT=NO,FORCED=YES,LANGUAGE=\"en\",URI=\"subtitles/eng_forced/prog_index.m3u8\"\n",
                                   "#EXT-X-MEDIA:TYPE=CLOSED-CAPTIONS,GROUP-ID=\"cc1\",LANGUAGE=\"en\",NAME=\"English\",AUTOSELECT=YES,DEFAULT=YES,INSTREAM-ID=\"CC1\"\n",
                                   "#EXT-X-STREAM-INF:BANDWIDTH=263851,CODECS=\"mp4a.40.2, avc1.4d400d\",RESOLUTION=416x234,SUBTITLES=\"subs\"\n",
                                   "gear1/prog_index.m3u8\n",
                                   "#EXT-X-STREAM-INF:BANDWIDTH=41457,CODECS=\"mp4a.40.2\",CLOSED-CAPTIONS=\"cc1\",SUBTITLES=\"subs\"\n",
                                   "gear0/prog_index.m3u8"]
    
    func testHLS_singleMediaFile() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "hls_singleMediaFile.txt")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let playlist = parsePlaylist(inString: hlsString)
        guard let validationIssues = HLSMasterPlaylistValidator.validate(hlsPlaylist: playlist) else {
            return
        }
        if validationIssues.count > 0 {
            XCTAssert(false, "Found unexpected validation Issue")
        }
    }
    
    private func validate(validator: HLSPlaylistValidator.Type, playlist: String, expected: Int) {
        
        let m = parsePlaylist(inString: playlist)
        guard let validationIssues = validator.validate(hlsPlaylist: m) else {
            if expected > 0 {
                XCTAssert(false, "Found unexpected validation Issues should have \(expected) actually has 0")
            }
            return
        }
        
        if validationIssues.count != expected {
            XCTAssert(false, "Found unexpected validation Issues should have \(expected) actually has \(validationIssues.count)")
        } else if expected == 0 {
            XCTAssert(false, "Validation issues should be nil, not empty, when 0 issues found")
        }
    }
    
    func testEXT_X_MEDIARenditionGroupTYPEValidatorOK() {
        
        let u = EXT_X_MEDIARenditionGroupTYPEValidator.self
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }

    func testEXT_X_MEDIARenditionGroupTYPEValidatorNonMatchingTypes() {
        
        let u = EXT_X_MEDIARenditionGroupTYPEValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_MEDIARenditionGroupTYPEValidatorMultipleNonMatchingTypes() {
        
        let u = EXT_X_MEDIARenditionGroupTYPEValidator.self
        EXT_X_MEDIA_txt += [
            "#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n",
            "#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g147200\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n"]
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 2)
    }
    
    func testEXT_X_MEDIARenditionGroupTYPEValidatorMissingType() {
        
        let u = EXT_X_MEDIARenditionGroupTYPEValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_MEDIARenditionGroupTYPEValidatorMissingGroup() {
        
        let u = EXT_X_MEDIARenditionGroupTYPEValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_MEDIARenditionGroupNAMEValidatorOK() {
        
        let u = EXT_X_MEDIARenditionGroupNAMEValidator.self
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_MEDIARenditionGroupNAMEValidatorDuplicateName() {
        
        let u = EXT_X_MEDIARenditionGroupNAMEValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_MEDIARenditionGroupNAMEValidatorMultipleDuplicateNames() {
        
        let u = EXT_X_MEDIARenditionGroupNAMEValidator.self
        EXT_X_MEDIA_txt += [
            "#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n",
            "#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g147200\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n"]
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 2)
    }
    
    func testEXT_X_MEDIARenditionGroupNAMEValidatorMissingName() {
        
        let u = EXT_X_MEDIARenditionGroupNAMEValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:GROUP-ID=\"g104000\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_MEDIARenditionGroupNAMEValidatorMissingGroup() {
        
        let u = EXT_X_MEDIARenditionGroupNAMEValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_MEDIARenditionGroupDEFAULTValidator() {
        
        let u = EXT_X_MEDIARenditionGroupDEFAULTValidator.self
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_MEDIARenditionGroupDEFAULTValidatorExtraValueOK() {
        
        let u = EXT_X_MEDIARenditionGroupDEFAULTValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=NO,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_MEDIARenditionGroupDEFAULTValidatorExtraValue() {
        
        let u = EXT_X_MEDIARenditionGroupDEFAULTValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_MEDIARenditionGroupDEFAULTValidatorExtraMissingValue() {
        
        let u = EXT_X_MEDIARenditionGroupDEFAULTValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_MEDIARenditionGroupAUTOSELECTValidator() {
        
        let u = EXT_X_MEDIARenditionGroupAUTOSELECTValidator.self
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_MEDIARenditionGroupAUTOSELECTValidatorDuplicateValue() {
        
        let u = EXT_X_MEDIARenditionGroupAUTOSELECTValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_MEDIARenditionGroupAUTOSELECTValidatorValidExtraValue() {
        
        let u = EXT_X_MEDIARenditionGroupAUTOSELECTValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"fr\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testHLSPlaylistAggregateTagGroupValidatorOK() {
        
        let u = HLSPlaylistRenditionGroupValidator.self
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testHLSPlaylistAggregateTagGroupValidatorMultipleFails() {
        
        let u = HLSPlaylistRenditionGroupValidator.self
        EXT_X_MEDIA_txt.append("#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"fr\",DEFAULT=YES,AUTOSELECT=YES\n")
        let hlsLoadString = EXT_X_MEDIA_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 4)
    }
    
    func testHLSPlaylistAggregateTagCardinalityValidatorOK() {

        let u = HLSPlaylistAggregateTagCardinalityValidator.self
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testHLSPlaylistAggregateTagCardinalityValidatorDuplicate() {
        
        EXT_X_MEDIA_SEQUENCE_txt.append("\n#EXT-X-MEDIA-SEQUENCE:2\n")
        let u = HLSPlaylistAggregateTagCardinalityValidator.self
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testHLSPlaylistAggregateTagCardinalityValidatorDuplicateTARGET_DURATION() {
        
        EXT_X_MEDIA_SEQUENCE_txt.append("\n#EXT-X-TARGETDURATION:10\n")
        let u = HLSPlaylistAggregateTagCardinalityValidator.self
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testHLSPlaylistAggregateTagCardinalityValidatorMissingTARGET_DURATION() {
        
        EXT_X_MEDIA_SEQUENCE_txt.remove(at: 5)
        let u = HLSPlaylistAggregateTagCardinalityValidator.self
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testHLSPlaylistAggregateTagCardinalityValidatorMultipleDuplicates() {
        
        EXT_X_MEDIA_SEQUENCE_txt.append("\n#EXT-X-MEDIA-SEQUENCE:2\n")
        EXT_X_MEDIA_SEQUENCE_txt.append("\n#EXT-X-ENDLIST\n")
        let u = HLSPlaylistAggregateTagCardinalityValidator.self
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 2)
    }
    
    func testHLSPlaylistAggregateTagCardinalityValidatorMissing() {

        EXT_X_MEDIA_SEQUENCE_txt.remove(at: 6)
        let u = HLSPlaylistAggregateTagCardinalityValidator.self
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testAudioGroupOK() {
        
        let u = HLSPlaylistRenditionGroupAUDIOValidator.self
        let hlsLoadString = AudioVideoGroup_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testAudioGroupNoCommonCodec() {
        
        let u = HLSPlaylistRenditionGroupAUDIOValidator.self
        AudioVideoGroup_txt.append("\n#EXT-X-STREAM-INF:BANDWIDTH=560400,AUDIO=\"g104000\",PROGRAM-ID=1,CODECS=\"badcodec\",RESOLUTION=320x180\n")
        let hlsLoadString = AudioVideoGroup_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testVideoGroupOK() {
        
        let hlsLoadString = AudioVideoGroup_txt.map { $0.replacingOccurrences(of: "AUDIO", with: "VIDEO") }.joined()
        let u = HLSPlaylistRenditionGroupVIDEOValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testVideoGroupNoCommonCodec() {
        
        AudioVideoGroup_txt.append("\n#EXT-X-STREAM-INF:BANDWIDTH=560400,VIDEO=\"g104000\",PROGRAM-ID=1,CODECS=\"badcodec\",RESOLUTION=320x180\n")
        let hlsLoadString = AudioVideoGroup_txt.map { $0.replacingOccurrences(of: "AUDIO", with: "VIDEO") }.joined()
        let u = HLSPlaylistRenditionGroupVIDEOValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupAUDIOValidatorOK() {
        
        let u = EXT_X_STREAM_INFRenditionGroupAUDIOValidator.self
        let hlsLoadString = AudioVideoGroup_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    
    func testEXT_X_STREAM_INFRenditionGroupAUDIOValidatorMissingEXT_X_MEDIA() {
        
        let u = EXT_X_STREAM_INFRenditionGroupAUDIOValidator.self
        AudioVideoGroup_txt.remove(at: 1)
        AudioVideoGroup_txt.remove(at: 2)
        let hlsLoadString = AudioVideoGroup_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupAUDIOValidatorMissingEXT_X_STREAM_INF() {
        
        let u = EXT_X_STREAM_INFRenditionGroupAUDIOValidator.self
        AudioVideoGroup_txt.remove(at: AudioVideoGroup_txt.count - 2)
        AudioVideoGroup_txt.remove(at: 5)
        let hlsLoadString = AudioVideoGroup_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupSUBTITLESValidatorOK() {
        
        let u = EXT_X_STREAM_INFRenditionGroupSUBTITLESValidator.self
        let hlsLoadString = SubtitlesAndCCGroup_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupSUBTITLESValidatorMissingEXT_X_MEDIA() {
        
        let u = EXT_X_STREAM_INFRenditionGroupSUBTITLESValidator.self
        var SubtitlesGroupTxt = SubtitlesAndCCGroup_txt
        SubtitlesGroupTxt.remove(at: 2)
        SubtitlesGroupTxt.remove(at: 1)
        let hlsLoadString = SubtitlesGroupTxt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupSUBTITLESValidatorMissingEXT_X_STREAM_INF() {
        
        let u = EXT_X_STREAM_INFRenditionGroupSUBTITLESValidator.self
        var SubtitlesGroupTxt = SubtitlesAndCCGroup_txt
        SubtitlesGroupTxt.remove(at: 7)
        SubtitlesGroupTxt.remove(at: 6)
        SubtitlesGroupTxt.remove(at: 5)
        SubtitlesGroupTxt.remove(at: 4)
        let hlsLoadString = SubtitlesGroupTxt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupVIDEOValidatorOK() {
        
        let hlsLoadString = AudioVideoGroup_txt.map { $0.replacingOccurrences(of: "AUDIO", with: "VIDEO") }.joined()
        let u = EXT_X_STREAM_INFRenditionGroupVIDEOValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupVIDEOValidatorMissingEXT_X_MEDIA() {
        
        AudioVideoGroup_txt.remove(at: 1)
        AudioVideoGroup_txt.remove(at: 2)
        let hlsLoadString = AudioVideoGroup_txt.map { $0.replacingOccurrences(of: "AUDIO", with: "VIDEO") }.joined()
        let u = EXT_X_STREAM_INFRenditionGroupVIDEOValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupVIDEOValidatorMissingEXT_X_STREAM_INF() {
        
        let u = EXT_X_STREAM_INFRenditionGroupVIDEOValidator.self
        AudioVideoGroup_txt.remove(at: AudioVideoGroup_txt.count - 2)
        AudioVideoGroup_txt.remove(at: 5)
        let hlsLoadString = AudioVideoGroup_txt.map { $0.replacingOccurrences(of: "AUDIO", with: "VIDEO") }.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupVIDEOValidatorMissingAllEXT_X_STREAM_INF() {
        
        let u = EXT_X_STREAM_INFRenditionGroupVIDEOValidator.self
        let newGroup = AudioVideoGroup_txt[0...4]
        let hlsLoadString = newGroup.map { $0.replacingOccurrences(of: "AUDIO", with: "VIDEO") }.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_TARGETDURATIONLengthValidationOK() {
        
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE_txt.joined()
        let u = EXT_X_TARGETDURATIONLengthValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_TARGETDURATIONLengthValidationTooLong() {
        
        EXT_X_MEDIA_SEQUENCE_txt.append("\n#EXTINF:11,1\n")
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE_txt.joined()
        let u = EXT_X_TARGETDURATIONLengthValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }

    func testEXT_X_TARGETDURATIONLengthValidationEXTINFDurationAtLimit() {
        
        let hlsLoadString = """
#EXTM3U
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-TARGETDURATION:6
#EXTINF:6.999
frag1.ts
"""
        let u = EXT_X_TARGETDURATIONLengthValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }

    func testEXT_X_TARGETDURATIONLengthValidationEXTINFDurationBeyondLimit() {
        
        let hlsLoadString = """
#EXTM3U
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-TARGETDURATION:6
#EXTINF:7.00
frag1.ts
"""
        let u = EXT_X_TARGETDURATIONLengthValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }

    func testMatchingPROGRAM_IDValidatorOK() {
        
        let hlsLoadString = AudioVideoGroup_txt.joined()
        let u = HLSPlaylistRenditionGroupMatchingPROGRAM_IDValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testMatchingPROGRAM_IDValidatorMisMatch() {
        
        AudioVideoGroup_txt.append("\n#EXT-X-STREAM-INF:BANDWIDTH=560400,VIDEO=\"g104000\",PROGRAM-ID=2,CODECS=\"badcodec\",RESOLUTION=320x180\n")
        let hlsLoadString = AudioVideoGroup_txt.joined()
        let u = HLSPlaylistRenditionGroupMatchingPROGRAM_IDValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testMatchingPROGRAM_IDValidatorMissing() {
        
        AudioVideoGroup_txt.append("\n#EXT-X-STREAM-INF:BANDWIDTH=560400,VIDEO=\"g104000\",PROGRAM-ID=,CODECS=\"badcodec\",RESOLUTION=320x180\n")
        let hlsLoadString = AudioVideoGroup_txt.joined()
        let u = HLSPlaylistRenditionGroupMatchingPROGRAM_IDValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testRenditionGroupMatchingNAMELANGUAGEValidatorOK() {
        
        let hlsLoadString = AudioVideoGroup_txt.joined()
        let u = HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testRenditionGroupMatchingNAMELANGUAGEValidatorExtraName() {
        
        AudioVideoGroup_txt.append("\n#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"French\",LANGUAGE=\"en\",DEFAULT=NO,AUTOSELECT=YES\n")
        let hlsLoadString = AudioVideoGroup_txt.joined()
        let u = HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testRenditionGroupMatchingNAMELANGUAGEValidatorExtraLanguage() {
        
        AudioVideoGroup_txt.append("\n#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"Spanish\",LANGUAGE=\"fr\",DEFAULT=NO,AUTOSELECT=YES\n")
        let hlsLoadString = AudioVideoGroup_txt.joined()
        let u = HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testRenditionGroupMatchingNAMELANGUAGEValidatorExtraBoth() {
        
        AudioVideoGroup_txt.append("\n#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",NAME=\"French\",LANGUAGE=\"fr\",DEFAULT=NO,AUTOSELECT=YES\n")
        let hlsLoadString = AudioVideoGroup_txt.joined()
        let u = HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testRenditionGroupMatchingNAMELANGUAGEValidatorMissingName() {
        
        AudioVideoGroup_txt.append("\n#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID=\"g104000\",LANGUAGE=\"dr\",DEFAULT=NO,AUTOSELECT=YES\n")
        let hlsLoadString = AudioVideoGroup_txt.joined()
        let u = HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_DISCONTINUITY_SEQUENCEValidationOK() {
        
        let u = HLSPlaylistAggregateTagCardinalityValidator.self
        var DiscontinuitySequenceTxt = EXT_X_MEDIA_SEQUENCE_txt
        DiscontinuitySequenceTxt.insert("#EXT-X-DISCONTINUITY-SEQUENCE:1\n", at: 11)
        let hlsLoadString = DiscontinuitySequenceTxt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_DISCONTINUITY_SEQUENCEValidationDuplicate() {
        
        var DiscontinuitySequenceTxt = EXT_X_MEDIA_SEQUENCE_txt
        DiscontinuitySequenceTxt.insert("#EXT-X-DISCONTINUITY-SEQUENCE:1\n", at: 11)
        DiscontinuitySequenceTxt.append("\n#EXT-X-DISCONTINUITY-SEQUENCE:2\n")
        let hlsLoadString = DiscontinuitySequenceTxt.joined()
        let u = HLSPlaylistAggregateTagCardinalityValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_STARTTimeOffsetValidatorOK() {
        
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE2_txt.joined()
        let u = EXT_X_STARTTimeOffsetValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    
    func testEXT_X_STARTTimeOffsetValidatorNearEndTime() {
        
        let hlsLoadString = EXT_X_MEDIA_SEQUENCE2_txt.map { $0.replacingOccurrences(of: "TIME-OFFSET=30", with: "TIME-OFFSET=60") }.joined()
        let u = EXT_X_STARTTimeOffsetValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_STARTTimeOffsetWithEndListValidatorOK() {
        
        var hlsLoadString = EXT_X_MEDIA_SEQUENCE2_txt.joined()
        hlsLoadString.append("\n#EXT-X-ENDLIST\n")
        let u = EXT_X_STARTTimeOffsetValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STARTTimeOffsetsetWithEndListValidatorNearEndTime() {
        
        var hlsLoadString = EXT_X_MEDIA_SEQUENCE2_txt.map { $0.replacingOccurrences(of: "TIME-OFFSET=30", with: "TIME-OFFSET=60") }.joined()
        hlsLoadString.append("\n#EXT-X-ENDLIST\n")
        let u = EXT_X_STARTTimeOffsetValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STARTTimeOffsetsetWithEndListValidatorExceedEndTime() {
        
        var hlsLoadString = EXT_X_MEDIA_SEQUENCE2_txt.map { $0.replacingOccurrences(of: "TIME-OFFSET=30", with: "TIME-OFFSET=90") }.joined()
        hlsLoadString.append("\n#EXT-X-ENDLIST\n")
        let u = EXT_X_STARTTimeOffsetValidator.self
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupCLOSEDCAPTIONSValidatorOK() {
        
        let u = EXT_X_STREAM_INFRenditionGroupCLOSEDCAPTIONSValidator.self
        let hlsLoadString = SubtitlesAndCCGroup_txt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupCCValidator_ValueNONE_OK() {
        
        let u = EXT_X_STREAM_INFRenditionGroupCLOSEDCAPTIONSValidator.self
        var SubtitlesGroupTxt = SubtitlesAndCCGroup_txt
        SubtitlesGroupTxt.remove(at: 6)
        SubtitlesGroupTxt.remove(at: 3)
        SubtitlesGroupTxt.insert("\n#EXT-X-STREAM-INF:BANDWIDTH=41457,CODECS=\"mp4a.40.2\",CLOSED-CAPTIONS=NONE,SUBTITLES=\"subs\"\n", at: 5)
        let hlsLoadString = SubtitlesGroupTxt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupCCValidator_MissingEXT_X_MEDIA() {
        
        let u = EXT_X_STREAM_INFRenditionGroupCLOSEDCAPTIONSValidator.self
        var SubtitlesGroupTxt = SubtitlesAndCCGroup_txt
        SubtitlesGroupTxt.remove(at: 3)
        let hlsLoadString = SubtitlesGroupTxt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }
    
    func testEXT_X_STREAM_INFRenditionGroupCCValidator_MissingEXT_X_STREAM_INF() {
        
        let u = EXT_X_STREAM_INFRenditionGroupCLOSEDCAPTIONSValidator.self
        var SubtitlesGroupTxt = SubtitlesAndCCGroup_txt
        SubtitlesGroupTxt.remove(at: 7)
        SubtitlesGroupTxt.remove(at: 6)
        let hlsLoadString = SubtitlesGroupTxt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 0)
    }
    
    func testEXT_X_MEDIARenditionINSTREAMIDValidatorNoINSTREAMID() {
        
        let u = EXT_X_MEDIARenditionINSTREAMIDValidator.self
        var SubtitlesGroupTxt = SubtitlesAndCCGroup_txt
        SubtitlesGroupTxt.remove(at: 3)
        SubtitlesGroupTxt.append("\n#EXT-X-MEDIA:TYPE=CLOSED-CAPTIONS,GROUP-ID=\"cc1\",LANGUAGE=\"en\",NAME=\"English\",AUTOSELECT=YES,DEFAULT=YES\n")
        let hlsLoadString = SubtitlesGroupTxt.joined()
        validate(validator: u, playlist: hlsLoadString, expected: 1)
    }

}
