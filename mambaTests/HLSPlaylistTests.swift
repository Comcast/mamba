//
//  HLSPlaylistTests.swift
//  mamba
//
//  Created by David Coufal on 9/28/17.
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

class HLSPlaylistTests: XCTestCase {
    
    func testInit() {
        let tags = [HLSTag]()
        let url = URL(string:"http://test.server")!
        let registeredTags = RegisteredHLSTags()
        let buffer = StaticMemoryStorage()
        
        let playlist1 = HLSPlaylist(url: url, tags: tags, registeredTags: registeredTags, hlsBuffer: buffer)
        
        XCTAssert(playlist1.url == url, "Expecting the url to match")
        XCTAssert(playlist1.tags.count == tags.count, "Expecting the tags to match")
        XCTAssert(playlist1.hlsBuffer == buffer, "Expecting the hls data to match")
        
        let playlist2 = HLSPlaylist(playlist: playlist1)

        XCTAssert(playlist1.url == playlist2.url, "Expecting the url to match")
        XCTAssert(playlist1.tags.count == playlist2.tags.count, "Expecting the tags to match")
        XCTAssert(playlist1.hlsBuffer == playlist2.hlsBuffer, "Expecting the hls data to match")
    }
    
    func testUrlChange() {
        let tags = [HLSTag]()
        let url1 = URL(string:"http://test.server1")!
        let url2 = URL(string:"http://test.server2")!
        let registeredTags = RegisteredHLSTags()
        let buffer = StaticMemoryStorage()

        var playlist = HLSPlaylist(url: url1, tags: tags, registeredTags: registeredTags, hlsBuffer: buffer)
        playlist.url = url2
        
        XCTAssert(playlist.url == url2, "Expecting the url to change")
    }
    
    func testDebugDescription() {
        let urlString = "http://test.server"
        let url = URL(string: urlString)!
        var playlist = parsePlaylist(inString: "# Just a comment")
        playlist.url = url
        
        let desc = playlist.debugDescription
        
        XCTAssert(desc.contains(urlString), "Expecting the url string in the debug output")
    }
    
    func testWrite() {
        let playlistString = """
#EXTM3U\n
#EXT-X-VERSION:4\n
#EXT-X-PLAYLIST-TYPE:VOD\n
#EXT-X-TARGETDURATION:2\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/segment1.ts\n
#EXTINF:1.0,\n
#EXT-X-DISCONTINUITY\n
http://not.a.server.nowhere/segment2.ts\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/segment3.ts\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/segment4.ts\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/segment5.ts\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/segment6.ts\n
#EXT-X-ENDLIST\n
"""
        let playlist = parsePlaylist(inString: playlistString)
        do {
            let data = try playlist.write()
            let roundTripString = String(data: data, encoding: .utf8)
            let roundTripPlaylist = parsePlaylist(inString: roundTripString!)
            
            for index in 0..<playlist.tags.count {
                // nb: we are doing index + 1 in the roundTripPlaylist because mamba inserts a comment indicating mamba is the origin as first tag
                XCTAssertEqual(roundTripPlaylist.tags[index + 1], playlist.tags[index])
            }
        }
        catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
        
}
