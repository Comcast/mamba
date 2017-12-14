//
//  GenericDictionaryTagParserHelper.swift
//  mamba
//
//  Created by David Coufal on 7/8/16.
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

struct GenericDictionaryTagParserHelper {
    
    /// Generic code to parse a tags values out from a dictionary. Assumes all tag values are strings and returns them as such
    static func parseTag(fromParsableString string: String?,
                         tag: HLSTagDescriptor)
        throws -> HLSTagDictionary {
            
            guard let string = string else {
                throw HLSParserError.malformedHLSTag(tag: tag.toString(), tagBody: nil)
            }
            
            var results: HLSTagDictionary
            do {
                results = try StringDictionaryParser.parseToHLSTagDictionary(fromParsableString:string as String)
            }
            catch {
                throw HLSParserError.malformedHLSTag(tag: tag.toString(), tagBody: string)
            }
                        
            return results
    }
}
