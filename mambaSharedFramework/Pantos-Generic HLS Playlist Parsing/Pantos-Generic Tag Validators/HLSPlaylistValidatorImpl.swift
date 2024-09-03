//
//  HLSExtensibleValidator.swift
//  mamba
//
//  Created by Mohan on 8/7/16.
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

/// A protocol for HLSPlaylistValidator that is a superset of other validators.
public protocol HLSExtensibleValidator: HLSPlaylistValidator {
    /// An array of HLSValidator types that will be used to validate playlists
    static var validators:[HLSValidator.Type] { get }
}

/**
 Default implementation of HLSExtensibleValidator.
 
 It will take a HLSPlaylistInterface, apply tag validators to all the tags, and then try to validate the
 entire playlist against all the validators in the `validators` array.
 */
public extension HLSExtensibleValidator {
    
    static func validate(hlsPlaylist: HLSPlaylistInterface) -> [HLSValidationIssue]? {
        var validationIssueList:[HLSValidationIssue] = []
        
        // tags
        for tag in hlsPlaylist.tags{
            guard let validator = hlsPlaylist.registeredTags.validator(forTag: tag.tagDescriptor) else {
                continue
            }
            guard let validationResponse = validator.validate(tag: tag) else {
                continue
            }
            
            validationIssueList += validationResponse
        }
        
        // playlist
        if let validationIssues = validateInternal(hlsPlaylist: hlsPlaylist) {
            validationIssueList += validationIssues
        }
        
        return validationIssueList.isEmpty ? nil : validationIssueList
    }
    
    static fileprivate func validateInternal(hlsPlaylist: HLSPlaylistInterface) -> [HLSValidationIssue]? {
        var issues:[HLSValidationIssue] = []
        
        for validator in validators{
            if let playlistValidator = validator as? HLSPlaylistValidator.Type {
                guard let validatorIssues = playlistValidator.validate(hlsPlaylist: hlsPlaylist) else { continue }
                issues += validatorIssues
                continue
            }
        }
        
        return issues.isEmpty ? nil : issues
    }
}

/// Validator for master playlists
public class HLSMasterPlaylistValidator: HLSExtensibleValidator {
    public static let validators:[HLSValidator.Type] = [HLSPlaylistRenditionGroupValidator.self,
                                                EXT_X_STREAM_INFRenditionGroupAUDIOValidator.self,
                                                EXT_X_STREAM_INFRenditionGroupVIDEOValidator.self,
                                                EXT_X_STREAM_INFRenditionGroupSUBTITLESValidator.self,
                                                EXT_X_SESSION_DATAPlaylistValidator.self]
}

/// Validator for variant playlists
public class HLSVariantPlaylistValidator: HLSExtensibleValidator {
    public static let validators:[HLSValidator.Type] = [HLSPlaylistAggregateTagCardinalityValidator.self,
                                                        EXT_X_TARGETDURATIONLengthValidator.self,
                                                        HLSPlaylistRenditionGroupMatchingPROGRAM_IDValidator.self,
                                                        HLSPlaylistRenditionGroupMatchingNAMELANGUAGEValidator.self,
                                                        EXT_X_STARTTimeOffsetValidator.self,
                                                        EXT_X_DATERANGEPlaylistValidator.self]
}

/// A general purpose validator that will validate either a variant or a master playlist
public class HLSCompletePlaylistValidator: HLSPlaylistValidator {

    public static func validate(hlsPlaylist: HLSPlaylistInterface) -> [HLSValidationIssue]? {
        switch hlsPlaylist.type {
        case .media:
            return HLSVariantPlaylistValidator.validate(hlsPlaylist: hlsPlaylist)
        case .master:
            return HLSMasterPlaylistValidator.validate(hlsPlaylist: hlsPlaylist)
        default:
            return nil
        }
    }
}
