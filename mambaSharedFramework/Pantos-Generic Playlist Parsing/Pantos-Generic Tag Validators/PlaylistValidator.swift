//
//  PlaylistValidator.swift
//  mamba
//
//  Created by David Coufal on 3/13/19.
//  Copyright © 2019 Comcast Corporation.
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

public protocol ExtensiblePlaylistValidator: ExtensibleMasterPlaylistValidator, ExtensibleVariantPlaylistValidator {}

public extension ExtensiblePlaylistValidator {
    
    /**
     Runs all playlist tags through their respective validators (if present) and returns
     all found issues.
     
     - parameter playlist: A `PlaylistInterface` to validate
     
     - returns: An array of `PlaylistValidationIssue`s. Will be empty if no issues are found.
     */
    static func validateTags(fromPlaylist playlist: PlaylistInterface) -> [PlaylistValidationIssue] {
        
        var issues = [PlaylistValidationIssue]()
        
        for tag in playlist.tags {
            guard let validator = playlist.registeredTags.validator(forTag: tag.tagDescriptor) else {
                continue
            }
            guard let newIssues = validator.validate(tag: tag) else {
                continue
            }
            
            issues += newIssues
        }

        return issues
    }
    
    static func validate(masterPlaylist: MasterPlaylistInterface) -> [PlaylistValidationIssue] {
        return validateTags(fromPlaylist: masterPlaylist) + combinedValidation(ofMasterPlaylist: masterPlaylist)
    }

    static func validate(variantPlaylist: VariantPlaylistInterface) -> [PlaylistValidationIssue] {
        return validateTags(fromPlaylist: variantPlaylist) + combinedValidation(ofVariantPlaylist: variantPlaylist)
    }
}

public class PlaylistValidator: ExtensiblePlaylistValidator {
    
    public static let masterPlaylistValidators: [MasterPlaylistValidator.Type] = [PlaylistRenditionGroupValidator.self,
                                                                                  EXT_X_STREAM_INFRenditionGroupAUDIOValidator.self,
                                                                                  EXT_X_STREAM_INFRenditionGroupVIDEOValidator.self,
                                                                                  EXT_X_STREAM_INFRenditionGroupSUBTITLESValidator.self,
                                                                                  PlaylistRenditionGroupMatchingNAMELANGUAGEValidator.self,
                                                                                  PlaylistRenditionGroupMatchingPROGRAM_IDValidator.self]
    
    public static let variantPlaylistValidators: [VariantPlaylistValidator.Type] = [PlaylistAggregateTagCardinalityValidator.self,
                                                                                    EXT_X_TARGETDURATIONLengthValidator.self,
                                                                                    EXT_X_STARTTimeOffsetValidator.self]
}
