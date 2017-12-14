//
//  String+HLSTypeEquatable.swift
//  mamba
//
//  Created by David Coufal on 8/17/16.
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

extension String {
    
    public init(tagDescriptor: HLSTagDescriptor) {
        self = tagDescriptor.toString()
    }
    
    public init(valueIdentifier: HLSTagValueIdentifier) {
        self = valueIdentifier.toString()
    }

    public init(stringRef: HLSStringRef) {
        self = stringRef.stringValue()
    }
}

// convenience equality operators

public func ==(lhs: String, rhs: HLSTagDescriptor) -> Bool {
    return lhs == rhs.toString()
}

public func !=(lhs: String, rhs: HLSTagDescriptor) -> Bool {
    return !(lhs == rhs)
}

public func ==(lhs: HLSTagDescriptor, rhs: String) -> Bool {
    return lhs.toString() == rhs
}

public func !=(lhs: HLSTagDescriptor, rhs: String) -> Bool {
    return !(lhs == rhs)
}

public func ==(lhs: String, rhs: HLSTagValueIdentifier) -> Bool {
    return lhs == rhs.toString()
}

public func !=(lhs: String, rhs: HLSTagValueIdentifier) -> Bool {
    return !(lhs == rhs)
}

public func ==(lhs: HLSTagValueIdentifier, rhs: String) -> Bool {
    return lhs.toString() == rhs
}

public func !=(lhs: HLSTagValueIdentifier, rhs: String) -> Bool {
    return !(lhs == rhs)
}
