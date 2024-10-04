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
struct EXT_X_SESSION_KEYValidator: PlaylistTagValidator {
    private let keyValidator: EXT_X_KEYValidator

    init() {
        keyValidator = EXT_X_KEYValidator(tag: PantosTag.EXT_X_SESSION_KEY, dictionaryValueIdentifiers: [
            DictionaryTagValueIdentifierImpl(valueId: PantosValue.method,
                                             optional: false,
                                             expectedType: EncryptionMethodType.self),
            DictionaryTagValueIdentifierImpl(valueId: PantosValue.uri,
                                             optional: false, // URI is REQUIRED since METHOD can't be NONE
                                             expectedType: String.self),
            DictionaryTagValueIdentifierImpl(valueId: PantosValue.ivector,
                                             optional: true,
                                             expectedType: String.self),
            DictionaryTagValueIdentifierImpl(valueId: PantosValue.keyformat,
                                             optional: true,
                                             expectedType: String.self),
            DictionaryTagValueIdentifierImpl(valueId: PantosValue.keyformatVersions,
                                             optional: true,
                                             expectedType: String.self)
        ])
    }

    public func validate(tag: PlaylistTag) -> [PlaylistValidationIssue]? {
        var issueList = keyValidator.validate(tag: tag) ?? []

        if let method = tag.value(forValueIdentifier: PantosValue.method) {
            if method == EncryptionMethodType.EncryptionMethod.None.rawValue {
                issueList.append(
                    PlaylistValidationIssue(
                        description: IssueDescription.EXT_X_SESSION_KEYValidator,
                        severity: IssueSeverity.error
                    )
                )
            }
        }

        return issueList.isEmpty ? nil : issueList
    }
}
