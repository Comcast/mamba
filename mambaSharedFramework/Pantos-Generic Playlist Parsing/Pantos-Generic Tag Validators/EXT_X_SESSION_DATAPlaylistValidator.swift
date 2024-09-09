//
//  EXT_X_SESSION_DATAPlaylistValidator.swift
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

final class EXT_X_SESSION_DATAPlaylistValidator: MasterPlaylistValidator {
    static func validate(masterPlaylist: any MasterPlaylistInterface) -> [PlaylistValidationIssue] {
        var issues = [PlaylistValidationIssue]()

        if let issue = duplicateIssue(
            tags: masterPlaylist.tags.filter { $0.tagDescriptor == PantosTag.EXT_X_SESSION_DATA }
        ) {
            issues.append(issue)
        }

        return issues
    }

    // A Playlist MAY contain multiple EXT-X-SESSION-DATA tags with the same DATA-ID attribute. A Playlist MUST NOT
    // contain more than one EXT-X-SESSION-DATA tag with the same DATA-ID attribute and the same LANGUAGE attribute.
    private static func duplicateIssue(tags: [PlaylistTag]) -> PlaylistValidationIssue? {
        var dataIdToLanguagesMap = [String: [String?]]()
        for tag in tags {
            guard let dataId = tag.value(forValueIdentifier: PantosValue.dataId) else { continue }
            var existingLanguages = dataIdToLanguagesMap[dataId] ?? []
            existingLanguages.append(tag.value(forValueIdentifier: PantosValue.language))
            dataIdToLanguagesMap[dataId] = existingLanguages
        }
        for languages in dataIdToLanguagesMap.values {
            if languages.count != Set(languages).count {
                return PlaylistValidationIssue(description: .EXT_X_SESSION_DATAPlaylistValidator, severity: .error)
            }
        }
        return nil
    }
}
