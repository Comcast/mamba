//
//  StringArrayParser.swift
//  mamba
//
//  Created by David Coufal on 6/27/16.
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

import Foundation

struct StringArrayParser {
    
    /// takes a string that is formatted as <str1>,<str2>,<str3> and returns [<str1>, <str2>, <str3>].
    ///
    /// quotes should escape commas, so "str1,"str2,str3"" should resolve to ["str1", "str2,str3"]
    static func parseToArray(fromParsableString string: String, ignoreQuotes: Bool = false) -> [String] {
        
        var array = [String]()
        var build: String? = nil
        
        var quoteEscaped = false
        
        for char in string {
            if char == "\"" {
                if (ignoreQuotes) {
                    continue
                }
                if let _ = build {
                    build! += "\""
                }
                else {
                    build = "\""
                }
                quoteEscaped = !quoteEscaped
            }
            else if char == "," && !quoteEscaped {
                if let build = build {
                    array.append(build)
                }
                else {
                    array.append("")
                }
                build = ""
            }
            else {
                if let _ = build {
                    build = build! + String(char)
                }
                else {
                    build = String(char)
                }
            }
        }
        if let build = build {
            array.append(build)
        }
       
        return array
    }
}
