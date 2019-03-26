//
//  PlaylistTagValidator.swift
//  mamba
//
//  Created by Mohan on 8/8/16.
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

/// A protocol describing the interface for a object that can validate a `Tag`'s adherence to a specification.
public protocol PlaylistTagValidator {
    
    /**
     Validates if a given `Tag` meets the specification.
     
     - parameter tag: The `Tag` to validate.
     
     - returns: An array of `PlaylistValidationIssue`s, or nil if no issues were found.
     */
    func validate(tag: PlaylistTag) -> [PlaylistValidationIssue]?
}
