//
//  EXT_X_TARGETDURATIONLengthValidator.swift
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

// The EXT-X-TARGETDURATION tag specifies the maximum media segment duration. The EXTINF duration of each media segment in the Playlist file MUST be less than or equal to the target duration.
class EXT_X_TARGETDURATIONLengthValidator: HLSPlaylistOneToManyValidator {
    
    static let oneTagDescriptor:HLSTagDescriptor = PantosTag.EXT_X_TARGETDURATION
    static let manyTagDescriptor:HLSTagDescriptor = PantosTag.EXTINF
    
    class var validation: (HLSTag?, [HLSTag]?) -> [HLSValidationIssue]? {
        
        return { (one, many) -> [HLSValidationIssue]? in
            
            guard let one = one,
                let many = many,
                let max: CMTime = one.value(forValueIdentifier: PantosValue.targetDurationSeconds)
                else { return nil }
            
            for tag in many {
                if tag.duration > max {
                    return [HLSValidationIssue(description: IssueDescription.EXT_X_TARGETDURATIONLengthValidator, severity: IssueSeverity.error)]
                }
            }
            
            return nil
        }
    }
}
