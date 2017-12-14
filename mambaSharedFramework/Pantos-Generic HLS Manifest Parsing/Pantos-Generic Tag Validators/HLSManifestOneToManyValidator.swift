//
//  HLSManifestOneToManyValidator.swift
//  mamba
//
//  Created by Philip McMahon on 11/3/16.
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

protocol HLSManifestOneToManyValidator: HLSManifestValidator {
    static var oneTagDescriptor: HLSTagDescriptor { get }
    static var manyTagDescriptor: HLSTagDescriptor { get }
    static var validation: (HLSTag?, [HLSTag]?) -> [HLSValidationIssue]? { get }
}

extension HLSManifestOneToManyValidator {
    static var filter: (HLSTag) throws -> Bool {
        return { (tag) -> Bool in
            return manyTagDescriptor == tag.tagDescriptor
        }
    }
    
    static func validate(hlsManifest: HLSManifestInterface) -> [HLSValidationIssue]? {
        let many = try? hlsManifest.tags.filter(self.filter)
        var one: HLSTag?
        for tag in hlsManifest.tags { if tag.tagDescriptor == self.oneTagDescriptor { one = tag; break } }
        return validation(one, many)
    }
}
