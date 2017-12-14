//
//  HLSManifestStructureAndEditingTests.swift
//  mamba
//
//  Created by David Coufal on 4/10/17.
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
import CoreMedia

@testable import mamba

class HLSManifestStructureAndEditingTests: XCTestCase {
    
    func testHLSWithNoXKeys() {
        let manifest = parseManifest(inString: sampleVariantManifest_NoXKeys)
        
        XCTAssert(manifest.header.range.count == 3, "Expecting 3 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 2)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 17)
        XCTAssert(manifest.footer?.endIndex == 17)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 4)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == true)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 3)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[3].startIndex == 11)
        XCTAssert(manifest.mediaFragmentGroups[3].endIndex == 12)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 15)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 16)
        
        XCTAssert(manifest.mediaSpans.count == 0)
    }
    
    func testHLSWithXKeys() {
        let manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        XCTAssert(manifest.header.range.count == 4, "Expecting 4 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 3)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 20)
        XCTAssert(manifest.footer?.endIndex == 20)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 4)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == true)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 5)
        XCTAssert(manifest.mediaFragmentGroups[3].startIndex == 13)
        XCTAssert(manifest.mediaFragmentGroups[3].endIndex == 15)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 18)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 19)
        
        XCTAssert(manifest.mediaSpans.count == 3)
        XCTAssert(manifest.mediaSpans[0].parentTag == manifest.tags[3])
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(manifest.mediaSpans[1].parentTag == manifest.tags[10])
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(manifest.mediaSpans[2].parentTag == manifest.tags[13])
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.count == 3)
        
        let mediaSpan0Tags = manifest.tags[manifest.mediaSpans[0].tagMediaSpan]
        let mediaSpan1Tags = manifest.tags[manifest.mediaSpans[1].tagMediaSpan]
        let mediaSpan2Tags = manifest.tags[manifest.mediaSpans[2].tagMediaSpan]
        
        XCTAssert(mediaSpan0Tags.count == manifest.mediaSpans[0].tagMediaSpan.count)
        XCTAssert(mediaSpan1Tags.count == manifest.mediaSpans[1].tagMediaSpan.count)
        XCTAssert(mediaSpan2Tags.count == manifest.mediaSpans[2].tagMediaSpan.count)
    }
    
    func testHLSWithMissingEXTINF_MissingFooter() {
        let manifest = parseManifest(inString: sampleVariantManifest_NoFooter)
        
        XCTAssert(manifest.header.range.count == 3)
        XCTAssert(manifest.footer == nil)
        XCTAssert(manifest.mediaFragmentGroups.count == 6)
    }
    
    func testHLSWithMissingEXTINF_CustomMediaSequence() {
        let manifest = parseManifest(inString: sampleVariantManifest_MediaSequenceStartsAt2)

        XCTAssert(manifest.header.range.count == 4)
        XCTAssert(manifest.footer?.range.count == 1)
        XCTAssert(manifest.mediaFragmentGroups.count == 6)
        
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 7)
    }
    
    func testHLSInsertSingleTag() {
        var manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the manifest structure to force a build and set us in the .clean state
        XCTAssert(manifest.mediaFragmentGroups.count > 0)
        
        let tag = HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Just a comment tag"))
        
        manifest.insert(tag: tag, atIndex: 8)
        
        XCTAssert(manifest.header.range.count == 4, "Expecting 4 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 3)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 21)
        XCTAssert(manifest.footer?.endIndex == 21)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 5)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == true)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 5)
        XCTAssert(manifest.mediaFragmentGroups[3].startIndex == 14)
        XCTAssert(manifest.mediaFragmentGroups[3].endIndex == 16)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 19)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 20)
        
        XCTAssert(manifest.mediaSpans.count == 3)
        XCTAssert(manifest.mediaSpans[0].parentTag == manifest.tags[3])
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(manifest.mediaSpans[1].parentTag == manifest.tags[11])
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(manifest.mediaSpans[2].parentTag == manifest.tags[14])
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSInsertMultipleTags() {
        var manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the manifest structure to force a build and set us in the .clean state
        XCTAssert(manifest.mediaFragmentGroups.count > 0)
        
        let tags = [HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Test Comment Number 1")),
                    HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Test Comment Number 2"))]
        
        manifest.insert(tags: tags, atIndex: 8)
        
        XCTAssert(manifest.header.range.count == 4, "Expecting 4 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 3)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 22)
        XCTAssert(manifest.footer?.endIndex == 22)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 6)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == true)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 5)
        XCTAssert(manifest.mediaFragmentGroups[3].startIndex == 15)
        XCTAssert(manifest.mediaFragmentGroups[3].endIndex == 17)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 20)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 21)
        
        XCTAssert(manifest.mediaSpans.count == 3)
        XCTAssert(manifest.mediaSpans[0].parentTag == manifest.tags[3])
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(manifest.mediaSpans[1].parentTag == manifest.tags[12])
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(manifest.mediaSpans[2].parentTag == manifest.tags[15])
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSMulitpleInserts() {
        var manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the manifest structure to force a build and set us in the .clean state
        XCTAssert(manifest.mediaFragmentGroups.count > 0)
        
        let tag1 = HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Test Comment Number 1"))
        let tag2 = HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Test Comment Number 2"))
        
        manifest.insert(tag: tag2, atIndex: 8)
        manifest.insert(tag: tag1, atIndex: 8)
        
        XCTAssert(manifest.header.range.count == 4, "Expecting 4 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 3)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 22)
        XCTAssert(manifest.footer?.endIndex == 22)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 6)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == true)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 5)
        XCTAssert(manifest.mediaFragmentGroups[3].startIndex == 15)
        XCTAssert(manifest.mediaFragmentGroups[3].endIndex == 17)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 20)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 21)
        
        XCTAssert(manifest.mediaSpans.count == 3)
        XCTAssert(manifest.mediaSpans[0].parentTag == manifest.tags[3])
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(manifest.mediaSpans[1].parentTag == manifest.tags[12])
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(manifest.mediaSpans[2].parentTag == manifest.tags[15])
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    
    func testHLSDeleteSingleTag() {
        var manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the manifest structure to force a build and set us in the .clean state
        XCTAssert(manifest.mediaFragmentGroups.count > 0)
        
        manifest.delete(atIndex: 7) // This deletes the DISCONTINUITY tag in sampleVariantManifest_frag1
        
        XCTAssert(manifest.header.range.count == 4, "Expecting 4 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 3)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 19)
        XCTAssert(manifest.footer?.endIndex == 19)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 5)
        XCTAssert(manifest.mediaFragmentGroups[3].startIndex == 12)
        XCTAssert(manifest.mediaFragmentGroups[3].endIndex == 14)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 17)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 18)
        
        XCTAssert(manifest.mediaSpans.count == 3)
        XCTAssert(manifest.mediaSpans[0].parentTag == manifest.tags[3])
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(manifest.mediaSpans[1].parentTag == manifest.tags[9])
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(manifest.mediaSpans[2].parentTag == manifest.tags[12])
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSDeleteSingleTagFromDirtyState() {
        var manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        manifest.delete(atIndex: 7) // This deletes the DISCONTINUITY tag in sampleVariantManifest_frag1
        
        XCTAssert(manifest.header.range.count == 4, "Expecting 4 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 3)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 19)
        XCTAssert(manifest.footer?.endIndex == 19)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 5)
        XCTAssert(manifest.mediaFragmentGroups[3].startIndex == 12)
        XCTAssert(manifest.mediaFragmentGroups[3].endIndex == 14)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 17)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 18)
        
        XCTAssert(manifest.mediaSpans.count == 3)
        XCTAssert(manifest.mediaSpans[0].parentTag == manifest.tags[3])
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(manifest.mediaSpans[1].parentTag == manifest.tags[9])
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(manifest.mediaSpans[2].parentTag == manifest.tags[12])
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSDeleteMultipleTags() {
        var manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the manifest structure to force a build and set us in the .clean state
        XCTAssert(manifest.mediaFragmentGroups.count > 0)
        
        manifest.delete(atRange: 7...8) // This deletes the DISCONTINUITY and BYTERANGE tags in sampleVariantManifest_frag1
        
        XCTAssert(manifest.header.range.count == 4, "Expecting 4 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 3)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 18)
        XCTAssert(manifest.footer?.endIndex == 18)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.start.seconds - 9.008) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[5].timeRange.end.seconds - 11.01) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 5)
        XCTAssert(manifest.mediaFragmentGroups[3].startIndex == 11)
        XCTAssert(manifest.mediaFragmentGroups[3].endIndex == 13)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 16)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 17)
        
        XCTAssert(manifest.mediaSpans.count == 3)
        XCTAssert(manifest.mediaSpans[0].parentTag == manifest.tags[3])
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.upperBound == 1)
        XCTAssert(manifest.mediaSpans[1].parentTag == manifest.tags[8])
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.lowerBound == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.upperBound == 2)
        XCTAssert(manifest.mediaSpans[2].parentTag == manifest.tags[11])
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.lowerBound == 3)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.upperBound == 5)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.count == 2)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func testHLSMultipleDeletes() {
        
        let sampleDeletableComments =
            "#EXTM3U\n" +
                "#EXT-X-VERSION:4\n" +
                "#EXT-X-PLAYLIST-TYPE:VOD\n" +
                "#EXT-X-TARGETDURATION:2\n" +
                "#TestCommentToBeDeleted1\n" +
                "#TestCommentToBeDeleted2\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/fragment1.ts\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/fragment2.ts\n" +
        "#EXT-X-ENDLIST\n"
        
        var manifest = parseManifest(inString: sampleDeletableComments)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the manifest structure to force a build and set us in the .clean state
        XCTAssert(manifest.header.range.count == 5, "Expecting 5 header tags")
        
        // This deletes the comment tags
        manifest.delete(atIndex: 3)
        manifest.delete(atIndex: 3)
        
        XCTAssert(manifest.header.range.count == 3, "Expecting 3 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 2)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 7)
        XCTAssert(manifest.footer?.endIndex == 7)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 2, "Expecting 6 media groups")
    }
    
    func testHLSCrossGroupDelete() {
        
        var manifest = parseManifest(inString: sample4FragmentManifest)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        XCTAssert(manifest.mediaFragmentGroups.count == 4, "Expecting 4 groups")
        
        // This deletes the middle two media groups
        manifest.delete(atRange: 5...8)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 2, "Expecting 2 groups")
    }
    
    func testHLSInsertNewMediaGroups() {
        var manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        // we're not going to test initial conditions as that's tested in `testHLSWithXKeys` above
        
        // access the manifest structure to force a build and set us in the .clean state
        XCTAssert(manifest.mediaFragmentGroups.count > 0)
        
        let extinfTagData = HLSStringRef(string: "2.002")
        let tags = [HLSTag(tagDescriptor: PantosTag.EXTINF, tagData:extinfTagData, tagName: HLSStringRef(string: PantosTag.EXTINF.toString()), duration: extinfTagData.extinfSegmentDuration()),
                    HLSTag(tagDescriptor: PantosTag.Location, tagData:HLSStringRef(string: "http://not-a-real.url/adFragment1.ts")),
                    HLSTag(tagDescriptor: PantosTag.EXTINF, tagData:extinfTagData, tagName: HLSStringRef(string: PantosTag.EXTINF.toString()), duration: extinfTagData.extinfSegmentDuration()),
                    HLSTag(tagDescriptor: PantosTag.Location, tagData:HLSStringRef(string: "http://not-a-real.url/adFragment2.ts"))] // insert two new media groups
        
        manifest.insert(tags: tags, atIndex: 10) // inserting between fragment 2 and 3
        
        XCTAssert(manifest.header.range.count == 4, "Expecting 4 header tags")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 3)
        
        XCTAssert(manifest.footer?.range.count == 1, "Expecting 1 footer tags")
        XCTAssert(manifest.footer?.startIndex == 24)
        XCTAssert(manifest.footer?.endIndex == 24)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 8, "Expecting 8 media groups")
        XCTAssert(manifest.mediaFragmentGroups[0].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[1].range.count == 4)
        XCTAssert(manifest.mediaFragmentGroups[2].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[3].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[4].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[5].range.count == 3)
        XCTAssert(manifest.mediaFragmentGroups[6].range.count == 2)
        XCTAssert(manifest.mediaFragmentGroups[7].range.count == 2)
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[0]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[1]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[2]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[3]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[4]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[5]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[6]), "Found an invalid media fragment group")
        XCTAssertTrue(runTestForMediaGroupValidity(manifest: manifest, mediaGroup: manifest.mediaFragmentGroups[7]), "Found an invalid media fragment group")
        XCTAssert(manifest.mediaFragmentGroups[0].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[1].discontinuity == true)
        XCTAssert(manifest.mediaFragmentGroups[2].discontinuity == false)
        XCTAssert(manifest.mediaFragmentGroups[0].mediaSequence == 0)
        XCTAssert(manifest.mediaFragmentGroups[5].mediaSequence == 5)
        XCTAssert(manifest.mediaFragmentGroups[0].timeRange.start.seconds == 0.0)
        XCTAssert(fabs(manifest.mediaFragmentGroups[0].timeRange.end.seconds - 2.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.start.seconds - 3.002) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[2].timeRange.end.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[3].timeRange.start.seconds - 5.004) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[3].timeRange.end.seconds - 7.006) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[4].timeRange.start.seconds - 7.006) < 0.002)
        XCTAssert(fabs(manifest.mediaFragmentGroups[4].timeRange.end.seconds - 9.008) < 0.002)
        XCTAssert(manifest.mediaFragmentGroups[0].startIndex == 4)
        XCTAssert(manifest.mediaFragmentGroups[0].endIndex == 5)
        XCTAssert(manifest.mediaFragmentGroups[5].startIndex == 17)
        XCTAssert(manifest.mediaFragmentGroups[5].endIndex == 19)
        XCTAssert(manifest.mediaFragmentGroups[7].startIndex == 22)
        XCTAssert(manifest.mediaFragmentGroups[7].endIndex == 23)
        
        XCTAssert(manifest.mediaSpans.count == 3)
        XCTAssert(manifest.mediaSpans[0].parentTag == manifest.tags[3])
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.lowerBound == 0)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.upperBound == 3)
        XCTAssert(manifest.mediaSpans[1].parentTag == manifest.tags[14])
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.lowerBound == 4)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.upperBound == 4)
        XCTAssert(manifest.mediaSpans[2].parentTag == manifest.tags[17])
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.lowerBound == 5)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.upperBound == 7)
        XCTAssert(manifest.mediaSpans[0].tagMediaSpan.count == 4)
        XCTAssert(manifest.mediaSpans[1].tagMediaSpan.count == 1)
        XCTAssert(manifest.mediaSpans[2].tagMediaSpan.count == 3)
    }
    
    func runTestForMediaGroupValidity(manifest: HLSManifest, mediaGroup: MediaFragmentTagGroup) -> Bool {
        let tags = manifest.tags(forMediaGroup: mediaGroup)
        if tags.filter({ $0.tagDescriptor == PantosTag.EXTINF }).count != 1 {
            return false
        }
        if tags.filter({ $0.tagDescriptor == PantosTag.Location }).count != 1 {
            return false
        }
        return true
    }
    
    func testHLS_MissingEXTINF() {
        let manifest = parseManifest(inString: sampleVariantManifest_MissingEXTINF)
        
        XCTAssert(manifest.header.range.count == 9, "Expecting 9 header tags, as structurally-unparsable manifests are treated as 'all header'")
        XCTAssert(manifest.header.startIndex == 0)
        XCTAssert(manifest.header.endIndex == 8)
        
        XCTAssert(manifest.mediaFragmentGroups.count == 0, "Expecting no groups")
        
        XCTAssert(manifest.mediaSpans.count == 0, "Expecting no spans")
        
        XCTAssert(manifest.footer == nil, "Expecting nil footer")
    }
    
    func testHLSMapping() {
        
        let fakeFragment = "http://not-a-real.url/fake_fragment.ts"
        
        var manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        // access the manifest structure to force a build and set us in the .clean state
        XCTAssert(manifest.mediaFragmentGroups.count > 0)
        
        do {
            try manifest.transform({ tag in
                if tag.tagDescriptor == PantosTag.Location {
                    return HLSTag(tagDescriptor: PantosTag.Location, tagData: HLSStringRef(string: fakeFragment))
                }
                return tag
            })
        }
        catch {
            XCTFail("testHLSMapping failed: \(error)")
        }
        
        XCTAssert(manifest.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        let locationTags = manifest.tags.filter { $0.tagDescriptor == PantosTag.Location }
        
        for locationTag in locationTags {
            XCTAssert(locationTag.tagData == fakeFragment, "Expected a changed Location")
        }
    }
    
    func testCopyOnWrite() {
        
        var manifest1 = parseManifest(inString: sampleVariantManifest_XKeys)
        let manifest2 = manifest1
        
        XCTAssert(manifest1.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest2.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest1.mediaFragmentGroups[1].range.count == 4)
        XCTAssert(manifest2.mediaFragmentGroups[1].range.count == 4)
        
        XCTAssert(manifest1.tags.count == manifest2.tags.count, "Expecting same count")
        
        let tag = HLSTag(tagDescriptor: PantosTag.Comment, tagData:HLSStringRef(string: " Just a comment tag"))
        
        manifest1.insert(tag: tag, atIndex: 8)
        
        XCTAssert(manifest1.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest2.mediaFragmentGroups.count == 6, "Expecting 6 media groups")
        XCTAssert(manifest1.mediaFragmentGroups[1].range.count == 5)
        XCTAssert(manifest2.mediaFragmentGroups[1].range.count == 4)
        
        XCTAssert(manifest1.tags.count == manifest2.tags.count + 1, "Expecting an added tag")
    }
    
    func testMediaGroupByObjectAndByIndex() {
        
        let manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        let groupIndex = 1
        
        let group = manifest.mediaFragmentGroups[groupIndex]
        
        let tagsByGroup = Array(manifest.tags(forMediaGroup: group))
        let tagsByIndex = Array(manifest.tags(forMediaGroupIndex: groupIndex))
        
        XCTAssert(tagsByGroup.count == tagsByIndex.count, "Expecting the same tags")
        for (index, _) in tagsByGroup.enumerated() {
            XCTAssert(tagsByGroup[index].tagDescriptor == tagsByIndex[index].tagDescriptor, "Expecting the same tag at index \(index)")
            XCTAssert(tagsByGroup[index].tagData == tagsByIndex[index].tagData, "Expecting the same tag at index \(index)")
        }
    }
    
    func testOutOfRangeMediaGroupAccess() {
        
        let manifest = parseManifest(inString: sampleVariantManifest_XKeys)
        
        let outOfRangeMediaGroupIndex = Int.max
        
        let tagsFromInvalidGroup = Array(manifest.tags(forMediaGroupIndex: outOfRangeMediaGroupIndex))
        
        XCTAssert(tagsFromInvalidGroup.count == 0, "There should be no tags in nonexistant groups")
    }
    
    func testAllHeader() {
        let manifest = parseManifest(inString: sampleVariantManifest_header)
        
        XCTAssert(manifest.header.range.count == 3, "Should have a header")
        XCTAssert(manifest.mediaFragmentGroups.count == 0, "Should have no groups")
        XCTAssert(manifest.footer == nil, "Should have no footer")
        XCTAssert(manifest.mediaSpans.count == 0, "Should have no spans")
    }
    
    func testSpanTagInHeader() {
        
        let sampleSpanInHeader =
            "#EXTM3U\n" +
                "#EXT-X-VERSION:4\n" +
                "#EXT-X-KEY:METHOD=AES-128,URI=\"https://not.a.server.nowhere/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa/\n" +
                "#EXT-X-PLAYLIST-TYPE:VOD\n" +
                "#EXT-X-TARGETDURATION:2\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/fragment1.ts\n" +
                "#EXT-X-KEY:METHOD=NONE\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/fragment2.ts\n" +
        "#EXT-X-ENDLIST\n"
        
        let manifest = parseManifest(inString: sampleSpanInHeader)
        
        XCTAssert(manifest.header.range.count == 4, "Should have a header")
        XCTAssert(manifest.mediaFragmentGroups.count == 2, "Should have 2 groups")
        XCTAssert(manifest.footer?.range.count == 1, "Should have a footer")
        XCTAssert(manifest.mediaSpans.count == 2, "Should have 2 spans")
    }
    
    func testSpanTagInFirstMediaGroup() {
        
        let sampleSpanInHeader =
            "#EXTM3U\n" +
                "#EXT-X-VERSION:4\n" +
                "#EXT-X-PLAYLIST-TYPE:VOD\n" +
                "#EXT-X-TARGETDURATION:2\n" +
                "#EXTINF:2.002,\n" +
                "#EXT-X-KEY:METHOD=AES-128,URI=\"https://not.a.server.nowhere/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa/\n" +
                "http://not.a.server.nowhere/fragment1.ts\n" +
                "#EXT-X-KEY:METHOD=NONE\n" +
                "#EXTINF:2.002,\n" +
                "http://not.a.server.nowhere/fragment2.ts\n" +
        "#EXT-X-ENDLIST\n"
        
        let manifest = parseManifest(inString: sampleSpanInHeader)
        
        XCTAssert(manifest.header.range.count == 3, "Should have a header")
        XCTAssert(manifest.mediaFragmentGroups.count == 2, "Should have 2 groups")
        XCTAssert(manifest.footer?.range.count == 1, "Should have a footer")
        XCTAssert(manifest.mediaSpans.count == 2, "Should have 2 spans")
    }
}


