//
//  PlaylistTests.swift
//  mamba
//
//  Created by David Coufal on 3/14/19.
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

class PlaylistTests: XCTestCase {
    
    func testInit() {
        let tags = [HLSTag]()
        let url = URL(string:"http://test.server")!
        let registeredTags = RegisteredHLSTags()
        let data = Data()
        
        let variant1 = VariantPlaylist(url: url, tags: tags, registeredTags: registeredTags, playlistData: data)
        let master1 = MasterPlaylist(url: url, tags: tags, registeredTags: registeredTags, playlistData: data)

        XCTAssert(variant1.url == url, "Expecting the url to match")
        XCTAssert(variant1.tags.count == tags.count, "Expecting the tags to match")
        XCTAssert(variant1.playlistData == data, "Expecting the hls data to match")
        XCTAssert(master1.url == url, "Expecting the url to match")
        XCTAssert(master1.tags.count == tags.count, "Expecting the tags to match")
        XCTAssert(master1.playlistData == data, "Expecting the hls data to match")

        let variant2 = VariantPlaylist(playlist: variant1)
        let master2 = MasterPlaylist(playlist: master1)

        XCTAssert(variant2.url == variant1.url, "Expecting the url to match")
        XCTAssert(variant2.tags.count == variant1.tags.count, "Expecting the tags to match")
        XCTAssert(variant2.playlistData == variant1.playlistData, "Expecting the hls data to match")
        XCTAssert(master2.url == master1.url, "Expecting the url to match")
        XCTAssert(master2.tags.count == master1.tags.count, "Expecting the tags to match")
        XCTAssert(master2.playlistData == master1.playlistData, "Expecting the hls data to match")
    }
    
    func testUrlChange() {
        let tags = [HLSTag]()
        let url1 = URL(string:"http://test.server1")!
        let url2 = URL(string:"http://test.server2")!
        let registeredTags = RegisteredHLSTags()
        let data = Data()
        
        var playlist = VariantPlaylist(url: url1, tags: tags, registeredTags: registeredTags, playlistData: data)
        playlist.url = url2
        
        XCTAssert(playlist.url == url2, "Expecting the url to change")
    }
    
    func testDebugDescription() {
        let urlString = "http://test.server"
        let url = URL(string: urlString)!
        var playlist = parseVariantPlaylist(inString: "#EXTM3U\n#EXT-X-TARGETDURATION:2\n#EXTINF:2.002,\nhttp://not.a.server.nowhere/segment1.ts")
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
        let playlist = parseVariantPlaylist(inString: playlistString)
        do {
            let data = try playlist.write()
            let roundTripString = String(data: data, encoding: .utf8)
            let roundTripPlaylist = parseVariantPlaylist(inString: roundTripString!)
            
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
