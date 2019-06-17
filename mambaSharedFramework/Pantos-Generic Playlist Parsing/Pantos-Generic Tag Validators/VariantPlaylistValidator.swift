//
//  VariantPlaylistValidator.swift
//  mamba
//
//  Created by David Coufal on 3/13/19.
//  Copyright © 2019 Comcast Corporation.
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
//  limitations under the License. All rights reserved.
//

import Foundation

/// Protocol for validating objects that implement `VariantPlaylistInterface`
public protocol VariantPlaylistValidator {
    
    /**
     Validates a VariantPlaylistInterface
     
     - parameter variantPlaylist: A `VariantPlaylistInterface` to validate
     
     - returns: An array of `PlaylistValidationIssue`s. Will be empty if no issues are found.
     */
    static func validate(variantPlaylist: VariantPlaylistInterface) -> [PlaylistValidationIssue]
}

/// A protocol for VariantPlaylistValidator that combines other VariantPlaylistValidator's in a superset
public protocol ExtensibleVariantPlaylistValidator: VariantPlaylistValidator {
    /// An array of VariantPlaylistValidator types that will be used to validate playlists
    static var variantPlaylistValidators: [VariantPlaylistValidator.Type] { get }
}

public extension ExtensibleVariantPlaylistValidator {
    
    /**
     Runs all `validators` against the variant playlist and returns all issues found.
     
     - parameter variantPlaylist: A `VariantPlaylistInterface` to validate
     
     - returns: An array of `PlaylistValidationIssue`s. Will be empty if no issues are found.
     */
    static func combinedValidation(ofVariantPlaylist variantPlaylist: VariantPlaylistInterface) -> [PlaylistValidationIssue] {
        
        var issues = [PlaylistValidationIssue]()
        
        for validator in variantPlaylistValidators {
            let newIssues = validator.validate(variantPlaylist: variantPlaylist)
            issues += newIssues
        }
        
        return issues
    }
    
    // overridable default for ExtensibleVariantPlaylistValidator
    static func validate(variantPlaylist: VariantPlaylistInterface) -> [PlaylistValidationIssue] {
        return combinedValidation(ofVariantPlaylist: variantPlaylist)
    }
}
