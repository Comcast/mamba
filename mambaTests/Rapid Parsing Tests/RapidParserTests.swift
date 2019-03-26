//
//  RapidParserTests.swift
//  mamba
//
//  Created by David Coufal on 1/23/17.
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

class RapidParserTests: XCTestCase {

    func testParser() {

        let mock = MockRapidParserCallback()
        
        mock.expectation = self.expectation(description: "Parsing complete")
        mock.expectedNumberOfLines = 19
                
        let data = FixtureLoader.load(fixtureName: "hls_sampleMediaFile.txt")! as Data
        
        let parser = RapidParser()
        
        parser.parseHLSData(data, callback: mock)
        
        self.waitForExpectations(timeout: 1, handler: { (error) in
            XCTAssertNil(error, "Unexpected error: \(error!)")
        })
    }
    
    func testEventShunt() {
        
        let mock = MockRapidParserCallback()
        mock.expectedNumberOfLines = 6
        mock.shuntOnFragmentUrl = "http://media.example.com/entire.ts"
        
        mock.expectation = self.expectation(description: "Parsing complete")
        
        let data = FixtureLoader.load(fixtureName: "hls_sampleMediaFile.txt")! as Data
        
        let parser = RapidParser()
        
        parser.parseHLSData(data, callback: mock)
        
        self.waitForExpectations(timeout: 1, handler: { (error) in
            XCTAssertNil(error, "Unexpected error: \(error!)")
        })
    }
}

private class MockRapidParserCallback: NSObject, RapidParserCallback {
    
    var lines = [TestLine]()
    var expectation: XCTestExpectation?
    var expectedNumberOfLines: Int = 0
    var shuntOnFragmentUrl: String? = nil

    // MARK: RapidParserCallback
    
    func addedURLLine(_ url: MambaStringRef) -> Bool {
        if
            let shuntOnFragmentUrl = shuntOnFragmentUrl,
            url.stringValue() == shuntOnFragmentUrl {
            runParseTest()
            return false
        }
        lines.insert(TestLine(url: url, comment: nil, tagName: nil, tagValue: nil), at: 0)
        return true
    }
    
    func addedCommentLine(_ comment: MambaStringRef) {
        lines.insert(TestLine(url: nil, comment: comment, tagName: nil, tagValue: nil), at: 0)
    }
    
    func addedNoValueTag(withName tagName: MambaStringRef) {
        lines.insert(TestLine(url: nil, comment: nil, tagName: tagName, tagValue: nil), at: 0)
    }
    
    func addedTag(withName tagName: MambaStringRef, value: MambaStringRef) {
        lines.insert(TestLine(url: nil, comment: nil, tagName: tagName, tagValue: value), at: 0)
    }
    
    public func addedEXTINFTag(withName tagName: MambaStringRef, duration: MambaStringRef, value: MambaStringRef) {
        lines.insert(TestLine(url: nil,
                              comment: nil,
                              tagName: tagName,
                              tagValue: value), at: 0)
    }
    
    func parseComplete() {
        runParseTest()
    }
    
    func parseError(_ error: String, errorNumber: UInt32) {
        XCTFail("Received Parse Error: \(errorNumber) \(error)")
    }
    
    private func runParseTest() {
        XCTAssert(lines.count == expectedNumberOfLines, "Unexpected number of lines got \(lines.count) expected \(expectedNumberOfLines)")
        guard let expectation = expectation else {
            XCTFail("No expectation")
            return
        }
        expectation.fulfill()
    }
}

private struct TestLine: CustomDebugStringConvertible {
    let url: MambaStringRef?
    let comment: MambaStringRef?
    let tagName: MambaStringRef?
    let tagValue: MambaStringRef?
    var debugDescription: String {
        if let u: MambaStringRef = url {
            return "\(u.stringValue())\n"
        }
        if let c: MambaStringRef = comment {
            return "\(c.stringValue())\n"
        }
        if let n: MambaStringRef = tagName {
            if let v: MambaStringRef = tagValue {
                return "\(n.stringValue()):\(v.stringValue())\n"
            }
            return "\(n.stringValue())\n"
        }
        return ""
    }
}
