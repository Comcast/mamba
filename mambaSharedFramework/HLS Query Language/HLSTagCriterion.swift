//
//  HLSTagCriterion.swift
//  mamba
//
//  Created by David Coufal on 8/4/16.
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

// MARK: Base HLSTagCriterion entities

/// Describes a object used to filter HLSTags from a HLSManifest
public protocol HLSTagCriterion {
    func evaluate(tag: HLSTag) -> Bool
}

/// Describes a comparision to be done as part of a HLSTagCriterion
public enum HLSTagCriterionComparison {
    case equals
    case lessThan
    case greaterThan
    case lessThanOrEquals
    case greaterThanOrEquals
}


// MARK: Generic HLSTagCriterion-based specialized protocols

/// Generic protocol for HLSTagCriterion that implement equality comparisons
public protocol HLSEqualityTagCriteron: HLSTagCriterion {
    associatedtype E: Equatable
    var valueIdentifer: HLSTagValueIdentifier { get }
    var value: E { get }
    func value(inTag: HLSTag, forValueIdentifer: HLSTagValueIdentifier) -> E?
}

extension HLSEqualityTagCriteron {
    public func evaluate(tag: HLSTag) -> Bool {
        guard let comp: E = self.value(inTag: tag, forValueIdentifer: self.valueIdentifer) else {
            return false
        }
        return comp == self.value
    }
}

/// Generic protocol for HLSTagCriterion that implement HLSTagCriterionComparison
public protocol HLSComparisonTagCriteron: HLSTagCriterion {
    associatedtype C: Comparable
    var valueIdentifer: HLSTagValueIdentifier { get }
    var value: C { get }
    var comparison: HLSTagCriterionComparison { get }
    func value(inTag: HLSTag, forValueIdentifer valueIdentifer: HLSTagValueIdentifier) -> C?
}

extension HLSComparisonTagCriteron {
    public func evaluate(tag: HLSTag) -> Bool {
        guard let comp: C = self.value(inTag: tag, forValueIdentifer: self.valueIdentifer) else {
            return false
        }
        switch self.comparison {
        case .equals:
            return comp == self.value
        case .lessThan:
            return comp < self.value
        case .greaterThan:
            return comp > self.value
        case .lessThanOrEquals:
            return comp <= self.value
        case .greaterThanOrEquals:
            return comp >= self.value
        }
    }
}

// MARK: Concrete HLSTagCriterion implementations

/// Filter all tags that have this descriptor
public struct HLSAllTagCriteron: HLSTagCriterion {
    public let tagDescriptor: HLSTagDescriptor
    public func evaluate(tag: HLSTag) -> Bool {
        return tag.tagDescriptor == self.tagDescriptor
    }
    public init(tagDescriptor: HLSTagDescriptor) {
        self.tagDescriptor = tagDescriptor
    }
}

/// Filter all tags that have a value for the given valueIdentifer
public struct HLSHasValueCriteron: HLSTagCriterion {
    public let valueIdentifer: HLSTagValueIdentifier
    public func evaluate(tag: HLSTag) -> Bool {
        let nilString: String? = nil
        return tag.value(forValueIdentifier: valueIdentifer) != nilString
    }
    public init(valueIdentifer: HLSTagValueIdentifier) {
        self.valueIdentifer = valueIdentifer
    }
}

/// Filter all tags that have no value for the given valueIdentifer
public struct HLSHasNoValueCriteron: HLSTagCriterion {
    public let valueIdentifer: HLSTagValueIdentifier
    public func evaluate(tag: HLSTag) -> Bool {
        let nilString: String? = nil
        return tag.value(forValueIdentifier: valueIdentifer) == nilString
    }
    public init(valueIdentifer: HLSTagValueIdentifier) {
        self.valueIdentifer = valueIdentifer
    }
}

/// Filter all tags that have this descriptor with a valueIdentifier that exactly matches this string
public struct HLSStringMatchTagCriteron: HLSEqualityTagCriteron {
    public let valueIdentifer: HLSTagValueIdentifier
    public let value: String
    public func value(inTag tag: HLSTag, forValueIdentifer valueIdentifer: HLSTagValueIdentifier) -> String? {
        return tag.value(forValueIdentifier: valueIdentifer)
    }
    public init(valueIdentifer: HLSTagValueIdentifier, value:String) {
        self.valueIdentifer = valueIdentifer
        self.value = value
    }
}

/// Filter all tags that have a tagName that exactly matches the requested tagName
public struct HLSStringMatchTagNameCriteron: HLSTagCriterion {
    public let tagName: String
    public func evaluate(tag: HLSTag) -> Bool {
        return (tag.tagName != nil) ? (tag.tagName! == self.tagName) : false
    }
    public init(tagName: String) {
        self.tagName = tagName
    }
}

/// Filter all tags that have this descriptor with a valueIdentifier that contains this string
public struct HLSContainsStringTagCriteron: HLSTagCriterion {
    public let valueIdentifer: HLSTagValueIdentifier
    public let containsValue: String
    public func evaluate(tag: HLSTag) -> Bool {
        guard let string: String = tag.value(forValueIdentifier: self.valueIdentifer) else {
            return false
        }
        return string.contains(self.containsValue)
    }
    public init(valueIdentifer: HLSTagValueIdentifier, containsValue: String) {
        self.valueIdentifer = valueIdentifer
        self.containsValue = containsValue
    }
}

/// Filter all tags that have this descriptor with a valueIdentifier that does not contain this string
public struct HLSDoesNotContainStringTagCriteron: HLSTagCriterion {
    public let valueIdentifer: HLSTagValueIdentifier
    public let containsValue: String
    public func evaluate(tag: HLSTag) -> Bool {
        guard let string: String = tag.value(forValueIdentifier: self.valueIdentifer) else {
            return false
        }
        return !string.contains(self.containsValue)
    }
    public init(valueIdentifer: HLSTagValueIdentifier, containsValue:String) {
        self.valueIdentifer = valueIdentifer
        self.containsValue = containsValue
    }
}

/// Filter all tags that have this descriptor with a valueIdentifier that matches the comparison operator on an Int value
public struct HLSIntTagCriteron: HLSComparisonTagCriteron {
    public let valueIdentifer: HLSTagValueIdentifier
    public let value: Int
    public let comparison: HLSTagCriterionComparison
    public func value(inTag tag: HLSTag, forValueIdentifer valueIdentifer: HLSTagValueIdentifier) -> Int? {
        return tag.value(forValueIdentifier: valueIdentifer)
    }
    public init(valueIdentifer: HLSTagValueIdentifier, value:Int, comparison: HLSTagCriterionComparison) {
        self.valueIdentifer = valueIdentifer
        self.value = value
        self.comparison = comparison
    }
}

/// Filter all tags that have this descriptor with a valueIdentifier that matches the comparison operator on a HLSResolution value
public struct HLSResolutionTagCriteron: HLSComparisonTagCriteron {
    public let valueIdentifer: HLSTagValueIdentifier
    public let value: HLSResolution
    public let comparison: HLSTagCriterionComparison
    public func value(inTag tag: HLSTag, forValueIdentifer valueIdentifer: HLSTagValueIdentifier) -> HLSResolution? {
        return tag.value(forValueIdentifier: valueIdentifer)
    }
    public init(valueIdentifer: HLSTagValueIdentifier, value:HLSResolution, comparison: HLSTagCriterionComparison) {
        self.valueIdentifer = valueIdentifer
        self.value = value
        self.comparison = comparison
    }
}
