//
//  RenditionGroupAudioVideoValidator.swift
//  mamba
//
//  Created by Philip McMahon on 11/4/16.
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

protocol PlaylistRenditionGroupAudioVideoValidator: MasterPlaylistTagGroupValidator {
    static var description: IssueDescription { get }
}

extension PlaylistRenditionGroupAudioVideoValidator {
    static var validation: ([PlaylistTag]) -> [PlaylistValidationIssue] {
        return { (tags) -> [PlaylistValidationIssue] in
            
            var codecArray: CodecValueTypeArray?
            
            for tag in tags.filter({ $0.tagDescriptor == PantosTag.EXT_X_STREAM_INF }) {
                
                if let value: String = tag.value(forValueIdentifier: PantosValue.codecs),
                    let codecs = CodecValueTypeArray(string: value) {
                    
                    if let _ = codecArray {
                        guard let previousCodecs = codecArray else { return [PlaylistValidationIssue]() }
                        let remainingCodecs = codecs.codecs.filter({ previousCodecs.includes(codec: $0) })
                        if (remainingCodecs.isEmpty) {
                            return [PlaylistValidationIssue(description: self.description, severity: IssueSeverity.error)]
                        }
                        codecArray = CodecValueTypeArray(codecs: remainingCodecs)
                    }
                    else {
                        codecArray = codecs
                    }
                }
                
            }
            
            return [PlaylistValidationIssue]()
        }
    }
}


// All members of a group with TYPE=AUDIO MUST use the same audio sample format.
class PlaylistRenditionGroupAUDIOValidator: PlaylistRenditionGroupAudioVideoValidator {
    class var description: IssueDescription {
        get {
            return IssueDescription.PlaylistRenditionGroupAUDIOValidator
        }
    }
    static let tagIdentifierPairs: [TagIdentifierPair] = [(PantosTag.EXT_X_MEDIA, PantosValue.groupId),
                                                             (PantosTag.EXT_X_STREAM_INF, PantosValue.audioGroup)]
}

// All members of a group with TYPE=VIDEO MUST use the same video sample format.
class PlaylistRenditionGroupVIDEOValidator: PlaylistRenditionGroupAudioVideoValidator {
    class var description: IssueDescription {
        get {
            return IssueDescription.PlaylistRenditionGroupVIDEOValidator
        }
    }
    static let tagIdentifierPairs: [TagIdentifierPair] = [(PantosTag.EXT_X_MEDIA, PantosValue.groupId),
                                                             (PantosTag.EXT_X_STREAM_INF, PantosValue.videoGroup)]
}
