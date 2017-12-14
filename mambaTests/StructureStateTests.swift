//
//  StructureStateTests.swift
//  mamba
//
//  Created by David Coufal on 4/14/17.
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

class StructureStateTests: XCTestCase {
    
    func testStructureState() {
        let clean1 = StructureState.clean
        let clean2 = StructureState.clean
        let tagChange1 = StructureState.dirtyWithTagChanges([TagChangeRecord(tagChangeCount: 0, index: 0)])
        let tagChange2 = StructureState.dirtyWithTagChanges([TagChangeRecord(tagChangeCount: 1, index: 1)])
        let dirty1 = StructureState.dirtyRequiresRebuild
        let dirty2 = StructureState.dirtyRequiresRebuild
        
        XCTAssertTrue(clean1 == clean2)
        XCTAssertTrue(tagChange1 == tagChange2)
        XCTAssertTrue(dirty1 == dirty2)
        
        XCTAssertFalse(clean1 == tagChange1)
        XCTAssertFalse(clean1 == dirty1)
        XCTAssertFalse(tagChange1 == dirty1)
        XCTAssertFalse(tagChange1 == clean1)
        XCTAssertFalse(dirty1 == clean1)
        XCTAssertFalse(clean1 == tagChange1)
    }
}
