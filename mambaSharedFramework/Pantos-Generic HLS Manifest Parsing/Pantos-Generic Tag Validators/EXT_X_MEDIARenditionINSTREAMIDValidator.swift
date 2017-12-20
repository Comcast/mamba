//
//  EXT_X_MEDIARenditionINSTREAMIDValidator.swift
//  mamba
//
//  Created by Mohan on 1/17/17.
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

// INSTREAM-ID attribute is REQUIRED if the TYPE attribute is CLOSED-CAPTIONS
class EXT_X_MEDIARenditionINSTREAMIDValidator: HLSManifestTagGroupValidator {
    
    static let tagIdentifierPairs: [HLSTagIdentifierPair] = tagIdentifierPairsWithDefaultValueIdentifier(descriptors: [PantosTag.EXT_X_MEDIA])
    
    class var validation: ([HLSTag]) -> [HLSValidationIssue]? {
        return { (tags) -> [HLSValidationIssue]? in
            
            let variantPlaylistTag: [HLSTag]  = tags.filter { (tag) -> Bool in tag.value(forValueIdentifier: PantosValue.type) == HLSMediaType.Media.ClosedCaptions.rawValue  }
            for tag in variantPlaylistTag {
                guard let _ :String = tag.value(forValueIdentifier: PantosValue.instreamId) else {
                    return [HLSValidationIssue(description: IssueDescription.EXT_X_MEDIA_InstreamIdValidation, severity: IssueSeverity.error)]
                }
            }
            return nil
        }
    }
}
