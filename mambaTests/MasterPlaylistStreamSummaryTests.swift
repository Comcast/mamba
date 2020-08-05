//
//  MasterPlaylistStreamSummaryTests.swift
//  mamba
//
//  Created by David Coufal on 6/12/19.
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
import mamba

class MasterPlaylistStreamSummaryTests: XCTestCase {
    
    func testDemuxedMaster() {
        let master = parseMasterPlaylist(inString: demuxedMasterSample)
        
        let result = master.calculateStreamSummary()
        let summary: PlaylistStreamSummary
        switch result {
        case .success(let summ):
            summary = summ
        case .failure(let error):
            XCTFail("calculateStreamSummary Failed with error \(error)")
            return
        }
        
        var iFrameCount = 0
        var audioCount = 0
        var streamInfCount = 0
        
        for stream in summary.streams {
            switch stream {
            case .iFrameStream(let iFrameStreamInfIndex, let uri):
                iFrameCount += 1
                
                switch iFrameStreamInfIndex {
                case 17:
                    XCTAssertEqual(uri, "iframe-180p-video-low.m3u8")
                    break
                case 18:
                    XCTAssertEqual(uri, "iframe-180p-video-high.m3u8")
                    break
                case 19:
                    XCTAssertEqual(uri, "iframe-288p-video.m3u8")
                    break
                case 20:
                    XCTAssertEqual(uri, "iframe-360p-video.m3u8")
                    break
                case 21:
                    XCTAssertEqual(uri, "iframe-432p-video.m3u8")
                    break
                case 22:
                    XCTAssertEqual(uri, "iframe-720p-video-low.m3u8")
                    break
                case 23:
                    XCTAssertEqual(uri, "iframe-720p-video-high.m3u8")
                    break
                default:
                    XCTFail("Unexpected iFrameStreamInfIndex: \(iFrameStreamInfIndex)")
                }
                break
            case .audioMediaStream(let mediaIndex, let uri, let groupId, let name, let language, let associatedLanguage):
                audioCount += 1
                
                switch mediaIndex {
                case 1:
                    XCTAssertEqual(groupId, "low")
                    XCTAssertEqual(name, "English")
                    XCTAssertEqual(language, "en")
                    XCTAssertEqual(associatedLanguage, nil)
                    XCTAssertEqual(uri, "low-bandwidth-audio.m3u8")
                    break
                case 2:
                    XCTAssertEqual(groupId, "high")
                    XCTAssertEqual(name, "English")
                    XCTAssertEqual(language, "en")
                    XCTAssertEqual(associatedLanguage, nil)
                    XCTAssertEqual(uri, "high-bandwidth-audio.m3u8")
                    break
                default:
                    XCTFail("Unexpected mediaIndex: \(mediaIndex)")
                }
                break
            case .videoMediaStream(_, _, _, _, _, _):
                XCTFail("Unexpected video stream")
            case .subtitlesMediaStream(_, _, _):
                XCTFail("Unexpected subtitles stream")
            case .stream(let streamInfIndex, let locationIndex, let uri, let audioGroupId, let videoGroupId, let captionsGroupId, let streamType, let bandwidth, let resolution):
                streamInfCount += 1
                
                XCTAssertEqual(streamInfIndex + 1, locationIndex)
                
                switch streamInfIndex {
                case 3:
                    XCTAssertEqual(audioGroupId, "low")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 464000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 320, height: 180))
                    XCTAssertEqual(uri, "180p-video-low.m3u8")
                    break
                case 5:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 664400)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 320, height: 180))
                    XCTAssertEqual(uri, "180p-video-high.m3u8")
                    break
                case 7:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 1242000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 512, height: 288))
                    XCTAssertEqual(uri, "288p-video.m3u8")
                    break
                case 9:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 1767200)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 640, height: 360))
                    XCTAssertEqual(uri, "360p-video.m3u8")
                    break
                case 11:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 2082000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 768, height: 432))
                    XCTAssertEqual(uri, "432p-video.m3u8")
                    break
                case 13:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 2292000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 1280, height: 720))
                    XCTAssertEqual(uri, "720p-video-low.m3u8")
                    break
                case 15:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 3922400)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 1280, height: 720))
                    XCTAssertEqual(uri, "720p-video-high.m3u8")
                    break
                default:
                    XCTFail("Unexpected streamInfIndex: \(streamInfIndex)")
                }
            }
        }
        
        XCTAssertEqual(iFrameCount, 7)
        XCTAssertEqual(audioCount, 2)
        XCTAssertEqual(streamInfCount, 7)
        
        XCTAssertTrue(summary.muxedStatus.contains(.containsDemuxedAudio))
        XCTAssertTrue(summary.muxedStatus.contains(.containsDemuxedVideo))
        XCTAssertFalse(summary.muxedStatus.contains(.containsMuxedAudioVideo))
    }
    
    func testMuxedMasterWithSAP() {
        let master = parseMasterPlaylist(inString: muxedMasterSampleWithSAP)
        
        let result = master.calculateStreamSummary()
        let summary: PlaylistStreamSummary
        switch result {
        case .success(let summ):
            summary = summ
        case .failure(let error):
            XCTFail("calculateStreamSummary Failed with error \(error)")
            return
        }
        
        var iFrameCount = 0
        var audioCount = 0
        var streamInfCount = 0
        
        for stream in summary.streams {
            switch stream {
            case .iFrameStream(let iFrameStreamInfIndex, let uri):
                iFrameCount += 1
                
                switch iFrameStreamInfIndex {
                case 20:
                    XCTAssertEqual(uri, "iframe-180p-video-low.m3u8")
                    break
                case 21:
                    XCTAssertEqual(uri, "iframe-180p-video-high.m3u8")
                    break
                case 22:
                    XCTAssertEqual(uri, "iframe-288p-video.m3u8")
                    break
                case 23:
                    XCTAssertEqual(uri, "iframe-360p-video.m3u8")
                    break
                case 24:
                    XCTAssertEqual(uri, "iframe-432p-video.m3u8")
                    break
                case 25:
                    XCTAssertEqual(uri, "iframe-720p-video-low.m3u8")
                    break
                case 26:
                    XCTAssertEqual(uri, "iframe-720p-video-high.m3u8")
                    break
                default:
                    XCTFail("Unexpected iFrameStreamInfIndex: \(iFrameStreamInfIndex)")
                }
            case .audioMediaStream(let mediaIndex, let uri, let groupId, let name, let language, let associatedLanguage):
                audioCount += 1
                
                switch mediaIndex {
                case 2:
                    XCTAssertEqual(groupId, "low")
                    XCTAssertEqual(name, "Spanish")
                    XCTAssertEqual(language, "es")
                    XCTAssertEqual(associatedLanguage, nil)
                    XCTAssertEqual(uri, "low-bandwidth-es-audio.m3u8")
                    break
                case 3:
                    XCTAssertEqual(groupId, "high")
                    XCTAssertEqual(name, "Spanish")
                    XCTAssertEqual(language, "es")
                    XCTAssertEqual(associatedLanguage, nil)
                    XCTAssertEqual(uri, "high-bandwidth-es-audio.m3u8")
                    break
                default:
                    XCTFail("Unexpected mediaIndex: \(mediaIndex)")
                }
            case .videoMediaStream(_, _, _, _, _, _):
                XCTFail("Unexpected video stream")
            case .subtitlesMediaStream(_, _, _):
                XCTFail("Unexpected subtitles stream")
            case .stream(let streamInfIndex, let locationIndex, let uri, let audioGroupId, let videoGroupId, let captionsGroupId, let streamType, let bandwidth, let resolution):
                streamInfCount += 1
                
                XCTAssertEqual(streamInfIndex + 1, locationIndex)
                
                switch streamInfIndex {
                case 4:
                    XCTAssertEqual(audioGroupId, "low")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 560400)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 320, height: 180))
                    XCTAssertEqual(uri, "180p-muxed-low.m3u8")
                    break
                case 6:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 788800)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 320, height: 180))
                    XCTAssertEqual(uri, "180p-muxed-high.m3u8")
                    break
                case 8:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 1072000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 512, height: 288))
                    XCTAssertEqual(uri, "288p-muxed.m3u8")
                    break
                case 10:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 1426400)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 640, height: 360))
                    XCTAssertEqual(uri, "360p-muxed.m3u8")
                    break
                case 12:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 2064400)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 768, height: 432))
                    XCTAssertEqual(uri, "432p-muxed.m3u8")
                    break
                case 14:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 3190400)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 1280, height: 720))
                    XCTAssertEqual(uri, "720p-muxed-low.m3u8")
                    break
                case 16:
                    XCTAssertEqual(audioGroupId, "high")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 4529600)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 1280, height: 720))
                    XCTAssertEqual(uri, "720p-muxed-high.m3u8")
                    break
                case 18:
                    XCTAssertEqual(audioGroupId, "low")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.demuxedAudio)
                    XCTAssertEqual(bandwidth, 104000)
                    XCTAssertEqual(resolution, nil)
                    XCTAssertEqual(uri, "low-bandwidth-audio.m3u8")
                    break
                default:
                    XCTFail("Unexpected streamInfIndex: \(streamInfIndex)")
                }
            }
        }
        
        XCTAssertEqual(iFrameCount, 7)
        XCTAssertEqual(audioCount, 2)
        XCTAssertEqual(streamInfCount, 8)
        
        XCTAssertTrue(summary.muxedStatus.contains(.containsDemuxedAudio))
        XCTAssertFalse(summary.muxedStatus.contains(.containsDemuxedVideo))
        XCTAssertTrue(summary.muxedStatus.contains(.containsMuxedAudioVideo))
    }
    
    func testLowBandwidthAudioOnlyDemuxedMaster() {
        let master = parseMasterPlaylist(inString: lowBandwidthAudioOnlyDemuxedSample)
        
        let result = master.calculateStreamSummary()
        let summary: PlaylistStreamSummary
        switch result {
        case .success(let summ):
            summary = summ
        case .failure(let error):
            XCTFail("calculateStreamSummary Failed with error \(error)")
            return
        }
        
        var audioCount = 0
        var streamInfCount = 0
        
        for stream in summary.streams {
            switch stream {
            case .iFrameStream(_, _):
                XCTFail("Unexpected iframe stream")
            case .audioMediaStream(let mediaIndex, let uri, let groupId, let name, let language, let associatedLanguage):
                audioCount += 1
                
                switch mediaIndex {
                case 1:
                    XCTAssertEqual(groupId, "audio")
                    XCTAssertEqual(name, "audio 0")
                    XCTAssertEqual(language, nil)
                    XCTAssertEqual(associatedLanguage, nil)
                    XCTAssertEqual(uri, "audio.m3u8")
                    break
                default:
                    XCTFail("Unexpected mediaIndex: \(mediaIndex)")
                }
            case .videoMediaStream(_, _, _, _, _, _):
                XCTFail("Unexpected video stream")
            case .subtitlesMediaStream(_, _, _):
                XCTFail("Unexpected subtitles stream")
            case .stream(let streamInfIndex, let locationIndex, let uri, let audioGroupId, let videoGroupId, let captionsGroupId, let streamType, let bandwidth, let resolution):
                streamInfCount += 1
                
                XCTAssertEqual(streamInfIndex + 1, locationIndex)
                
                switch streamInfIndex {
                case 2:
                    XCTAssertEqual(audioGroupId, "audio")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, "NONE")
                    XCTAssertEqual(streamType, StreamType.demuxedAudio)
                    XCTAssertEqual(bandwidth, 104000)
                    XCTAssertEqual(resolution, nil)
                    XCTAssertEqual(uri, "audio.m3u8")
                    break
                case 4:
                    XCTAssertEqual(audioGroupId, "audio")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, "NONE")
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 312000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 320, height: 180))
                    XCTAssertEqual(uri, "180p-video-low.m3u8")
                    break
                case 6:
                    XCTAssertEqual(audioGroupId, "audio")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, "NONE")
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 416000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 320, height: 180))
                    XCTAssertEqual(uri, "180p-video-high.m3u8")
                    break
                case 8:
                    XCTAssertEqual(audioGroupId, "audio")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, "NONE")
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 620000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 512, height: 288))
                    XCTAssertEqual(uri, "288p-video.m3u8")
                    break
                case 10:
                    XCTAssertEqual(audioGroupId, "audio")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, "NONE")
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 874000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 640, height: 360))
                    XCTAssertEqual(uri, "360p-video.m3u8")
                    break
                case 12:
                    XCTAssertEqual(audioGroupId, "audio")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, "NONE")
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 1378000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 768, height: 432))
                    XCTAssertEqual(uri, "432p-video.m3u8")
                    break
                case 14:
                    XCTAssertEqual(audioGroupId, "audio")
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, "NONE")
                    XCTAssertEqual(streamType, StreamType.demuxedVideo)
                    XCTAssertEqual(bandwidth, 2230000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 1280, height: 720))
                    XCTAssertEqual(uri, "720p-video.m3u8")
                    break
                default:
                    XCTFail("Unexpected streamInfIndex: \(streamInfIndex)")
                }
            }
        }
        
        
        XCTAssertEqual(audioCount, 1)
        XCTAssertEqual(streamInfCount, 7)
        
        XCTAssertTrue(summary.muxedStatus.contains(.containsDemuxedAudio))
        XCTAssertTrue(summary.muxedStatus.contains(.containsDemuxedVideo))
        XCTAssertFalse(summary.muxedStatus.contains(.containsMuxedAudioVideo))
    }
    
    func testAltVideoAltSubtitlesMuxed() {
        let master = parseMasterPlaylist(inString: altVideoAltSubtitlesMuxedSample)
        
        let result = master.calculateStreamSummary()
        let summary: PlaylistStreamSummary
        switch result {
        case .success(let summ):
            summary = summ
        case .failure(let error):
            XCTFail("calculateStreamSummary Failed with error \(error)")
            return
        }
        
        var videoCount = 0
        var subtitlesCount = 0
        var streamInfCount = 0
        
        for stream in summary.streams {
            switch stream {
            case .iFrameStream(_, _):
                XCTFail("Unexpected iframe stream")
            case .audioMediaStream(_, _, _, _, _, _):
                XCTFail("Unexpected audio stream")
            case .videoMediaStream(let mediaIndex, let uri, let groupId, let name, let language, let associatedLanguage):
                videoCount += 1
                
                switch mediaIndex {
                case 1:
                    XCTAssertEqual(groupId, "video")
                    XCTAssertEqual(name, "alt video")
                    XCTAssertEqual(language, nil)
                    XCTAssertEqual(associatedLanguage, nil)
                    XCTAssertEqual(uri, "alt_video.m3u8")
                    break
                default:
                    XCTFail("Unexpected mediaIndex: \(mediaIndex)")
                }
            case .subtitlesMediaStream(let mediaIndex, let uri, let groupId):
                subtitlesCount += 1
                
                switch mediaIndex {
                case 3:
                    XCTAssertEqual(groupId, "subs")
                    XCTAssertEqual(uri, "subtitles.subs")
                    break
                default:
                    XCTFail("Unexpected mediaIndex: \(mediaIndex)")
                }
            case .stream(let streamInfIndex, let locationIndex, let uri, let audioGroupId, let videoGroupId, let captionsGroupId, let streamType, let bandwidth, let resolution):
                streamInfCount += 1
                
                XCTAssertEqual(streamInfIndex + 1, locationIndex)
                
                switch streamInfIndex {
                case 4:
                    XCTAssertEqual(audioGroupId, nil)
                    XCTAssertEqual(videoGroupId, "video")
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 500000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 512, height: 288))
                    XCTAssertEqual(uri, "288p-muxed.m3u8")
                    break
                case 6:
                    XCTAssertEqual(audioGroupId, nil)
                    XCTAssertEqual(videoGroupId, "video")
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 1300000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 768, height: 432))
                    XCTAssertEqual(uri, "432p-muxed.m3u8")
                    break
                case 8:
                    XCTAssertEqual(audioGroupId, nil)
                    XCTAssertEqual(videoGroupId, "video")
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 2200000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 1280, height: 720))
                    XCTAssertEqual(uri, "720p-muxed.m3u8")
                    break
                default:
                    XCTFail("Unexpected streamInfIndex: \(streamInfIndex)")
                }
            }
        }
        
        XCTAssertEqual(videoCount, 1)
        XCTAssertEqual(subtitlesCount, 1)
        XCTAssertEqual(streamInfCount, 3)
        
        XCTAssertFalse(summary.muxedStatus.contains(.containsDemuxedAudio))
        XCTAssertTrue(summary.muxedStatus.contains(.containsDemuxedVideo))
        XCTAssertTrue(summary.muxedStatus.contains(.containsMuxedAudioVideo))
    }
    
    func testMuxed() {
        let master = parseMasterPlaylist(inString: muxedSample)
        
        let result = master.calculateStreamSummary()
        let summary: PlaylistStreamSummary
        switch result {
        case .success(let summ):
            summary = summ
        case .failure(let error):
            XCTFail("calculateStreamSummary Failed with error \(error)")
            return
        }
        
        var streamInfCount = 0
        
        for stream in summary.streams {
            switch stream {
            case .iFrameStream(_, _):
                XCTFail("Unexpected iframe stream")
            case .audioMediaStream(_, _, _, _, _, _):
                XCTFail("Unexpected audio stream")
            case .videoMediaStream(_, _, _, _, _, _):
                XCTFail("Unexpected video stream")
            case .subtitlesMediaStream(_, _, _):
                XCTFail("Unexpected subtitles stream")
            case .stream(let streamInfIndex, let locationIndex, let uri, let audioGroupId, let videoGroupId, let captionsGroupId, let streamType, let bandwidth, let resolution):
                streamInfCount += 1
                
                XCTAssertEqual(streamInfIndex + 1, locationIndex)
                
                switch streamInfIndex {
                case 0:
                    XCTAssertEqual(audioGroupId, nil)
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 500000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 512, height: 288))
                    XCTAssertEqual(uri, "288p-muxed.m3u8")
                    break
                case 2:
                    XCTAssertEqual(audioGroupId, nil)
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 1300000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 768, height: 432))
                    XCTAssertEqual(uri, "432p-muxed.m3u8")
                    break
                case 4:
                    XCTAssertEqual(audioGroupId, nil)
                    XCTAssertEqual(videoGroupId, nil)
                    XCTAssertEqual(captionsGroupId, nil)
                    XCTAssertEqual(streamType, StreamType.muxed)
                    XCTAssertEqual(bandwidth, 2200000)
                    XCTAssertEqual(resolution, ResolutionValueType(width: 1280, height: 720))
                    XCTAssertEqual(uri, "720p-muxed.m3u8")
                    break
                default:
                    XCTFail("Unexpected streamInfIndex: \(streamInfIndex)")
                }
            }
        }
        
        XCTAssertEqual(streamInfCount, 3)
        
        XCTAssertFalse(summary.muxedStatus.contains(.containsDemuxedAudio))
        XCTAssertFalse(summary.muxedStatus.contains(.containsDemuxedVideo))
        XCTAssertTrue(summary.muxedStatus.contains(.containsMuxedAudioVideo))
    }
    
    func testErrors() {
        let master = parseMasterPlaylist(inString: brokenSample)
        
        let result = master.calculateStreamSummary()
        switch result {
        case .success(_):
            XCTFail("Not expecting a success")
        case .failure(let error):
            switch error {
            case .invalidMasterPlaylistError(let errorText):
                XCTAssert(errorText.contains("Location") && errorText.contains("streamInf"), "Expecting this error to be about location tags")
            case .internalIndexError:
                XCTFail("Not expecting this error")
            }
            return
        }
    }
    
}

