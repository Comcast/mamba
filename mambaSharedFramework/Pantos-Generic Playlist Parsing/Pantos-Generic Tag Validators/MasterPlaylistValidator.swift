//
//  MasterPlaylistValidator.swift
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

/// Protocol for validating objects that implement `MasterPlaylistInterface`
public protocol MasterPlaylistValidator {
    
    /**
     Validates a MasterPlaylistInterface
     
     - parameter masterPlaylist: A `MasterPlaylistInterface` to validate
     
     - returns: An array of `PlaylistValidationIssue`s. Will be empty if no issues are found.
     */
    static func validate(masterPlaylist: MasterPlaylistInterface) -> [PlaylistValidationIssue]
}

/// A protocol for MasterPlaylistValidator that combines other MasterPlaylistValidator's in a superset
public protocol ExtensibleMasterPlaylistValidator: MasterPlaylistValidator {
    /// An array of MasterPlaylistValidator types that will be used to validate playlists
    static var masterPlaylistValidators: [MasterPlaylistValidator.Type] { get }
}

public extension ExtensibleMasterPlaylistValidator {
    
    /**
     Runs all `validators` against the master playlist and returns all issues found.
     
     - parameter masterPlaylist: A `MasterPlaylistInterface` to validate
     
     - returns: An array of `PlaylistValidationIssue`s. Will be empty if no issues are found.
     */
    static func combinedValidation(ofMasterPlaylist masterPlaylist: MasterPlaylistInterface) -> [PlaylistValidationIssue] {
        
        var issues = [PlaylistValidationIssue]()
        
        for validator in masterPlaylistValidators {
            let newIssues = validator.validate(masterPlaylist: masterPlaylist)
            issues += newIssues
        }
        
        return issues
    }
    
    // overridable default for ExtensibleMasterPlaylistValidator
    static func validate(masterPlaylist: MasterPlaylistInterface) -> [PlaylistValidationIssue] {
        return combinedValidation(ofMasterPlaylist: masterPlaylist)
    }
}
