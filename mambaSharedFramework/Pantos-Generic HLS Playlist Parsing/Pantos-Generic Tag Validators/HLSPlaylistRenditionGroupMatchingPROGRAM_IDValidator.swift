//
//  HLSPlaylistRenditionGroupMatchingPROGRAM_IDValidator.swift
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

// Variant Playlists MUST contain an EXT-X-STREAM-INF tag or EXT-X-I-FRAME-STREAM-INF tag for each variant stream. Each tag identifying an encoding of the same presentation MUST have the same PROGRAM-ID attribute value.
class HLSPlaylistRenditionGroupMatchingPROGRAM_IDValidator: HLSPlaylistCollectionValidator {
    
   static let tagIdentifierPairs: [HLSTagIdentifierPair] = [(tagDescriptor: PantosTag.EXT_X_STREAM_INF, valueIdentifier: PantosValue.programId),
                                                            (tagDescriptor: PantosTag.EXT_X_I_FRAME_STREAM_INF, valueIdentifier: PantosValue.programId)]

    class var validation: ([HLSTag]) -> [HLSValidationIssue]? {
        get {
            return { (tags: [HLSTag]) -> [HLSValidationIssue]? in
                
                guard let programId: String = tags.first?.value(forValueIdentifier: PantosValue.programId) else {
                    return nil
                }
                
                for tag in tags {
                    if tag.value(forValueIdentifier: PantosValue.programId) != programId {
                        return [HLSValidationIssue(description: IssueDescription.HLSPlaylistRenditionGroupMatchingPROGRAM_IDValidator, severity: IssueSeverity.error)]
                    }
                }
                return nil
            }
        }
    }
}
