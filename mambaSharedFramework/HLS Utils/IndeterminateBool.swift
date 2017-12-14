//
//  IndeterminateBool.swift
//  mamba
//
//  Created by David Coufal on 12/7/17.
//  Copyright © 2017 Comcast Corporation.
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

/// An enum representing a three value bool system, where there can be either TRUE, FALSE or INDETERMINATE.
public enum IndeterminateBool: Equatable {
    
    /// This value is false
    case FALSE
    /// This value is true
    case TRUE
    /// Value cannot be determined
    case INDETERMINATE
    
    /// Convenience Initializer. The value will either be .TRUE or .FALSE depending on the boolValue.
    public init(boolValue: Bool) {
        self = boolValue ? .TRUE : .FALSE
    }
}

extension IndeterminateBool: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .TRUE:
            return "TRUE"
        case .FALSE:
            return "FALSE"
        case .INDETERMINATE:
            return "INDETERMINATE"
        }
    }
}

public func == (lhs: Bool, rhs: IndeterminateBool) -> Bool {
    return IndeterminateBool(boolValue: lhs) == rhs
}

public func == (lhs: IndeterminateBool, rhs: Bool) -> Bool {
    return lhs == IndeterminateBool(boolValue: rhs)
}

public prefix func ! (value: IndeterminateBool) -> IndeterminateBool {
    switch value {
    case .FALSE:
        return .TRUE
    case .TRUE:
        return .FALSE
    case .INDETERMINATE:
        return .INDETERMINATE
    }
}

public func && (lhs: IndeterminateBool, rhs: IndeterminateBool) -> IndeterminateBool {
    switch lhs {
    case .FALSE:
        return .FALSE
    case .TRUE:
        return rhs
    case .INDETERMINATE:
        if rhs == .FALSE {
            return .FALSE
        }
        return .INDETERMINATE
    }
}

public func && (lhs: Bool, rhs: IndeterminateBool) -> IndeterminateBool {
    return IndeterminateBool(boolValue: lhs) && rhs
}

public func && (lhs: IndeterminateBool, rhs: Bool) -> IndeterminateBool {
    return lhs && IndeterminateBool(boolValue: rhs)
}

public func || (lhs: IndeterminateBool, rhs: IndeterminateBool) -> IndeterminateBool {
    switch lhs {
    case .FALSE:
        return rhs
    case .TRUE:
        return .TRUE
    case .INDETERMINATE:
        if rhs == .TRUE {
            return .TRUE
        }
        return .INDETERMINATE
    }
}

public func || (lhs: Bool, rhs: IndeterminateBool) -> IndeterminateBool {
    return IndeterminateBool(boolValue: lhs) || rhs
}

public func || (lhs: IndeterminateBool, rhs: Bool) -> IndeterminateBool {
    return lhs || IndeterminateBool(boolValue: rhs)
}
