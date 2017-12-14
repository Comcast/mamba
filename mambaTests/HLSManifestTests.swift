//
//  HLSManifestTests.swift
//  mamba
//
//  Created by David Coufal on 9/28/17.
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
@testable import mamba

class HLSManifestTests: XCTestCase {
    
    func testInit() {
        let tags = [HLSTag]()
        let url = URL(string:"http://test.server")!
        let registeredTags = RegisteredHLSTags()
        let data = Data()
        
        let manifest1 = HLSManifest(url: url, tags: tags, registeredTags: registeredTags, hlsData: data)
        
        XCTAssert(manifest1.url == url, "Expecting the url to match")
        XCTAssert(manifest1.tags.count == tags.count, "Expecting the tags to match")
        XCTAssert(manifest1.hlsData == data, "Expecting the hls data to match")
        
        let manifest2 = HLSManifest(manifest: manifest1)

        XCTAssert(manifest1.url == manifest2.url, "Expecting the url to match")
        XCTAssert(manifest1.tags.count == manifest2.tags.count, "Expecting the tags to match")
        XCTAssert(manifest1.hlsData == manifest2.hlsData, "Expecting the hls data to match")
    }
    
    func testUrlChange() {
        let tags = [HLSTag]()
        let url1 = URL(string:"http://test.server1")!
        let url2 = URL(string:"http://test.server2")!
        let registeredTags = RegisteredHLSTags()
        let data = Data()
        
        var manifest = HLSManifest(url: url1, tags: tags, registeredTags: registeredTags, hlsData: data)
        manifest.url = url2
        
        XCTAssert(manifest.url == url2, "Expecting the url to change")
    }
    
    func testDebugDescription() {
        let urlString = "http://test.server"
        let url = URL(string: urlString)!
        var manifest = parseManifest(inString: "# Just a comment")
        manifest.url = url
        
        let desc = manifest.debugDescription
        
        XCTAssert(desc.contains(urlString), "Expecting the url string in the debug output")
    }
    
    func testWrite() {
        let manifestString = """
#EXTM3U\n
#EXT-X-VERSION:4\n
#EXT-X-PLAYLIST-TYPE:VOD\n
#EXT-X-TARGETDURATION:2\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/fragment1.ts\n
#EXTINF:1.0,\n
#EXT-X-DISCONTINUITY\n
http://not.a.server.nowhere/fragment2.ts\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/fragment3.ts\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/fragment4.ts\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/fragment5.ts\n
#EXTINF:2.002,\n
http://not.a.server.nowhere/fragment6.ts\n
#EXT-X-ENDLIST\n
"""
        let manifest = parseManifest(inString: manifestString)
        do {
            let data = try manifest.write()
            let roundTripString = String(data: data, encoding: .utf8)
            let roundTripManifest = parseManifest(inString: roundTripString!)
            
            for index in 0..<manifest.tags.count {
                // nb: we are doing index + 1 in the roundTripManifest because mamba inserts a comment indicating mamba is the origin as first tag
                XCTAssertEqual(roundTripManifest.tags[index + 1], manifest.tags[index])
            }
        }
        catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
        
}
