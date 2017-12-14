//
//  HLSManifestRenditionGroupValidator.swift
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

// This is an aggregate validator that encapsulates all of the Rendition Group validators so that we are only filtering and grouping the the tags once.
class HLSManifestRenditionGroupValidator: HLSManifestTagGroupValidator {

    static let tagIdentifierPairs: [HLSTagIdentifierPair] = tagIdentifierPairsWithDefaultValueIdentifier(descriptors: [PantosTag.EXT_X_MEDIA])
    
    static let validators: [HLSManifestTagGroupValidator.Type] = [EXT_X_MEDIARenditionGroupTYPEValidator.self,
                                                                  EXT_X_MEDIARenditionGroupNAMEValidator.self,
                                                                  EXT_X_MEDIARenditionGroupDEFAULTValidator.self,
                                                                  EXT_X_MEDIARenditionGroupAUTOSELECTValidator.self,
                                                                  EXT_X_MEDIARenditionINSTREAMIDValidator.self,
                                                                  HLSManifestRenditionGroupAUDIOValidator.self,
                                                                  HLSManifestRenditionGroupVIDEOValidator.self]
    
    class var validation: ([HLSTag]) -> [HLSValidationIssue]? {
        
        return { (tags) -> [HLSValidationIssue]? in
            
            var issues:[HLSValidationIssue] = []
            for validator in validators {
                if let validatorIssues = validator.validation(tags) {
                    issues += validatorIssues
                }
            }
            
            return issues.isEmpty ? nil : issues
        }
    }
}














