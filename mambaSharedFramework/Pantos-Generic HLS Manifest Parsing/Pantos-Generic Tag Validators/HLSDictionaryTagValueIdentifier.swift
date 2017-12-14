//
//  HLSDictionaryTagValueIdentifier.swift
//  mamba
//
//  Created by Philip McMahon on 9/9/16.
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

public protocol HLSDictionaryTagValueIdentifier {

    var valueId: HLSTagValueIdentifier { get }
    var optional: Bool { get }
    var expectedType: FailableStringLiteralConvertible.Type { get }
}

public struct HLSDictionaryTagValueIdentifierImpl: HLSDictionaryTagValueIdentifier {
    
    public init(valueId: HLSTagValueIdentifier, optional: Bool, expectedType: FailableStringLiteralConvertible.Type) {
        self.valueId = valueId
        self.optional = optional
        self.expectedType = expectedType
    }
    
    public let valueId: HLSTagValueIdentifier
    public let optional: Bool
    public let expectedType: FailableStringLiteralConvertible.Type
}
