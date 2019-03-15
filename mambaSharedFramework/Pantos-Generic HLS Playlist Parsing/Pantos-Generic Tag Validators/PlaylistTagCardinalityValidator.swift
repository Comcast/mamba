//
//  PlaylistAggregateTagCardinalityValidator.swift
//  mamba
//
//  Created by Philip McMahon on 10/18/16.
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

// This is an aggregate validator that encapsulates all of the Cardinality validations so that for efficiencies sake, we are only filtering over the tags once.
class PlaylistAggregateTagCardinalityValidator: VariantPlaylistValidator {
    
    static let validations: [PlaylistTagCardinalityValidation.Type] = [EXT_X_MEDIA_SEQUENCEValidation.self,
                                                                       EXT_X_DISCONTINUITY_SEQUENCEValidation.self,
                                                                       EXT_X_ENDLISTValidation.self,
                                                                       EXT_X_VERSIONValidation.self,
                                                                       EXT_X_TARGETDURATIONValidation.self]
    
    
    public static func validate(variantPlaylist: VariantPlaylistInterface) -> [HLSValidationIssue] {
        var issues = [HLSValidationIssue]()
        let validator = PlaylistCardinalityValidator()
        let tags = variantPlaylist.tags.filter { (tag) -> Bool in validations.contains(where: { $0.tagDescriptor == tag.tagDescriptor }) }
        for validation in validations {
            if let issue = validator.validate(validation: validation, tags: tags) { issues.append(issue) }
        }
        return issues

    }
}

class PlaylistCardinalityValidator {
    
    func validate(validation: PlaylistTagCardinalityValidation.Type, tags: [HLSTag]) -> HLSValidationIssue? {

        let count = tags.filter { (tag) -> Bool in tag.tagDescriptor == validation.tagDescriptor }.count
        if count < validation.min || count > validation.max {
            return HLSValidationIssue(description: validation.description, severity: IssueSeverity.error)
        }
        
        return nil
    }
}

// "A Playlist file MUST NOT contain more than one EXT-X-MEDIA-SEQUENCE tag."
class EXT_X_MEDIA_SEQUENCEValidation: PlaylistTagCardinalityValidation {
    
    static let min = 0
    static let max = 1
    static let description: IssueDescription = .EXT_X_MEDIA_SEQUENCEValidation
    static let tagDescriptor: HLSTagDescriptor = PantosTag.EXT_X_MEDIA_SEQUENCE
}

// "A Playlist file MUST NOT contain more than one EXT-X-DISCONTINUITY-SEQUENCE."
class EXT_X_DISCONTINUITY_SEQUENCEValidation: PlaylistTagCardinalityValidation {
    
    static let min = 0
    static let max = 1
    static let description: IssueDescription = .EXT_X_DISCONTINUITY_SEQUENCEValidator
    static let tagDescriptor: HLSTagDescriptor = PantosTag.EXT_X_DISCONTINUITY_SEQUENCE
}

// "EXT-X-ENDLIST It MAY occur anywhere in the Playlist file; it MUST NOT occur more than once."
class EXT_X_ENDLISTValidation: PlaylistTagCardinalityValidation {
    
    static let min = 0
    static let max = 1
    static let description: IssueDescription = .EXT_X_ENDLISTValidation
    static let tagDescriptor: HLSTagDescriptor = PantosTag.EXT_X_ENDLIST
}

// "A Playlist file MUST NOT contain more than one EXT-X-VERSION tag. A Playlist file that does not contain an EXT-X-VERSION tag MUST comply with version 1 of this protocol."
class EXT_X_VERSIONValidation: PlaylistTagCardinalityValidation {
    
    static let min = 0
    static let max = 1
    static let description: IssueDescription = .EXT_X_VERSIONValidation
    static let tagDescriptor: HLSTagDescriptor = PantosTag.EXT_X_VERSION
}

// "EXT-X-TARGETDURATION - This tag MUST appear once in the Playlist file."
class EXT_X_TARGETDURATIONValidation: PlaylistTagCardinalityValidation {
    
    static let min = 1
    static let max = 1
    static let description: IssueDescription = .EXT_X_TARGETDURATIONValidation
    static let tagDescriptor: HLSTagDescriptor = PantosTag.EXT_X_TARGETDURATION
}
