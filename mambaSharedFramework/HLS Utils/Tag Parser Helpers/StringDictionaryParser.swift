//
//  StringDictionaryParser.swift
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

struct StringDictionaryParser {
    
    enum StringDictionaryParserError: Error {
        /// Error indicating that the passed in string is not in the expected format
        case malformedDictionaryString
    }
    
    /// parses a string in the format "<key1>=<value1>,<key2>=<value2>" to a dictionary [<key1>: <value1>, <key2>: <value2>]. Throws .malformedDictionaryString if string is not formatted as expected
    ///
    /// quotes should escape commas and equals, so "key1=value1,key2="value2,value3=value4"" should resolve to [key1: value1, key2: "value2,value3=value4"]
    static func parseToHLSTagDictionary(fromParsableString string: String) throws -> HLSTagDictionary {
        
        var dictionary = HLSTagDictionary()
        
        guard string.count > 0 else {
            return dictionary
        }
        
        var build: String? = nil
        var key: String = ""
        var quoteEscaped = false
        
        for char in string {
            if char == "\"" {
                quoteEscaped = !quoteEscaped
                if let _ = build {
                    build = build! + String(char)
                }
                else {
                    build = String(char)
                }
            }
            else if char == "=" && !quoteEscaped && key.isEmpty {
                if let build = build {
                    key = build
                }
                else {
                    throw StringDictionaryParserError.malformedDictionaryString
                }
                build = ""
            }
            else if char == "," && !quoteEscaped {
                if let build = build, !key.isEmpty {
                    add(key: key, andValue: build, toTagDictionary: &dictionary)
                }
                else {
                    throw StringDictionaryParserError.malformedDictionaryString
                }
                build = ""
                key = ""
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
        if let build = build, !key.isEmpty {
            add(key: key, andValue: build, toTagDictionary: &dictionary)
        }
        else {
            throw StringDictionaryParserError.malformedDictionaryString
        }
        return dictionary
    }
    
    static private func add(key keyIn: String,
                            andValue valueIn: String,
                            toTagDictionary dictionary: inout HLSTagDictionary) {
        
        var value = valueIn.trim()
        let key = keyIn.trim()
        var quoteEscaped = false
        
        if value.hasPrefix("\"") && value.hasSuffix("\"") {
            value = value.trimDoubleQuotes()
            quoteEscaped = true
        }
        
        dictionary[key] = HLSValueData(value: value, quoteEscaped: quoteEscaped)
    }
}
