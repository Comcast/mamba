//
//  EXT_X_STREAM_INFRenditionGroupValidator.swift
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

protocol EXT_X_STREAM_INFRenditionGroupValidator: HLSManifestTagGroupValidator {
    static var description: IssueDescription { get }
}

extension EXT_X_STREAM_INFRenditionGroupValidator {
    static var validation: ([HLSTag]) -> [HLSValidationIssue]? {
        return { (tags) -> [HLSValidationIssue]? in
            
            let requiredTags: [HLSTagDescriptor] = [PantosTag.EXT_X_MEDIA, PantosTag.EXT_X_STREAM_INF]
            let remainingTags = requiredTags.filter({ (tag) -> Bool in
                tags.contains(where: { (tag2) -> Bool in
                    return tag2.tagDescriptor == tag
                })
            })
            
            // if we've got a EXT_X_STREAM_INF in here, there needs to be a matching EXT_X_MEDIA
            if (remainingTags.contains(where: { $0 == PantosTag.EXT_X_STREAM_INF })) {
                if (remainingTags.count != requiredTags.count) {
                    //if CLOSED-CAPTIONS=NONE in EXT_X_STREAM_INF, there are no closed captions in any variant stream in the Master Playlist
                    let count = tags.filter { $0.value(forValueIdentifier: PantosValue.closedCaptionsGroup) == "NONE" }.count
                    if (count != abs(requiredTags.count - remainingTags.count)){
                        return [HLSValidationIssue(description: self.description, severity: IssueSeverity.error)]
                    }
                }
            }
            return nil
        }
    }
}

// EXT-X-STREAM-INF - AUDIO The value is a quoted-string. It MUST match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist whose TYPE attribute is AUDIO.
class EXT_X_STREAM_INFRenditionGroupAUDIOValidator: EXT_X_STREAM_INFRenditionGroupValidator {
    static let description:IssueDescription = IssueDescription.EXT_X_STREAM_INFRenditionGroupAUDIOValidator
    static let tagIdentifierPairs:[HLSTagIdentifierPair] = [(PantosTag.EXT_X_MEDIA, PantosValue.groupId),
                                                                       (PantosTag.EXT_X_STREAM_INF, PantosValue.audioGroup)]

}

// EXT-X-STREAM-INF - VIDEO The value is a quoted-string. It MUST match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist whose TYPE attribute is VIDEO.
class EXT_X_STREAM_INFRenditionGroupVIDEOValidator: EXT_X_STREAM_INFRenditionGroupValidator {
    static let description:IssueDescription = IssueDescription.EXT_X_STREAM_INFRenditionGroupVIDEOValidator
    static let tagIdentifierPairs:[HLSTagIdentifierPair] = [(PantosTag.EXT_X_MEDIA, PantosValue.groupId),
                                                           (PantosTag.EXT_X_STREAM_INF, PantosValue.videoGroup)]
}

// EXT-X-STREAM-INF - SUBTITLES The value is a quoted-string. It MUST match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist whose TYPE attribute is SUBTITLES.
class EXT_X_STREAM_INFRenditionGroupSUBTITLESValidator: EXT_X_STREAM_INFRenditionGroupValidator {
    static let description:IssueDescription = IssueDescription.EXT_X_STREAM_INFRenditionGroupSUBTITLESValidator
    static let tagIdentifierPairs:[HLSTagIdentifierPair] = [(PantosTag.EXT_X_MEDIA, PantosValue.groupId),
                                                            (PantosTag.EXT_X_STREAM_INF, PantosValue.subtitlesGroup)]

}

// EXT-X-STREAM-INF - CLOSED-CAPTIONS The value is a quoted-string or an enumerated-string NONE. If the value is a quoted-string, it MUST match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist whose TYPE attribute is CLOSED-CAPTIONS. If it is NONE, all EXT-X-STREAM-INF tags MUST have this attribute with a value of NONE.
class EXT_X_STREAM_INFRenditionGroupCLOSEDCAPTIONSValidator: EXT_X_STREAM_INFRenditionGroupValidator {
    static let description:IssueDescription = IssueDescription.EXT_X_STREAM_INFRenditionGroupCLOSEDCAPTIONSValidator
    static let tagIdentifierPairs:[HLSTagIdentifierPair] = [(PantosTag.EXT_X_MEDIA, PantosValue.groupId),
                                                            (PantosTag.EXT_X_STREAM_INF, PantosValue.closedCaptionsGroup)]
}
