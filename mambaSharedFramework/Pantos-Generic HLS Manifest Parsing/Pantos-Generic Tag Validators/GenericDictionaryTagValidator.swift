//
//  HLSGenericArrayTagValidator.swift
//  mamba
//
//  Created by Philip McMahon on 9/8/16.
//  Copyright © 2016 Comcast Corporation.
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

public class GenericDictionaryTagValidator: HLSTagValidator {
    
    private let dictionaryValueIdentifiers: [HLSDictionaryTagValueIdentifier]
    private let tag: HLSTagDescriptor
    
    public init(tag: HLSTagDescriptor, dictionaryValueIdentifiers: [HLSDictionaryTagValueIdentifier]) {
        self.tag = tag
        self.dictionaryValueIdentifiers = dictionaryValueIdentifiers
    }
    
    public func validate(tag: HLSTag) -> [HLSValidationIssue]? {
        
        var issueList:[HLSValidationIssue] = []
        for identifier in dictionaryValueIdentifiers {
            
            if let value: String = tag.value(forValueIdentifier: identifier.valueId) {
                
                guard let _ = identifier.expectedType.init(string: value) else {
                    issueList.append(HLSValidationIssue(description: "\(tag.tagDescriptor.toString()) \(identifier.valueId)=\(value) is not an instance of the expected data type \(identifier.expectedType).", severity: IssueSeverity.error))
                    continue
                }
            }
            else {
                if !identifier.optional {
                    issueList.append(HLSValidationIssue(description: "\(tag.tagDescriptor.toString()) mandatory value \(identifier.valueId) is missing.", severity: IssueSeverity.error))
                }
            }
        }
        
        return issueList.isEmpty ? nil : issueList
    }
}
