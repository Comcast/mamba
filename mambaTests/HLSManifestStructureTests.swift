//
//  HLSManifestStructureTests.swift
//  mamba
//
//  Created by David Coufal on 4/14/17.
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

/*
 We do most of our testing for HLSManifestStructure in HLSManifest tests.
 
 This is to test some edge cases that are impossible to test through HLSManifest.
 */
class HLSManifestStructureTests: XCTestCase {
    
    func testDeleteCrossMediaGroupDelete() {
        
        let manifest = parseManifest(inString: sample4FragmentManifest)
        
        let structure = HLSManifestStructure(withTags: manifest.tags)
        
        // sanity check
        XCTAssert(structure.mediaFragmentGroups.count == 4)
        
        // remove 2 tags from the middle of the manifest
        structure.delete(atRange: 6...7)
        
        XCTAssert(structure.mediaFragmentGroups.count == 3)
    }
    
    func testDeleteOutOfFooter() {
        
        let manifest = parseManifest(inString: sampleLargeFooterManifest)
        
        let structure = HLSManifestStructure(withTags: manifest.tags)
        
        // sanity check
        XCTAssert(structure.footer!.range.count == 3)
        
        // remove 1 tags from the footer
        structure.delete(atIndex: 6)
        
        XCTAssert(structure.footer!.range.count == 2)
    }
    
    func testDeleteEntireFooter() {
        
        let manifest = parseManifest(inString: sampleLargeFooterManifest)
        
        let structure = HLSManifestStructure(withTags: manifest.tags)
        
        // sanity check
        XCTAssert(structure.footer!.range.count == 3)
        
        // remove 3 tags from the footer
        structure.delete(atRange: 5...7)
        
        XCTAssert(structure.footer == nil)
    }
    
    func testEmptyManifest() {
        
        let manifest = parseManifest(inString: "#EXTM3U")
        
        let structure = HLSManifestStructure(withTags: manifest.tags)
        
        XCTAssertNil(structure.footer)
        XCTAssert(structure.mediaFragmentGroups.count == 0)
        XCTAssertNil(structure.header)
    }
}

// unusual/malformed manifest to test footer deletion
let sampleLargeFooterManifest = """
#EXTM3U
#EXT-X-VERSION:4
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-TARGETDURATION:2
#EXTINF:2.002,
http://not.a.server.nowhere/fragment1.ts
#EXT-X-ENDLIST
#EXT-X-ENDLIST
#EXT-X-ENDLIST
"""
