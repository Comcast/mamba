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

#if SWIFT_PACKAGE
import PlaylistParserError
#endif

import Foundation

/// Class for generically parsing tags in the form of `#EXT-X-TARGETDURATION:10`, where there is a tag with a one and only one value associated with it
public class GenericSingleValueTagParser: PlaylistTagParser {
    
    let tag: PlaylistTagDescriptor
    var singleValueIdentifier: PlaylistTagValueIdentifier
    
    /**
     Constructs a GenericSingleValueTagParser
     
     - parameter tag: The PlaylistTagDescriptor for the tag you are trying to parse
     - parameter singleValueIdentifier: The PlaylistTagValueIdentifier for the value you are trying to parse out of the tag
    */
    public init(tag: PlaylistTagDescriptor, singleValueIdentifier: PlaylistTagValueIdentifier) {
        self.tag = tag
        self.singleValueIdentifier = singleValueIdentifier
    }
    
    public func parseTag(fromTagString string: String?) throws -> PlaylistTagDictionary {
        guard let string = string , !string.isEmpty else {
            throw PlaylistParserError.malformedPlaylistTag(tag: tag.toString(), tagBody: nil)
        }
        return [singleValueIdentifier.toString(): PlaylistTagValueData(value: string)]
    }
}
