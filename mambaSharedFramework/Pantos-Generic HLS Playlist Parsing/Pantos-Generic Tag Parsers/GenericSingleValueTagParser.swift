//
//  GenericSingleValueTagParser.swift
//  mamba
//
//  Created by David Coufal on 7/15/16.
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

import Foundation

/// Class for generically parsing tags in the form of `#EXT-X-TARGETDURATION:10`, where there is a tag with a one and only one value associated with it
public class GenericSingleValueTagParser: HLSTagParser {
    
    let tag: HLSTagDescriptor
    var singleValueIdentifier: HLSTagValueIdentifier
    
    /**
     Constructs a GenericSingleValueTagParser
     
     - parameter tag: The HLSTagDescriptor for the tag you are trying to parse
     - parameter singleValueIdentifier: The HLSTagValueIdentifier for the value you are trying to parse out of the tag
     - parameter validator: The SingleValueValidator that will do any validation of the tag value. Just return true if no validation is required
    */
    public init(tag: HLSTagDescriptor, singleValueIdentifier: HLSTagValueIdentifier) {
        self.tag = tag
        self.singleValueIdentifier = singleValueIdentifier
    }
    
    public func parseTag(fromTagString string: String?) throws -> HLSTagDictionary {
        guard let string = string , !string.isEmpty else {
            throw ParserError.malformedHLSTag(tag: tag.toString(), tagBody: nil)
        }
        return [singleValueIdentifier.toString(): HLSValueData(value: string)]
    }
}
