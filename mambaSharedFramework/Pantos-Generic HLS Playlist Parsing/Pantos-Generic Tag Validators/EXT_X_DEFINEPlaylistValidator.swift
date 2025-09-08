//
//  EXT_X_DEFINEPlaylistValidator.swift
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

class EXT_X_DEFINEPlaylistValidator: HLSPlaylistValidator {
    static func validate(hlsPlaylist: any HLSPlaylistInterface) -> [HLSValidationIssue]? {
        let tagValidator = EXT_X_DEFINETagValidator()
        var validationIssues = [HLSValidationIssue]()
        var variableNames = Set<String>()

        for tag in hlsPlaylist.tags where tag.tagDescriptor == PantosTag.EXT_X_DEFINE {
            // An EXT-X-DEFINE tag MUST contain either a NAME, an IMPORT, or a QUERYPARAM attribute, but only one of the
            // three. Otherwise, the client MUST fail to parse the Playlist.
            let fatalTagIssues = (tagValidator.validate(tag: tag) ?? []).filter {
                $0.description == IssueDescription.EXT_X_DEFINENoNameNorImportNorQueryparam.rawValue ||
                $0.description == IssueDescription.EXT_X_DEFINEMoreThanOneOfNameImportOrQueryParam.rawValue
            }
            validationIssues.append(contentsOf: fatalTagIssues)

            var variableName: String?
            switch DefineVariableName(tag: tag) {
            case let .name(value):
                variableName = value
            case let .import(value):
                variableName = value
                // EXT-X-DEFINE tags containing the IMPORT attribute MUST NOT occur in Multivariant Playlists; they are
                // only allowed in Media Playlists.
                switch hlsPlaylist.type {
                case .master:
                    validationIssues.append(
                        HLSValidationIssue(
                            description: .EXT_X_DEFINEImportInMultivariant,
                            severity: .error
                        )
                    )
                case .media, .unknown:
                    break
                }
            case let .queryparam(value):
                variableName = value
                // If the QUERYPARAM attribute value does not match any query parameter in the URI or the matching
                // parameter has no associated value, the parser MUST fail to parse the Playlist.
                if
                    let playlist = (hlsPlaylist as? HLSPlaylist),
                    let urlComponents = URLComponents(url: playlist.url, resolvingAgainstBaseURL: true)
                {
                    let queryItems = urlComponents.queryItems ?? []
                    if !queryItems.contains(where: { $0.name == value && !($0.value ?? "").isEmpty }) {
                        validationIssues.append(
                            HLSValidationIssue(
                                description: .EXT_X_DEFINENoQueryParameterValue,
                                severity: .error
                            )
                        )
                    }
                }
            case .none:
                break // This issue will already have been added in the check above.
            }
            // An EXT-X-DEFINE tag MUST NOT specify the same Variable Name as any other EXT-X-DEFINE tag in the same
            // Playlist. Parsers that encounter duplicate Variable Name declarations MUST fail to parse the Playlist.
            if let variableName {
                if variableNames.contains(variableName) {
                    validationIssues.append(
                        HLSValidationIssue(
                            description: .EXT_X_DEFINEDuplicateDefinition,
                            severity: .error
                        )
                    )
                } else {
                    variableNames.insert(variableName)
                }
            }
        }

        return validationIssues.isEmpty ? nil : validationIssues
    }
}

extension EXT_X_DEFINEPlaylistValidator {
    private enum DefineVariableName {
        case name(String)
        case `import`(String)
        case queryparam(String)

        init?(tag: HLSTag) {
            if let v = tag.value(forValueIdentifier: PantosValue.name) {
                self = .name(v)
            } else if let v = tag.value(forValueIdentifier: PantosValue.import) {
                self = .import(v)
            } else if let v = tag.value(forValueIdentifier: PantosValue.queryparam) {
                self = .queryparam(v)
            } else {
                return nil
            }
        }
    }
}
