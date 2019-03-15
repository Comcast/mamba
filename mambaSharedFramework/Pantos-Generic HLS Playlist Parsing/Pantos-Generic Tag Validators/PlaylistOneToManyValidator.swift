//
//  PlaylistOneToManyValidator.swift
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

protocol CorePlaylistOneToManyValidator {
    static var oneTagDescriptor: HLSTagDescriptor { get }
    static var manyTagDescriptor: HLSTagDescriptor { get }
    static var validation: (HLSTag?, [HLSTag]?) -> [HLSValidationIssue] { get }
}

extension CorePlaylistOneToManyValidator {
    static var filter: (HLSTag) throws -> Bool {
        return { (tag) -> Bool in
            return manyTagDescriptor == tag.tagDescriptor
        }
    }
}

protocol MasterPlaylistOneToManyValidator: MasterPlaylistValidator, CorePlaylistOneToManyValidator {}

extension MasterPlaylistOneToManyValidator {
    static func validate(masterPlaylist: MasterPlaylistInterface) -> [HLSValidationIssue] {
        let many = try? masterPlaylist.tags.filter(self.filter)
        var one: HLSTag?
        for tag in masterPlaylist.tags { if tag.tagDescriptor == self.oneTagDescriptor { one = tag; break } }
        return validation(one, many)
    }
}

protocol VariantPlaylistOneToManyValidator: VariantPlaylistValidator, CorePlaylistOneToManyValidator {}

extension VariantPlaylistOneToManyValidator {
    static func validate(variantPlaylist: VariantPlaylistInterface) -> [HLSValidationIssue] {
        let many = try? variantPlaylist.tags.filter(self.filter)
        var one: HLSTag?
        for tag in variantPlaylist.tags { if tag.tagDescriptor == self.oneTagDescriptor { one = tag; break } }
        return validation(one, many)
    }
}
