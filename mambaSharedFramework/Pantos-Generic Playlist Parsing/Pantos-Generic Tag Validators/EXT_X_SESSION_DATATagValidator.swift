//
//  EXT_X_SESSION_DATATagValidator.swift
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

class EXT_X_SESSION_DATATagValidator: PlaylistTagValidator {
    private var genericValidator: GenericDictionaryTagValidator

    init() {
        genericValidator = GenericDictionaryTagValidator(
            tag: PantosTag.EXT_X_SESSION_DATA,
            dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.dataId,
                    optional: false,
                    expectedType: String.self
                ),
                DictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.value,
                    optional: true,
                    expectedType: String.self
                ),
                DictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.uri,
                    optional: true,
                    expectedType: String.self
                ),
                DictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.format,
                    optional: true,
                    expectedType: SessionDataFormat.self
                ),
                DictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.language,
                    optional: true,
                    expectedType: String.self
                ),
            ]
        )
    }

    func validate(tag: PlaylistTag) -> [PlaylistValidationIssue]? {
        var issueList = genericValidator.validate(tag: tag) ?? []

        // Each EXT-X-SESSION-DATA tag MUST contain either a VALUE or URI attribute, but not both.
        switch (tag.value(forValueIdentifier: PantosValue.value), tag.value(forValueIdentifier: PantosValue.uri)) {
        case (.none, .some), (.some, .none):
            break
        case (.some, .some), (.none, .none):
            issueList.append(PlaylistValidationIssue(description: .EXT_X_SESSION_DATATagValidator, severity: .error))
        }

        return issueList.isEmpty ? nil : issueList
    }
}
