//
//  HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator.swift
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

// A Playlist MAY contain multiple groups of the same TYPE in order to provide multiple encodings of each rendition. If it does so, each group of the same TYPE SHOULD contain corresponding members with the same NAME attribute, LANGUAGE attribute, and rendition.
class HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator: HLSPlaylistTagCrossGroupValidator {
    static let tagIdentifierPairs: [HLSTagIdentifierPair] = tagIdentifierPairsWithDefaultValueIdentifier(descriptors: [PantosTag.EXT_X_MEDIA])
    
    static var crossGroupValidation: ([String:[HLSTag]]) -> [HLSValidationIssue]? {
        return { (groups: [String:[HLSTag]]) -> [HLSValidationIssue]? in
            var issues:[HLSValidationIssue] = []
            var names:Set<String>?
            var languages: Set<String>?
            for tags in groups.values {
                if let names = names, let languages = languages {
                    let localNames = tags.extractValues(tagDescriptor: PantosTag.EXT_X_MEDIA, valueIdentifier: PantosValue.name)
                    let localLanguages = tags.extractValues(tagDescriptor: PantosTag.EXT_X_MEDIA, valueIdentifier: PantosValue.language)
                    
                    if localNames.count != names.count || localLanguages.count != languages.count {
                        issues += [HLSValidationIssue(description: IssueDescription.HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator, severity: IssueSeverity.error)]
                    }
                    
                    for localName in localNames {
                        if !names.contains(where: { (name) -> Bool in return localName == name }) {
                            issues += [HLSValidationIssue(description: IssueDescription.HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator, severity: IssueSeverity.error)]
                        }
                    }
                    
                    for localLanguage in localLanguages {
                        if !languages.contains(where: { (language) -> Bool in return localLanguage == language }) {
                            issues += [HLSValidationIssue(description: IssueDescription.HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator, severity: IssueSeverity.error)]
                        }
                    }
                }
                else {
                    names = tags.extractValues(tagDescriptor: PantosTag.EXT_X_MEDIA, valueIdentifier: PantosValue.name)
                    languages = tags.extractValues(tagDescriptor: PantosTag.EXT_X_MEDIA, valueIdentifier: PantosValue.language)
                }
            }
            return issues.isEmpty ? nil : issues
        }
    }
}
