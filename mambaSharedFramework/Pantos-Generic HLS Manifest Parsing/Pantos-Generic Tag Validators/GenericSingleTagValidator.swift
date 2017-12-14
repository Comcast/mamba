//
//  GenericDurationValidator.swift
//  mamba
//
//  Created by Mohan on 8/8/16.
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


/// Class for generically validating values in the form of `#EXT-X-TARGETDURATION:10`, where there is a tag with a one and only one value(that is a string convertible to a known type) associated with it
public class GenericSingleTagValidator<S: FailableStringLiteralConvertible>: HLSTagValidator {
    
    fileprivate let singleValueIdentifier: HLSTagValueIdentifier
    fileprivate let tag: HLSTagDescriptor
    
    public init(tag: HLSTagDescriptor, singleValueIdentifier: HLSTagValueIdentifier) {
        self.tag = tag
        self.singleValueIdentifier = singleValueIdentifier
    }
    
    public func validate(tag: HLSTag) -> [HLSValidationIssue]? {
        var issueList:[HLSValidationIssue] = []
        
        assert(tag.numberOfParsedValues() == 1)
        
        if tag.numberOfParsedValues() < 1 {
            issueList.append(HLSValidationIssue(description: "\(tag.tagDescriptor.toString()) has no parsed data.", severity: IssueSeverity.error))
        }
        else if tag.numberOfParsedValues() > 1 {
            issueList.append(HLSValidationIssue(description: "\(tag.tagDescriptor.toString()) has more than one parsed data values.", severity: IssueSeverity.warning))
        }
        
        guard let value: String = tag.value(forValueIdentifier: singleValueIdentifier) , !value.isEmpty else {
            issueList.append(HLSValidationIssue(description: "\(tag.tagDescriptor.toString()) value is empty.", severity: IssueSeverity.error))
            return issueList
        }
        guard let _ = S(string: value) else {
            issueList.append(HLSValidationIssue(description: "\(tag.tagDescriptor.toString()) (\(value)) is not an instance of the expected data type.", severity: IssueSeverity.error))
            return issueList
        }
        
        return nil
    }
}
