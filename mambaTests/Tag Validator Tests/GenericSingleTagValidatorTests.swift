//
//  GenericDurationValidatorTests.swift
//  mamba
//
//  Created by Mohan on 8/8/16.
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

class GenericSingleTagValidatorTests: XCTestCase {
    
    // EXT_X_TARGETDURATION test cases
    func testNumberCorrectInput() {
        let tagData = "10"
        let (validator,tag) = constructTargetDurationValidator(tagData)
        
        guard let _ = validator.validate(tag: tag) else {
            return
        }
        XCTAssert(false, "Unexpected error")
    }
    
    func testStringInput() {
        let tagData = "FIVE"
        let (validator,tag) = constructTargetDurationValidator(tagData)
        
        guard let validationIssues = validator.validate(tag: tag) else {
            XCTAssert(false, "Expecting validation issues")
            return
        }
        XCTAssert(validationIssues.count == 1, "Incorrect validationIssues count")
        XCTAssert(validationIssues[0].description == "\(PantosTag.EXT_X_TARGETDURATION.toString()) (\(tagData)) is not an instance of the expected data type.", "Incorrect issue description")
        XCTAssert(validationIssues[0].severity == IssueSeverity.error, "Incorrect issue severity")
    }
    
    func testFloatInput() {
        let tagData = "6.25"
        let (validator,tag) = constructTargetDurationValidator(tagData)
        
        guard let validationIssues = validator.validate(tag: tag) else {
            XCTAssert(false, "Expecting validation issues")
            return
        }
        XCTAssert(validationIssues.count == 1, "Incorrect validationIssues count")
        XCTAssert(validationIssues[0].description == "\(PantosTag.EXT_X_TARGETDURATION.toString()) (\(tagData)) is not an instance of the expected data type.", "Incorrect issue description")
        XCTAssert(validationIssues[0].severity == IssueSeverity.error, "Incorrect issue severity")
    }
    
    // EXT_X_ALLOW_CACHE test cases
    func testAllocCacheCorrectInput() {
        let tagData = "YES"
        let (validator,tag) = constructAllowCacheValidator(tagData)
        
        guard let _ = validator.validate(tag: tag) else {
            return
        }
        XCTAssert(false, "Unexpected error")
    }
    
    func testAllocCacheCorrectInput2() {
        let tagData = "NO"
        let (validator,tag) = constructAllowCacheValidator(tagData)
        
        guard let _ = validator.validate(tag: tag) else {
            return
        }
        XCTAssert(false, "Unexpected error")
    }
    
    func testAllocCacheInvalidInput() {
        let tagData = "Invalid"
        let (validator,tag) = constructAllowCacheValidator(tagData)
        
        guard let validationIssues = validator.validate(tag: tag) else {
            XCTAssert(false, "Expecting validation issues")
            return
        }
        XCTAssert(validationIssues.count == 1, "Incorrect validationIssues count")
        XCTAssert(validationIssues[0].description == "\(PantosTag.EXT_X_ALLOW_CACHE.toString()) (\(tagData)) is not an instance of the expected data type.", "Incorrect issue description")
        XCTAssert(validationIssues[0].severity == IssueSeverity.error, "Incorrect issue severity")
    }
    
    // EXT_X_PLAYLIST_TYPE test cases
    func testPlayListTypeCorrectInput() {
        let tagData = "EVENT"
        let (validator,tag) = constructPlayListTypeValidator(tagData)
        
        guard let _ = validator.validate(tag: tag) else {
            return
        }
        XCTAssert(false, "Unexpected error")
    }
    
    func testPlayListTypeCorrectInput2() {
        let tagData = "VOD"
        let (validator,tag) = constructPlayListTypeValidator(tagData)
        
        guard let _ = validator.validate(tag: tag) else {
            return
        }
        XCTAssert(false, "Unexpected error")
    }
    
    func testPlayListTypeInvalidInput() {
        let tagData = "Invalid"
        let (validator,tag) = constructPlayListTypeValidator(tagData)
        
        guard let validationIssues = validator.validate(tag: tag) else {
            XCTAssert(false, "Expecting validation issues")
            return
        }
        XCTAssert(validationIssues.count == 1, "Incorrect validationIssues count")
        XCTAssert(validationIssues[0].description == "\(PantosTag.EXT_X_PLAYLIST_TYPE.toString()) (\(tagData)) is not an instance of the expected data type.", "Incorrect issue description")
        XCTAssert(validationIssues[0].severity == IssueSeverity.error, "Incorrect issue severity")
    }
    
    
    func constructTargetDurationValidator(_ tagValue:String) -> (HLSTagValidator, HLSTag) {
        let tag = createHLSTag(tagDescriptor: PantosTag.EXT_X_TARGETDURATION, tagData: tagValue)
        
        return (GenericSingleTagValidator<Int>(tag: PantosTag.EXT_X_TARGETDURATION,
            singleValueIdentifier:PantosValue.targetDurationSeconds), tag)
    }
    
    func constructAllowCacheValidator(_ tagValue:String) -> (HLSTagValidator, HLSTag) {
        let tag = createHLSTag(tagDescriptor: PantosTag.EXT_X_ALLOW_CACHE, tagData: tagValue)
        
        return (GenericSingleTagValidator<Bool>(tag: PantosTag.EXT_X_ALLOW_CACHE,
            singleValueIdentifier:PantosValue.allowCache), tag)
    }
    
    func constructPlayListTypeValidator(_ tagValue:String) -> (HLSTagValidator, HLSTag) {
        let tag = createHLSTag(tagDescriptor: PantosTag.EXT_X_PLAYLIST_TYPE, tagData: tagValue)
        
        return (GenericSingleTagValidator<HLSPlaylistType>(tag: PantosTag.EXT_X_PLAYLIST_TYPE,
            singleValueIdentifier:PantosValue.playlistType), tag)
    }
}
