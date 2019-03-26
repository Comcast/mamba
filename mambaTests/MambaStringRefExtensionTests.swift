//
//  MambaStringRefExtensionTests.swift
//  mamba
//
//  Created by Jesse on 4/14/17.
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

class MambaStringRefExtensionTests: XCTestCase {
    
    func testInitFromValueID() {
        let valueID = PantosValue.UnknownTag_Name
        let mambaStringRef = MambaStringRef(valueIdentifier: valueID)
        
        XCTAssertNotNil(mambaStringRef, "we should have an MambaStringRef")
        XCTAssertEqual(mambaStringRef.stringValue(), valueID.toString())
    }
    
    func testInitFromDescriptor() {
        let descriptor = PantosTag.UnknownTag
        let mambaStringRef = MambaStringRef(descriptor: descriptor)
        
        XCTAssertNotNil(mambaStringRef, "We should have an MambaStringRef")
        XCTAssertEqual(mambaStringRef.stringValue(), "#\(descriptor.toString())")
    }
    
    func testStringEquality() {
        let tagValue = "test"
        let stringRef = MambaStringRef(string: tagValue)
        XCTAssert(tagValue == stringRef)
    }
    
    func testStringInequality() {
        let stringRef = MambaStringRef(string: "test")
        XCTAssert(stringRef != "other")
        XCTAssert("other" != stringRef)
    }
    
    func testRelativeURL() {
        let url: URL = URL(string:"http://fake.server/playlist.m3u8")!
        let relativeUrlStringRef = MambaStringRef(string: "variant.m3u8")
        let fullUrlStringRef = MambaStringRef(mambaStringRef:relativeUrlStringRef, relativeTo:url)
        XCTAssert(fullUrlStringRef! == "http://fake.server/variant.m3u8")
    }
}
