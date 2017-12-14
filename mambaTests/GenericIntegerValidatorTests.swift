//
//  GenericDurationValidatorTests.swift
//  helio
//
//  Created by Mohan on 8/8/16.
//  Copyright © 2016 Comcast Corporation. This software and its contents are
//  Comcast confidential and proprietary. It cannot be used, disclosed, or
//  distributed without Comcast's prior written permission. Modification of this
//  software is only allowed at the direction of Comcast Corporation. All allowed
//  modifications must be provided to Comcast Corporation. All rights reserved.
//

import XCTest

@testable import helio

class GenericIntegerValidatorTests: XCTestCase {

    func testNumberCorrectInput() {
        let tagData = "10"
        let validator = GenericIntegerValidator(integerValueIdentifier: PantosValue.durationSeconds)

        guard let _ = validator.validateTag(self.getTag(tagData)) else {
            return
        }
        XCTAssert(false, "Unexpected error")
    }
    
    func testStringInput() {
        let tagData = "FIVE"
        let validator = GenericIntegerValidator(integerValueIdentifier: PantosValue.durationSeconds)
     
        guard let validationIssues = validator.validateTag(self.getTag(tagData)) else {
             XCTAssert(false, "Expecting validation issues")
            return
        }
        XCTAssert(validationIssues.count == 1, "Incorrect validationIssues count")
        XCTAssert(validationIssues[0].description == "EXT-X-TARGETDURATION value \(tagData) is not an integer.", "Incorrect issue description")
        XCTAssert(validationIssues[0].severity == IssueSeverity.Error, "Incorrect issue severity")
    }
    
    func testFloatInput() {
        let tagData = "6.25"
        let validator = GenericIntegerValidator(integerValueIdentifier: PantosValue.durationSeconds)
        
        guard let validationIssues = validator.validateTag(self.getTag(tagData)) else {
            XCTAssert(false, "Expecting validation issues")
            return
        }
        XCTAssert(validationIssues.count == 1, "Incorrect validationIssues count")
        XCTAssert(validationIssues[0].description == "EXT-X-TARGETDURATION value \(tagData) is not an integer.", "Incorrect issue description")
        XCTAssert(validationIssues[0].severity == IssueSeverity.Error, "Incorrect issue severity")
    }

    func testEmptyInput() {
        let tagData = ""
        let validator = GenericIntegerValidator(integerValueIdentifier: PantosValue.durationSeconds)
        
        guard let validationIssues = validator.validateTag(self.getTag(tagData)) else {
            XCTAssert(false, "Expecting validation issues")
            return
        }
        XCTAssert(validationIssues.count == 1, "Incorrect validationIssues count")
        XCTAssert(validationIssues[0].description == "EXT-X-TARGETDURATION value is empty.", "Incorrect issue description")
        XCTAssert(validationIssues[0].severity == IssueSeverity.Error, "Incorrect issue severity")
    }
    
    func getTag(tagValue:String) -> HLSTag{
        let tag = HLSTagImpl(tagDescriptor: PantosTag.EXT_X_TARGETDURATION, tagData: tagValue, registeredTags: standardRegisteredTags)
        tag.state = .Parsed
        tag.valueDictionaryCache = [PantosValue.durationSeconds.toString(): tagValue]
        return tag
    }
    
}
