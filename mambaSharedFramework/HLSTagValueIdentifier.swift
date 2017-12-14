//
//  HLSTagValueIdentifier.swift
//  mamba
//
//  Created by David Coufal on 7/5/16.
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

/// Protocol that describes a possible value associated with a HLS tag
///
/// There is a default `HLSTagValueIdentifier` provider, `PantosValue`
public protocol HLSTagValueIdentifier {
    
    /// Get a string represention of the tag value that is the same as how it appears in the HLS manifest (i.e. "`PROGRAM-ID`"), if it does appear in the manifest
    func toString() -> String
}

