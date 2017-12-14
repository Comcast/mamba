//
//  IndeterminateBoolTests.swift
//  mamba
//
//  Created by David Coufal on 12/7/17.
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
import mamba

class IndeterminateBoolTests: XCTestCase {
    
    func testIndeterminateBool() {
        
        XCTAssertEqual(IndeterminateBool(boolValue: true), IndeterminateBool.TRUE)
        XCTAssertEqual(IndeterminateBool(boolValue: false), IndeterminateBool.FALSE)
        
        XCTAssert(IndeterminateBool.TRUE == IndeterminateBool.TRUE)
        XCTAssertFalse(IndeterminateBool.TRUE == IndeterminateBool.FALSE)
        XCTAssertFalse(IndeterminateBool.TRUE == IndeterminateBool.INDETERMINATE)
        XCTAssert(IndeterminateBool.FALSE == IndeterminateBool.FALSE)
        XCTAssertFalse(IndeterminateBool.FALSE == IndeterminateBool.TRUE)
        XCTAssertFalse(IndeterminateBool.FALSE == IndeterminateBool.INDETERMINATE)
        XCTAssert(IndeterminateBool.INDETERMINATE == IndeterminateBool.INDETERMINATE)
        XCTAssertFalse(IndeterminateBool.INDETERMINATE == IndeterminateBool.TRUE)
        XCTAssertFalse(IndeterminateBool.INDETERMINATE == IndeterminateBool.FALSE)
        
        XCTAssert(IndeterminateBool.TRUE == true)
        XCTAssert(IndeterminateBool.FALSE == false)
        XCTAssert(true == IndeterminateBool.TRUE)
        XCTAssert(false == IndeterminateBool.FALSE)
        
        XCTAssert(IndeterminateBool.TRUE != IndeterminateBool.FALSE)
        XCTAssert(IndeterminateBool.TRUE != IndeterminateBool.INDETERMINATE)
        XCTAssert(IndeterminateBool.FALSE != IndeterminateBool.TRUE)
        XCTAssert(IndeterminateBool.FALSE != IndeterminateBool.INDETERMINATE)
        XCTAssert(IndeterminateBool.INDETERMINATE != IndeterminateBool.TRUE)
        XCTAssert(IndeterminateBool.INDETERMINATE != IndeterminateBool.FALSE)
        
        XCTAssert((IndeterminateBool.TRUE && IndeterminateBool.TRUE) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.TRUE && IndeterminateBool.FALSE) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.TRUE && IndeterminateBool.INDETERMINATE) == IndeterminateBool.INDETERMINATE)
        XCTAssert((IndeterminateBool.FALSE && IndeterminateBool.TRUE) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.FALSE && IndeterminateBool.FALSE) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.FALSE && IndeterminateBool.INDETERMINATE) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.INDETERMINATE && IndeterminateBool.TRUE) == IndeterminateBool.INDETERMINATE)
        XCTAssert((IndeterminateBool.INDETERMINATE && IndeterminateBool.FALSE) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.INDETERMINATE && IndeterminateBool.INDETERMINATE) == IndeterminateBool.INDETERMINATE)
        
        XCTAssert((IndeterminateBool.TRUE || IndeterminateBool.TRUE) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.TRUE || IndeterminateBool.FALSE) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.TRUE || IndeterminateBool.INDETERMINATE) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.FALSE || IndeterminateBool.TRUE) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.FALSE || IndeterminateBool.FALSE) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.FALSE || IndeterminateBool.INDETERMINATE) == IndeterminateBool.INDETERMINATE)
        XCTAssert((IndeterminateBool.INDETERMINATE || IndeterminateBool.TRUE) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.INDETERMINATE || IndeterminateBool.FALSE) == IndeterminateBool.INDETERMINATE)
        XCTAssert((IndeterminateBool.INDETERMINATE || IndeterminateBool.INDETERMINATE) == IndeterminateBool.INDETERMINATE)
        
        XCTAssert((IndeterminateBool.TRUE && true) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.TRUE && false) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.FALSE && true) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.FALSE && false) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.INDETERMINATE && true) == IndeterminateBool.INDETERMINATE)
        XCTAssert((IndeterminateBool.INDETERMINATE && false) == IndeterminateBool.FALSE)
        
        XCTAssert((IndeterminateBool.TRUE || true) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.TRUE || false) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.FALSE || true) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.FALSE || false) == IndeterminateBool.FALSE)
        XCTAssert((IndeterminateBool.INDETERMINATE || true) == IndeterminateBool.TRUE)
        XCTAssert((IndeterminateBool.INDETERMINATE || false) == IndeterminateBool.INDETERMINATE)
        
        XCTAssert((true && IndeterminateBool.TRUE) == IndeterminateBool.TRUE)
        XCTAssert((false && IndeterminateBool.TRUE) == IndeterminateBool.FALSE)
        XCTAssert((true && IndeterminateBool.FALSE) == IndeterminateBool.FALSE)
        XCTAssert((false && IndeterminateBool.FALSE) == IndeterminateBool.FALSE)
        XCTAssert((true && IndeterminateBool.INDETERMINATE) == IndeterminateBool.INDETERMINATE)
        XCTAssert((false && IndeterminateBool.INDETERMINATE) == IndeterminateBool.FALSE)
        
        XCTAssert((true || IndeterminateBool.TRUE) == IndeterminateBool.TRUE)
        XCTAssert((false || IndeterminateBool.TRUE) == IndeterminateBool.TRUE)
        XCTAssert((true || IndeterminateBool.FALSE) == IndeterminateBool.TRUE)
        XCTAssert((false || IndeterminateBool.FALSE) == IndeterminateBool.FALSE)
        XCTAssert((true || IndeterminateBool.INDETERMINATE) == IndeterminateBool.TRUE)
        XCTAssert((false || IndeterminateBool.INDETERMINATE) == IndeterminateBool.INDETERMINATE)
        
        XCTAssert(!(IndeterminateBool.TRUE) == IndeterminateBool.FALSE)
        XCTAssert(!(IndeterminateBool.FALSE) == IndeterminateBool.TRUE)
        XCTAssert(!(IndeterminateBool.INDETERMINATE) == IndeterminateBool.INDETERMINATE)
        
        XCTAssertEqual(IndeterminateBool.TRUE.debugDescription, "TRUE")
        XCTAssertEqual(IndeterminateBool.FALSE.debugDescription, "FALSE")
        XCTAssertEqual(IndeterminateBool.INDETERMINATE.debugDescription, "INDETERMINATE")
    }
}
