//
//  RapidParserTests.swift
//  mamba
//
//  Created by David Coufal on 1/23/17.
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

class RapidParserTests: XCTestCase, HLSRapidParserCallback {

    var lines = [TestLine]()
    var expectation: XCTestExpectation?
    
    func testParser() {
        
        expectation = self.expectation(description: "Parsing complete")
                
        let data = FixtureLoader.load(fixtureName: "hls_sampleMediaFile.txt")! as Data
        
        let parser = HLSRapidParser()
        
        parser.parseHLSData(data, callback: self)
        
        self.waitForExpectations(timeout: 1, handler: { (error) in
            XCTAssertNil(error, "Unexpected error: \(error!)")
        })
    }
    
    
    // MARK: HLSRapidParserCallback
    
    func addedURLLine(_ url: HLSStringRef) {
        lines.insert(TestLine(url: url, comment: nil, tagName: nil, tagValue: nil), at: 0)
    }
    
    func addedCommentLine(_ comment: HLSStringRef) {
        lines.insert(TestLine(url: nil, comment: comment, tagName: nil, tagValue: nil), at: 0)
    }
    
    func addedNoValueTag(withName tagName: HLSStringRef) {
        lines.insert(TestLine(url: nil, comment: nil, tagName: tagName, tagValue: nil), at: 0)
    }
    
    func addedTag(withName tagName: HLSStringRef, value: HLSStringRef) {
        lines.insert(TestLine(url: nil, comment: nil, tagName: tagName, tagValue: value), at: 0)
    }
    
    public func addedEXTINFTag(withName tagName: HLSStringRef, duration: HLSStringRef, value: HLSStringRef) {
        lines.insert(TestLine(url: nil,
                              comment: nil,
                              tagName: tagName,
                              tagValue: value), at: 0)
    }
    
    func parseComplete() {
        print(lines)
        XCTAssert(lines.count == 19, "Unexpected number of lines")
        guard let expectation = expectation else {
            XCTFail("No expectation")
            return
        }
        expectation.fulfill()
    }
    
    func parseError(_ error: String, errorNumber: UInt32) {
        XCTFail("Received Parse Error: \(errorNumber) \(error)")
    }
}

struct TestLine: CustomDebugStringConvertible {
    let url: HLSStringRef?
    let comment: HLSStringRef?
    let tagName: HLSStringRef?
    let tagValue: HLSStringRef?
    var debugDescription: String {
        if let u: HLSStringRef = url {
            return "\(u.stringValue())\n"
        }
        if let c: HLSStringRef = comment {
            return "\(c.stringValue())\n"
        }
        if let n: HLSStringRef = tagName {
            if let v: HLSStringRef = tagValue {
                return "\(n.stringValue()):\(v.stringValue())\n"
            }
            return "\(n.stringValue())\n"
        }
        return ""
    }
}
