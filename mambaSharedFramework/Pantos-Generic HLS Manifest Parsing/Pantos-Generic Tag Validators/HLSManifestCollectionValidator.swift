//
//  HLSManifestCollectionValidator.swift
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

typealias HLSTagIdentifierPair = (tagDescriptor: HLSTagDescriptor, valueIdentifier: HLSTagValueIdentifier)

protocol HLSManifestCollectionValidator: HLSManifestValidator {
    static var tagIdentifierPairs:[HLSTagIdentifierPair] { get }
    static var validation: ([HLSTag]) -> [HLSValidationIssue]? { get }
}

extension HLSManifestCollectionValidator {
    static internal var filter: (HLSTag) throws -> Bool {
        return { (tag) -> Bool in
            return self.tagIdentifierPairs.contains(where: { $0.tagDescriptor == tag.tagDescriptor })
        }
    }
    
    static func validate(hlsManifest: HLSManifestInterface) -> [HLSValidationIssue]? {
        let tags = (try? hlsManifest.tags.filter(filter)) ?? []
        return validation(tags)
    }
    
    internal static func tagIdentifierPairsWithDefaultValueIdentifier(descriptors:[HLSTagDescriptor]) -> [HLSTagIdentifierPair] {
        return descriptors.map { (descriptor) -> HLSTagIdentifierPair in
                return HLSTagIdentifierPair(descriptor,PantosValue.groupId)
            }
    }
}
