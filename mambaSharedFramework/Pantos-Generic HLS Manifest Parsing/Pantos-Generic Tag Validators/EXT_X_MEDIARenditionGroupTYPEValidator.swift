//
//  EXT_X_MEDIARenditionGroupTYPEValidator.swift
//  mamba
//
//  Created by Philip McMahon on 11/4/16.
//  Copyright © 2016 Comcast Corporation.
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

// All EXT-X-MEDIA tags in the same group MUST have the same TYPE attribute.
class EXT_X_MEDIARenditionGroupTYPEValidator: HLSManifestTagGroupValidator {
    
    static let tagIdentifierPairs: [HLSTagIdentifierPair] = tagIdentifierPairsWithDefaultValueIdentifier(descriptors: [PantosTag.EXT_X_MEDIA])
    
    class var validation: ([HLSTag]) -> [HLSValidationIssue]? {
        return { (tags: [HLSTag]) -> [HLSValidationIssue]? in
            
            let type: String? = tags.first?.value(forValueIdentifier: PantosValue.type)
            let count = tags.filter({ (tag) -> Bool in
                return tag.value(forValueIdentifier: PantosValue.type) == type
            }).count
            
            if (count != tags.count) {
                return [HLSValidationIssue(description: .EXT_X_MEDIARenditionGroupTYPEValidator, severity: IssueSeverity.error)]
            }
            
            return nil
        }
    }
}
