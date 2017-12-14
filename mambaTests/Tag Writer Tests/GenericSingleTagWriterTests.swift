//
//  GenericSingleTagWriterTests.swift
//  mamba
//
//  Created by David Coufal on 7/13/16.
//  Copyright © 2016 Comcast Cable Communications Management, LLC
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

class GenericSingleTagWriterTests: XCTestCase {
    
    let duration = "6"
    
    let dummyKey = "DUMMY-KEY"
    let dummyValue = "DUMMY-VALUE"
    
    func testGenericSingleTagWriterSuccess() {
        
        let tag = createHLSTag(tagDescriptor: PantosTag.EXT_X_TARGETDURATION, tagData: "\(duration)")
        
        let writer = GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.targetDurationSeconds)
        
        do {
            let string = try writeToString(withTag: tag, withWriter: writer)
            
            XCTAssert(string == "#\(PantosTag.EXT_X_TARGETDURATION.toString()):\(duration)", "Did not write successfully")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
    
    func testGenericSingleTagWriterFailure_MissingTags() {
        
        let tag = HLSTag(tagDescriptor: PantosTag.EXT_X_STREAM_INF, stringTagData: "", parsedValues: ["notag":HLSValueData(value: "novalue")])
        
        let writer = GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.targetDurationSeconds)
        
        do {
            
            let _ = try writeToString(withTag: tag, withWriter: writer)
            
            XCTAssert(false, "Should throw")
        }
        catch OutputStreamError.invalidData(_) {
            // expected
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
}
