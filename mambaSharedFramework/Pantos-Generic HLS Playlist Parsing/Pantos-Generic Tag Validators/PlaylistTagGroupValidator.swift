//
//  PlaylistTagGroupValidator.swift
//  mamba
//
//  Created by Philip McMahon on 10/19/16.
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

protocol CorePlaylistGroupByValidator: TagIdentifierPairsOwner {}

extension CorePlaylistGroupByValidator {
    internal static func groupBy(tags: [HLSTag]) -> [String:[HLSTag]] {
        var groups = [String:[HLSTag]]()
        for tag in tags {
            for pair in Self.tagIdentifierPairs {
                if pair.tagDescriptor == tag.tagDescriptor {
                    if let groupId: String = tag.value(forValueIdentifier: pair.valueIdentifier) {
                        var group = groups[groupId] ?? [HLSTag]()
                        group.append(tag)
                        groups[groupId] = group
                        break
                    }
                }
            }
        }
        return groups
    }
}

protocol MasterPlaylistTagGroupValidator: MasterPlaylistCollectionValidator, CorePlaylistGroupByValidator {
}

extension MasterPlaylistTagGroupValidator {
    
    static func validate(masterPlaylist: MasterPlaylistInterface) -> [HLSValidationIssue] {
        let tags = (try? masterPlaylist.tags.filter(self.filter)) ?? []
        let groups = groupBy(tags: tags)
        var issues = [HLSValidationIssue]()
        for group in groups {
            let groupIssues = validation(group.value)
            issues += groupIssues
        }
        return issues
    }
}

protocol VariantPlaylistTagGroupValidator: VariantPlaylistCollectionValidator, CorePlaylistGroupByValidator {
}

extension VariantPlaylistTagGroupValidator {
    
    static func validate(variantPlaylist: VariantPlaylistInterface) -> [HLSValidationIssue] {
        let tags = (try? variantPlaylist.tags.filter(self.filter)) ?? []
        let groups = groupBy(tags: tags)
        var issues = [HLSValidationIssue]()
        for group in groups {
            let groupIssues = validation(group.value)
            issues += groupIssues
        }
        return issues
    }
}

protocol NoOpCoreValidation {}

extension NoOpCoreValidation {
    static var validation: ([HLSTag]) -> [HLSValidationIssue] {
        return { _ in return [HLSValidationIssue]() }
    }
}

protocol VariantTagCrossGroupValidator: VariantPlaylistTagGroupValidator, NoOpCoreValidation {
    static var crossGroupValidation: ([String:[HLSTag]]) -> [HLSValidationIssue] { get }
}

extension VariantTagCrossGroupValidator {
    static func validate(variantPlaylist: VariantPlaylistInterface) -> [HLSValidationIssue]? {
        let tags = (try? variantPlaylist.tags.filter(self.filter)) ?? []
        let groups = groupBy(tags: tags)
        return crossGroupValidation(groups)
    }
}
