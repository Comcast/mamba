//
//  GenericDictionaryTagParser.swift
//  mamba
//
//  Created by David Coufal on 7/20/16.
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

/// Class for generically parsing tags in the form of `#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="g104000",NAME="English",LANGUAGE="en",DEFAULT=YES,AUTOSELECT=YES`, where there is a tag with a set of key=value pairs as part of the payload
public class GenericDictionaryTagParser: HLSTagParser {
    
    let tag: HLSTagDescriptor
    
    /// Constructs a GenericDictionaryTagParser
    ///
    /// tag - The HLSTagDescriptor for the tag you are trying to parse
    public init(tag: HLSTagDescriptor) {
        self.tag = tag
    }

    public func parseTag(fromTagString string: String?) throws -> HLSTagDictionary {
        
        do {
            return try GenericDictionaryTagParserHelper.parseTag(fromParsableString: string, tag: tag)
        }
        catch {
            throw error
        }
    }
}
