//
//  URL+hlsplaylistTests.swift
//  mamba
//
//  Created by David Coufal on 10/10/16.
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

class URL_hlsplaylistTests: XCTestCase {
    
    func testURL_hlsplaylist_changeScheme() {
        
        var url = URL(string: "http://comcast.com")
        
        XCTAssertTrue((url?.changeScheme(to: "mamba"))!, "Should be able to change schemes")
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
        
        XCTAssert(components?.scheme == "mamba", "Should have matching scheme name")
        XCTAssert(components?.host == "comcast.com", "Host should be the same")
    }
}