fileprivate let demuxedMasterSample = """
#EXTM3U
#EXT-X-VERSION:7
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="low",NAME="English",LANGUAGE="en",URI="low-bandwidth-audio.m3u8",DEFAULT=YES,AUTOSELECT=YES
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="high",NAME="English",LANGUAGE="en",URI="high-bandwidth-audio.m3u8",DEFAULT=YES,AUTOSELECT=YES

#EXT-X-STREAM-INF:BANDWIDTH=464000,AUDIO="low",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=320x180
180p-video-low.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=664400,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=320x180
180p-video-high.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1242000,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=512x288
288p-video.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1767200,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=640x360
360p-video.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2082000,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=768x432
432p-video.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2292000,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.640029,mp4a.40.5",RESOLUTION=1280x720
720p-video-low.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=3922400,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.640029,mp4a.40.5",RESOLUTION=1280x720
720p-video-high.m3u8

#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=360000,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=320x180,URI="iframe-180p-video-low.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=517200,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=320x180,URI="iframe-180p-video-high.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=1094800,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=512x288,URI="iframe-288p-video.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=1620000,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=640x360,URI="iframe-360p-video.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=1934800,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=768x432,URI="iframe-432p-video.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=2144800,PROGRAM-ID=1,CODECS="avc1.640029",RESOLUTION=1280x720,URI="iframe-720p-video-low.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=3775200,PROGRAM-ID=1,CODECS="avc1.640029",RESOLUTION=1280x720,URI="iframe-720p-video-high.m3u8"
"""

