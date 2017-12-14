//
//  GenericDictionaryTagWriterTests.swift
//  mamba
//
//  Created by David Coufal on 7/13/16.
//  Copyright © 2016 Comcast Corporation.
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

class GenericDictionaryTagWriterTests: XCTestCase {
    
    let key1 = "KEY1"
    let key2 = "KEY2"
    let key3 = "KEY3"
    let value1 = "VALUE1"
    let value2 = "VALUE2"
    let value3 = "VALUE3"
    
    let arbitraryTag = PantosTag.EXT_X_MEDIA
    
    func testGenericDictionaryTagWriter() {
        
        var tag = HLSTag(tagDescriptor: arbitraryTag,
                         stringTagData: "",
                         parsedValues: [key1: HLSValueData(value: value1),
                                        key2: HLSValueData(value: value2)])
        // force isDirty
        tag.set(value: value1, forKey: key1)
        
        let writer = GenericDictionaryTagWriter()
        
        do {
            let string = try writeToString(withTag: tag, withWriter: writer)
            
            XCTAssert(string == "#\(arbitraryTag.toString()):\(key1)=\(value1),\(key2)=\(value2)", "Write was not successful")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
    
    func testGenericDictionaryTagWriter_NoTags() {
        
        let tag = HLSTag(tagDescriptor: arbitraryTag,
                         stringTagData: "")
        
        let writer = GenericDictionaryTagWriter()
        
        do {
            let string = try writeToString(withTag: tag, withWriter: writer)
            
            XCTAssert(string == "#\(arbitraryTag.toString())", "Write was not successful")
        }
        catch {
            XCTAssert(false, "Should not throw")
        }
    }
}
