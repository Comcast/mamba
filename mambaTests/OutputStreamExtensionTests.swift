//
//  OutputStreamExtensionTests.swift
//  mamba
//
//  Created by David Coufal on 12/12/17.
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

private let testString = "OutputStreamExtensionTests_TestString"

class OutputStreamExtensionTests: XCTestCase {
    
    func testHLSStringRefWrite() {
        
        let stream = OutputStream.toMemory()
        stream.open()
        
        defer {
            stream.close()
        }
        
        let stringRef = HLSStringRef(string: testString)
        
        do { try stream.write(stringRef: stringRef) }
        catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        if let streamerror = stream.streamError {
            XCTFail("Unexpected streamerror: \(streamerror)")
        }
        else {
            guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
                XCTFail("Could not get written data from stream")
                return
            }
            guard let result = String(data: data, encoding: .utf8) else {
                XCTFail("Could not convert data to string")
                return
            }
            XCTAssert(result == testString, "Expecting \'\(testString)\' output, got \'\(result)\' instead")
        }
    }
    
    func testStringWrite() {
        
        let stream = OutputStream.toMemory()
        stream.open()
        
        defer {
            stream.close()
        }
        
        do { try stream.write(string: testString) }
        catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        if let streamerror = stream.streamError {
            XCTFail("Unexpected streamerror: \(streamerror)")
        }
        else {
            guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
                XCTFail("Could not get written data from stream")
                return
            }
            guard let result = String(data: data, encoding: .utf8) else {
                XCTFail("Could not convert data to string")
                return
            }
            XCTAssert(result == testString, "Expecting \'\(testString)\' output, got \'\(result)\' instead")
        }
    }
    
    func testDataHLSStringRefWrite() {
        
        let stream = OutputStream.toMemory()
        stream.open()
        
        defer {
            stream.close()
        }
        
        let testData = testString.data(using: .utf8)!
        
        do { try stream.write(data: testData) }
        catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        if let streamerror = stream.streamError {
            XCTFail("Unexpected streamerror: \(streamerror)")
        }
        else {
            guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
                XCTFail("Could not get written data from stream")
                return
            }
            guard let result = String(data: data, encoding: .utf8) else {
                XCTFail("Could not convert data to string")
                return
            }
            XCTAssert(result == testString, "Expecting \'\(testString)\' output, got \'\(result)\' instead")
        }
    }
    
    func testUnicodeScalarWrite() {
        
        let stream = OutputStream.toMemory()
        stream.open()
        
        defer {
            stream.close()
        }
        
        let scalar: UnicodeScalar = "M"
        
        do { try stream.write(unicodeScalar: scalar) }
        catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        if let streamerror = stream.streamError {
            XCTFail("Unexpected streamerror: \(streamerror)")
        }
        else {
            guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
                XCTFail("Could not get written data from stream")
                return
            }
            guard let result = String(data: data, encoding: .utf8) else {
                XCTFail("Could not convert data to string")
                return
            }
            XCTAssert(result == "M", "Expecting \'\(scalar)\' output, got \'\(result)\' instead")
        }
    }
}