fileprivate let muxedMasterSampleWithSAP = """
#EXTM3U
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="low",NAME="English",LANGUAGE="en",DEFAULT=YES,AUTOSELECT=YES
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="high",NAME="English",LANGUAGE="en",DEFAULT=YES,AUTOSELECT=YES
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="low",NAME="Spanish",LANGUAGE="es",URI="low-bandwidth-es-audio.m3u8"
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="high",NAME="Spanish",LANGUAGE="es",URI="high-bandwidth-es-audio.m3u8"

#EXT-X-STREAM-INF:BANDWIDTH=560400,AUDIO="low",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=320x180
180p-muxed-low.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=788800,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=320x180
180p-muxed-high.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1072000,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=512x288
288p-muxed.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1426400,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=640x360
360p-muxed.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2064400,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=768x432
432p-muxed.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=3190400,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.4d4020,mp4a.40.5",RESOLUTION=1280x720
720p-muxed-low.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=4529600,AUDIO="high",PROGRAM-ID=1,CODECS="avc1.640029,mp4a.40.5",RESOLUTION=1280x720
720p-muxed-high.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=104000,AUDIO="low",PROGRAM-ID=1,CODECS="mp4a.40.5"
low-bandwidth-audio.m3u8

#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=360000,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=320x180,URI="iframe-180p-video-low.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=517200,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=320x180,URI="iframe-180p-video-high.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=1094800,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=512x288,URI="iframe-288p-video.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=1620000,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=640x360,URI="iframe-360p-video.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=1934800,PROGRAM-ID=1,CODECS="avc1.4d401f",RESOLUTION=768x432,URI="iframe-432p-video.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=2144800,PROGRAM-ID=1,CODECS="avc1.640029",RESOLUTION=1280x720,URI="iframe-720p-video-low.m3u8"
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=3775200,PROGRAM-ID=1,CODECS="avc1.640029",RESOLUTION=1280x720,URI="iframe-720p-video-high.m3u8"
"""

