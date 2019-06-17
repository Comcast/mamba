//
//  EXT_X_MEDIARenditionGroupDEFAULTValidator.swift
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

// A group MUST NOT have more than one member with a DEFAULT attribute of YES.
class EXT_X_MEDIARenditionGroupDEFAULTValidator: MasterPlaylistTagGroupValidator {
    static let tagIdentifierPairs: [TagIdentifierPair] = tagIdentifierPairsWithDefaultValueIdentifier(descriptors: [PantosTag.EXT_X_MEDIA])
    
    class var validation: ([PlaylistTag]) -> [PlaylistValidationIssue] {
        return { (tags) -> [PlaylistValidationIssue] in
            
            let count = tags.reduce(0) { return $1.value(forValueIdentifier: PantosValue.defaultMedia) == Bool.YesNo.Yes.rawValue ? $0 + 1 : $0 }
            if (count > 1) {
                return [PlaylistValidationIssue(description: .EXT_X_MEDIARenditionGroupDEFAULTValidator, severity: IssueSeverity.error)]
            }
            
            return [PlaylistValidationIssue]()
        }
    }
}
