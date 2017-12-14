//
//  HLSTagCriteria.swift
//  mamba
//
//  Created by David Coufal on 8/17/16.
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

/**
 Collection of HLSTagCriteria, along with a "type" that can be applied to a query.
 
 HLSTagCriteria and HLSTagCriterion are useful as base pieces to build a system for querying collections of `HLSTag` for specific properties.

 This can be set up (via MatchType) to either match all of the criteria (for an "and" type match) or just one of the criteria (for an "or" type match)

 Default is MatchType.MatchAll
 */
public struct HLSTagCriteria: HLSTagCriterion {
    
    public let criteria: [HLSTagCriterion]
    public let matchType: MatchType
    
    public init(matchType: MatchType) {
        self.matchType = matchType
        criteria = [HLSTagCriterion]()
    }
    
    public init(criteria: [HLSTagCriterion], matchType: MatchType) {
        self.matchType = matchType
        self.criteria = criteria
    }
    
    public init(criteria: [HLSTagCriterion]) {
        self.matchType = .matchAll
        self.criteria = criteria
    }
    
    /// Defines the logic of how we evaluate our criteria
    public enum MatchType {
        /// Match all criteria in this group (AND)
        case matchAll
        /// Match only one criteria in this group (OR)
        case matchAtLeastOne
    }
    
    public func evaluate(tag: HLSTag) -> Bool {
        switch(matchType) {
        case .matchAll:
            return passesAllCriteria(tag: tag, criteria: criteria)
        case .matchAtLeastOne:
            return passesAtLeastOneCriteria(tag: tag, criteria: criteria)
        }
    }
}

internal func passesAllCriteria(tag: HLSTag, criteria: [HLSTagCriterion]) -> Bool {
    for criterion in criteria {
        if !criterion.evaluate(tag: tag) {
            return false
        }
    }
    return true
}

internal func passesAtLeastOneCriteria(tag: HLSTag, criteria: [HLSTagCriterion]) -> Bool {
    for criterion in criteria {
        if criterion.evaluate(tag: tag) {
            return true
        }
    }
    return false
}