// Calculated HLS fixtures

fileprivate let sampleVariantManifest_NoXKeys =
    sampleVariantManifest_header +
        sampleVariantManifest_frag1 +
        sampleVariantManifest_frag2 +
        sampleVariantManifest_frag3 +
sampleVariantManifest_footer

fileprivate let sampleVariantManifest_XKeys =
    sampleVariantManifest_header +
        sampleVariantManifest_encryption_key +
        sampleVariantManifest_frag1 +
        sampleVariantManifest_clear_key +
        sampleVariantManifest_frag2 +
        sampleVariantManifest_encryption_key +
        sampleVariantManifest_frag3 +
sampleVariantManifest_footer

fileprivate let sampleVariantManifest_NoFooter =
    sampleVariantManifest_header +
        sampleVariantManifest_frag1 +
        sampleVariantManifest_frag2 +
sampleVariantManifest_frag3

fileprivate let sampleVariantManifest_MediaSequenceStartsAt2 =
    sampleVariantManifest_header +
        "#EXT-X-MEDIA-SEQUENCE:2\n" +
        sampleVariantManifest_frag1 +
        sampleVariantManifest_frag2 +
        sampleVariantManifest_frag3 +
sampleVariantManifest_footer

// HLS fragments for above calculated HLS fixtures

