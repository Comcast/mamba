//
//  PlaylistTagDictionaryParser.swift
//  mamba
//
//  Created by David Coufal on 6/27/16.
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

// Abstracts a value found in a PlaylistTag
public struct PlaylistTagValueData {
    public init(value: String, quoteEscaped: Bool = false) {
        self.value = value
        self.quoteEscaped = quoteEscaped
    }
    /// The actual value
    let value: String
    /// Indicates if the value should be quote-escaped or not
    let quoteEscaped: Bool
}

public typealias PlaylistTagDictionary = OrderedDictionary<String, PlaylistTagValueData>

/// Describes a object that parse an individual tag from a line in a HLS playlist
public protocol PlaylistTagParser: AnyObject {
    
    /**
     Parses an playlist tag from a String. (i.e. if your tag is "#EXT-GENERICTAG:<Values>", you would pass "<Values>" as your string argument)
     
     - parameter fromTagString: An optional string to parse. (Optional because some tags actually have no data)
     
     - returns: An `PlaylistTagDictionary` of all the key value pairs found in the tag (will contain values found in single-value tags as well, for convenience)
     
     - throws: a PlaylistTagParserError.malformedTag type if the tag is malformed or is missing pantos required data
     */
    func parseTag(fromTagString: String?) throws -> PlaylistTagDictionary
}
