//
//  EXT_X_KEYValidator.swift
//  mamba
//
//  Created by Philip McMahon on 11/2/16.
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

// EXT-X-KEY If the encryption method is NONE, the URI, IV, KEYFORMAT and KEYFORMATVERSIONS attributes MUST NOT be present. 
// If the encryption method is AES-128 or SAMPLE-AES, the URI attribute MUST be present.
public class EXT_X_KEYValidator: GenericDictionaryTagValidator {
    
    override public func validate(tag: HLSTag) -> [HLSValidationIssue]? {
        
        var issueList = super.validate(tag: tag) ?? []
        
        if let value: String = tag.value(forValueIdentifier: PantosValue.method) {
            
            let uri: String? = tag.value(forValueIdentifier: PantosValue.uri)
            let iv: String? = tag.value(forValueIdentifier: PantosValue.ivector)
            let keyformat: String? = tag.value(forValueIdentifier: PantosValue.keyformat)
            let keyformatVersions: String? = tag.value(forValueIdentifier: PantosValue.keyformatVersions)
            
            switch value {

            case HLSEncryptionMethodType.EncryptionMethod.None.rawValue:
                if uri != nil || iv != nil || keyformat != nil || keyformatVersions != nil {
                    issueList.append(HLSValidationIssue(description: IssueDescription.EXT_X_KEYValidator, severity: IssueSeverity.error))
                }
            case HLSEncryptionMethodType.EncryptionMethod.AES128.rawValue:
                fallthrough
            case HLSEncryptionMethodType.EncryptionMethod.SampleAES.rawValue:
                guard let _ = uri else {
                    issueList.append(HLSValidationIssue(description: IssueDescription.EXT_X_KEYValidator, severity: IssueSeverity.error))
                    break
                }
            default: break
            }
            
        }
        return issueList.isEmpty ? nil : issueList
    }
}
