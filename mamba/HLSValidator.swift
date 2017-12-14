//
//  HLSValidator.swift
//  mamba
//
//  Created by Mohan on 8/4/16.
//  Copyright © 2016 Comcast Corporation. This software and its contents are
//  Comcast confidential and proprietary. It cannot be used, disclosed, or
//  distributed without Comcast's prior written permission. Modification of this
//  software is only allowed at the direction of Comcast Corporation. All allowed
//  modifications must be provided to Comcast Corporation. All rights reserved.
//

import Foundation

/// Namespace class for validating HLS manifests
public class HLSValidator {
    
    public init() {}
    
    /// Takes a HLS manifest object and validates it. Returns the HLSValidationIssues list with error description and severity
    public func validate(hlsManifest:HLSManifest) -> [HLSValidationIssue]? {
        
        var validationIssueList:[HLSValidationIssue] = []
        for tag in hlsManifest.tags{
            guard let validationResponse = tag.validate() else {
                continue
            }
            for issue in validationResponse{
                validationIssueList.append(issue)
            }
        }
        return validationIssueList
    }
    
}