/// This kind of stream is a little exotic (check out the first #EXT-X-STREAM-INF stream and the #EXT-X-MEDIA stream, they are the same!).
/// But it plays so we should handle it.
fileprivate let lowBandwidthAudioOnlyDemuxedSample = """
#EXTM3U
#EXT-X-VERSION:7
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="audio 0",AUTOSELECT=YES,DEFAULT=YES,URI="audio.m3u8"

#EXT-X-STREAM-INF:BANDWIDTH=104000,AVERAGE-BANDWIDTH=99000,CLOSED-CAPTIONS=NONE,CODECS="mp4a.40.2",AUDIO="audio"
audio.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=312000,AVERAGE-BANDWIDTH=264000,RESOLUTION=320x180,CLOSED-CAPTIONS=NONE,CODECS="avc1.4d401f,mp4a.40.2",AUDIO="audio"
180p-video-low.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=416000,AVERAGE-BANDWIDTH=339000,RESOLUTION=320x180,CLOSED-CAPTIONS=NONE,CODECS="avc1.4d401f,mp4a.40.2",AUDIO="audio"
180p-video-high.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=620000,AVERAGE-BANDWIDTH=500000,RESOLUTION=512x288,CLOSED-CAPTIONS=NONE,CODECS="avc1.4d401f,mp4a.40.2",AUDIO="audio"
288p-video.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=874000,AVERAGE-BANDWIDTH=692000,RESOLUTION=640x360,CLOSED-CAPTIONS=NONE,CODECS="avc1.4d401f,mp4a.40.2",AUDIO="audio"
360p-video.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1378000,AVERAGE-BANDWIDTH=1030000,RESOLUTION=768x432,CLOSED-CAPTIONS=NONE,CODECS="avc1.4d401f,mp4a.40.2",AUDIO="audio"
432p-video.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2230000,AVERAGE-BANDWIDTH=1682000,RESOLUTION=1280x720,CLOSED-CAPTIONS=NONE,CODECS="avc1.4d401f,mp4a.40.2",AUDIO="audio"
720p-video.m3u8
"""

