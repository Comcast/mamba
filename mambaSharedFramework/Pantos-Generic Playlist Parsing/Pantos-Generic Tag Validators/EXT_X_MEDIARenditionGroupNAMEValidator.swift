//
//  EXT_X_MEDIARenditionGroupNAMEValidator.swift
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

// All EXT-X-MEDIA tags in the same group MUST have different NAME attributes.
class EXT_X_MEDIARenditionGroupNAMEValidator: MasterPlaylistTagGroupValidator {
    
    static let tagIdentifierPairs: [TagIdentifierPair] = tagIdentifierPairsWithDefaultValueIdentifier(descriptors: [PantosTag.EXT_X_MEDIA])
    
    class var validation: ([PlaylistTag]) -> [PlaylistValidationIssue] {
        return { (tags) -> [PlaylistValidationIssue] in
            
            let uniqueValues = tags.reduce(Set<String>()) { (result, tag) in
                var r = result
                if let value: String = tag.value(forValueIdentifier: PantosValue.name) {
                    r.insert(value)
                }
                return r
            }
            
            if (tags.count != uniqueValues.count) {
                return [PlaylistValidationIssue(description: .EXT_X_MEDIARenditionGroupNAMEValidator,
                                                severity: IssueSeverity.error)]
            }
            
            return [PlaylistValidationIssue]()
        }
    }
    
}
