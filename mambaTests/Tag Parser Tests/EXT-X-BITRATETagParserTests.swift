//
//  EXT-X-BITRATETagParserTests.swift
//  mambaTests
//
//  Created by Youngkin, Richard on 11/7/18.
//  Copyright © 2018 Comcast Corporation.
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
//  limitations under the License. All rights reserved.
//

import XCTest

@testable import mamba

class EXT_X_BITRATETagParserTests: XCTestCase {
    
    func testFullTag() {
        let parser = PantosTag.parser(forTag: PantosTag.EXT_X_BITRATE)
        
        do {
            let valueDictionary = try parser!.parseTag(fromTagString: "3492800")
            
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.value == "3492800", "Tag did not parse properly")
            XCTAssert(valueDictionary[PantosValue.bandwidthBPS.rawValue]?.quoteEscaped == false, "Tag did not parse properly")
        }
        catch {
            XCTAssert(false, "Parser should not throw")
        }
    }
    
}