fileprivate let altVideoAltSubtitlesMuxedSample = """
#EXTM3U
#EXT-X-VERSION:7
#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="video",NAME="alt video",URI="alt_video.m3u8"
#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="video",NAME="video"
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="english subtitles",LANGUAGE="en",ASSOC-LANGUAGE="en-US",URI="subtitles.subs"

#EXT-X-STREAM-INF:BANDWIDTH=500000,RESOLUTION=512x288,CODECS="avc1.4d401f,mp4a.40.2",VIDEO="video",SUBTITLES="subs"
288p-muxed.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1300000,RESOLUTION=768x432,CODECS="avc1.4d401f,mp4a.40.2",VIDEO="video",SUBTITLES="subs"
432p-muxed.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2200000,RESOLUTION=1280x720,CODECS="avc1.4d401f,mp4a.40.2",VIDEO="video",SUBTITLES="subs"
720p-muxed.m3u8
"""

fileprivate let muxedSample = """
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=500000,RESOLUTION=512x288,CODECS="avc1.4d401f,mp4a.40.2"
288p-muxed.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1300000,RESOLUTION=768x432,CODECS="avc1.4d401f,mp4a.40.2"
432p-muxed.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2200000,RESOLUTION=1280x720,CODECS="avc1.4d401f,mp4a.40.2"
720p-muxed.m3u8
"""

fileprivate let brokenSample = """
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=500000,RESOLUTION=512x288,CODECS="avc1.4d401f,mp4a.40.2"
# Missing a location tag here!
#EXT-X-STREAM-INF:BANDWIDTH=1300000,RESOLUTION=768x432,CODECS="avc1.4d401f,mp4a.40.2"
432p-muxed.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2200000,RESOLUTION=1280x720,CODECS="avc1.4d401f,mp4a.40.2"
720p-muxed.m3u8
"""
