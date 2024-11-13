//
//  FailableStringLiteralConvertible.swift
//  mamba
//
//  Created by Mohan on 8/17/16.
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
import CoreMedia

#if SWIFT_PACKAGE
import HLSObjectiveC
#endif

/// A protocol for objects that can be constructed from a string, but might fail.
public protocol FailableStringLiteralConvertible {
    init?(failableInitWithString: String)
}

extension Int: FailableStringLiteralConvertible {
    public init?(failableInitWithString string: String) {
        self.init(string, radix: 10)
    }
}

extension Float: FailableStringLiteralConvertible {
    public init?(failableInitWithString string: String) {
        self.init(string)
    }
}

extension Double: FailableStringLiteralConvertible {
    public init?(failableInitWithString string: String) {
        self.init(string)
    }
}

extension Bool: FailableStringLiteralConvertible {
    public enum YesNo: String {
        case No = "NO"
        case Yes = "YES"
    }
    public init?(failableInitWithString string: String) {
        guard let value = YesNo.init(rawValue: string) else {
            return nil
        }
        self = (value == .Yes)
    }
}

extension String: FailableStringLiteralConvertible {
    public init?(failableInitWithString string: String) {
        self.init(string)
    }
}

extension Date: FailableStringLiteralConvertible {
    public init?(failableInitWithString string: String) {
        guard let date = string.parseISO8601Date() else {
            return nil
        }
        self.init(timeInterval:0.0, since:date)
    }
    
}

extension CMTime: FailableStringLiteralConvertible {
    public init?(failableInitWithString string: String) {
        self = mamba_CMTimeMakeFromString(string, UInt8(CMTime.defaultMambaPrecision), nil)
    }
}
