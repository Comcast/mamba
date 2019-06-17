//
//  MambaStringRef.swift
//  mamba
//
//  Created by David Coufal on 1/26/17.
//  Copyright © 2017 Comcast Cable Communications Management, LLC
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

public extension MambaStringRef {
    
    convenience init(descriptor: PlaylistTagDescriptor) {
        self.init(string: "#\(descriptor.toString())")
    }
    
    convenience init(valueIdentifier: PlaylistTagValueIdentifier) {
        self.init(string: valueIdentifier.toString())
    }
}

public func == (lhs: MambaStringRef, rhs: String) -> Bool {
    return lhs.isEqual(to: rhs)
}

public func != (lhs: MambaStringRef, rhs: String) -> Bool {
    return !(lhs == rhs)
}

public func == (lhs: String, rhs: MambaStringRef) -> Bool {
    return rhs.isEqual(to: lhs)
}

public func != (lhs: String, rhs: MambaStringRef) -> Bool {
    return !(lhs == rhs)
}
