//
//  EXT_X_DEFINEValidator.swift
//  mamba
//
//  Created by Robert Galluccio on 11/30/24.
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

class EXT_X_DEFINETagValidator: HLSTagValidator {
    private let genericValidator: GenericDictionaryTagValidator

    init() {
        genericValidator = GenericDictionaryTagValidator(
            tag: PantosTag.EXT_X_DEFINE,
            dictionaryValueIdentifiers: [
                HLSDictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.name,
                    optional: true,
                    expectedType: String.self
                ),
                HLSDictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.value,
                    optional: true,
                    expectedType: String.self
                ),
                HLSDictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.import,
                    optional: true,
                    expectedType: String.self
                ),
                HLSDictionaryTagValueIdentifierImpl(
                    valueId: PantosValue.queryparam,
                    optional: true,
                    expectedType: String.self
                )
            ]
        )
    }

    func validate(tag: HLSTag) -> [HLSValidationIssue]? {
        var validationIssues = [HLSValidationIssue]()

        // An EXT-X-DEFINE tag MUST contain either a NAME, an IMPORT, or a QUERYPARAM attribute, but only one of the
        // three.
        switch (value(tag, .name), value(tag, .import), value(tag, .queryparam)) {
        // Split out NAME separately as we need to validate further that VALUE is present
        case (.some, .none, .none):
            // [The VALUE] attribute is REQUIRED if the EXT-X-DEFINE tag has a NAME attribute.
            if tag.value(forValueIdentifier: PantosValue.value) == nil {
                validationIssues.append(HLSValidationIssue(description: .EXT_X_DEFINENameWithNoValue, severity: .error))
            }
        // There is an issue if none of NAME, IMPORT, nor QUERYPARAM are present
        case (.none, .none, .none):
            validationIssues.append(
                HLSValidationIssue(
                    description: .EXT_X_DEFINENoNameNorImportNorQueryparam,
                    severity: .error
                )
            )
        // There is an issue if more than one of NAME, IMPORT, or QUERYPARAM are present
        case (.some, .some, _), (_, .some, .some), (.some, _, .some):
            validationIssues.append(
                HLSValidationIssue(
                    description: .EXT_X_DEFINEMoreThanOneOfNameImportOrQueryParam,
                    severity: .error
                )
            )
        // No issues with either only IMPORT or only QUERYPARAM
        case (.none, .some, .none), (.none, .none, .some):
            break
        }

        return validationIssues.isEmpty ? nil : validationIssues
    }

    /// Convenience method for getting a `PantosValue`
    ///
    /// Using this method to allow for the switch statement above to be more concise.
    /// - Parameter pantosValue: Value to search for
    /// - Returns: String value if it exists
    private func value(_ tag: HLSTag, _ pantosValue: PantosValue) -> String? {
        tag.value(forValueIdentifier: pantosValue)
    }
}