fileprivate let hlsStartTag = "#EXTM3U\n"

fileprivate let sampleVariantManifest_header =
    hlsStartTag +
        "#EXT-X-VERSION:4\n" +
        "#EXT-X-PLAYLIST-TYPE:VOD\n" +
"#EXT-X-TARGETDURATION:2\n"

fileprivate let sampleVariantManifest_frag1 =
    "#EXTINF:2.002\n" +
        "http://not.a.server.nowhere/fragment1.ts\n" +
        "#EXTINF:1.0\n" +
        "#EXT-X-DISCONTINUITY\n" +
        "#EXT-X-BYTERANGE:82112@752321\n" +
"http://not.a.server.nowhere/fragment2.ts\n"

fileprivate let sampleVariantManifest_frag2 =
    "#EXTINF:2.002,\n" +
"http://not.a.server.nowhere/fragment3.ts\n"

fileprivate let sampleVariantManifest_frag3 =
    "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/fragment4.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/fragment5.ts\n" +
        "#EXTINF:2.002,\n" +
"http://not.a.server.nowhere/fragment6.ts\n"


fileprivate let sampleVariantManifest_footer =
"#EXT-X-ENDLIST\n"

fileprivate let sampleVariantManifest_encryption_key =
"#EXT-X-KEY:METHOD=AES-128,URI=\"https://not.a.server.nowhere/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa/\n"

fileprivate let sampleVariantManifest_clear_key =
"#EXT-X-KEY:METHOD=NONE\n"


// Standalone test HLS fixtures

fileprivate let sampleVariantManifest_MissingEXTINF =
    "#EXTM3U\n" +
        "#EXT-X-VERSION:4\n" +
        "#EXT-X-PLAYLIST-TYPE:VOD\n" +
        "#EXT-X-TARGETDURATION:2\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/fragment4.ts\n" +
        "http://not.a.server.nowhere/fragment5.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/fragment6.ts\n" +
"#EXT-X-ENDLIST\n"

let sample4FragmentManifest =
    "#EXTM3U\n" +
        "#EXT-X-VERSION:4\n" +
        "#EXT-X-PLAYLIST-TYPE:VOD\n" +
        "#EXT-X-TARGETDURATION:2\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/fragment1.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/fragment2.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/fragment3.ts\n" +
        "#EXTINF:2.002,\n" +
        "http://not.a.server.nowhere/fragment4.ts\n" +
"#EXT-X-ENDLIST\n"
