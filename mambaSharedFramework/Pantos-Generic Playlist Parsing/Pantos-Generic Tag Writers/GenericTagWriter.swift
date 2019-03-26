//
//  GenericTagWriter.swift
//  mamba
//
//  Created by Andrew Morrow on 2/9/17.
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

/// A generic writer for tags that pays no attention to structure. It will just take the tag and any data and write it directly to stream.
/// This is useful for `PantosTag.UnknownTag` type tags where we do not recognize the type.
struct GenericTagWriter: PlaylistTagWriter {
    
    func write(tag: PlaylistTag, toStream stream: OutputStream) throws {
        try GenericTagWriter.write(tag: tag, toStream: stream)
    }
    
    static func write(tag: PlaylistTag, toStream stream: OutputStream) throws {
        assert(!tag.isDirty, "GenericTagWriter cannot write dirty tags")
        
        if let name = tag.tagName, name.length > 0 {
            try stream.write(stringRef: name)
            if tag.tagData.length > 0 {
                try stream.write(unicodeScalar: TagWritingSeparators.colon)
            }
        }
        
        if tag.tagData.length > 0 {
            try stream.write(stringRef: tag.tagData)
        }
    }
}
