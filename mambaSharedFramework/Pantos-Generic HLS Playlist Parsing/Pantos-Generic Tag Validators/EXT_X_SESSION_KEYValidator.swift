//
//  EXT_X_SESSION_KEYValidator.swift
//  mamba
//
//  Created by Robert Galluccio on 8/31/24.
//  Copyright © 2024 Comcast Corporation.
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
//  limitations under the License. All rights reserved.
//

import Foundation

// All attributes defined for the EXT-X-KEY tag (Section 4.4.4.4) are also defined for the
// EXT-X-SESSION-KEY, except that the value of the METHOD attribute MUST NOT be NONE.
class EXT_X_SESSION_KEYValidator: EXT_X_KEYValidator {

    override public func validate(tag: HLSTag) -> [HLSValidationIssue]? {
        var issueList = super.validate(tag: tag) ?? []

        if let method = tag.value(forValueIdentifier: PantosValue.method) {
            if method == HLSEncryptionMethodType.EncryptionMethod.None.rawValue {
                issueList.append(
                    HLSValidationIssue(
                        description: IssueDescription.EXT_X_SESSION_KEYValidator,
                        severity: IssueSeverity.error
                    )
                )
            }
        }

        return issueList.isEmpty ? nil : issueList
    }
}
