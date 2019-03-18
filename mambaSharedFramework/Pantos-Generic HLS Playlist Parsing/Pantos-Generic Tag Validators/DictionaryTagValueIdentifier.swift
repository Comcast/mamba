//
//  DictionaryTagValueIdentifier.swift
//  mamba
//
//  Created by Philip McMahon on 9/9/16.
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

/// A protocol describing what values are expected in a dictionary style HLS tag.
public protocol DictionaryTagValueIdentifier {

    /// The HLSTagValueIdentifier of the key in the key value pair.
    var valueId: HLSTagValueIdentifier { get }
    /// Is the key-value pair optional or required?
    var optional: Bool { get }
    /// What type are we expecting for the value in the key-value pair. This type must implement FailableStringLiteralConvertible.
    var expectedType: FailableStringLiteralConvertible.Type { get }
}

/// A concrete implemention of HLSDictionaryTagValueIdentifier.
public struct DictionaryTagValueIdentifierImpl: DictionaryTagValueIdentifier {
    
    public init(valueId: HLSTagValueIdentifier, optional: Bool, expectedType: FailableStringLiteralConvertible.Type) {
        self.valueId = valueId
        self.optional = optional
        self.expectedType = expectedType
    }
    
    public let valueId: HLSTagValueIdentifier
    public let optional: Bool
    public let expectedType: FailableStringLiteralConvertible.Type
}
