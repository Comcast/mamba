//
//  NoOpTagParser.swift
//  mamba
//
//  Created by David Coufal on 2/16/17.
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

import Foundation

/// "No operation" Tag Parser. This is returned in cases when `RegisteredTags` cannot determine a `TagParser`. Usage of this class in production is a error.
public class NoOpTagParser: PlaylistTagParser {
    
    public func parseTag(fromTagString string: String?) throws -> PlaylistTagDictionary {
        
        assertionFailure("Should not use NoOpTagParser to parse a tag")
        return PlaylistTagDictionary()
    }
}
