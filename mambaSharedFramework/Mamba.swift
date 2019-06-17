//
//  Mamba.swift
//  mamba
//
//  Created by David Coufal on 8/2/16.
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

/// Base object representing the Mamba framework
public enum Mamba {
    
    /// returns the version of the mamba framework
    public static var version: String {
        
        let bundle = Bundle(for: PlaylistParser.self)
        
        guard let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            assertionFailure("Unable to find version string in framework bundle")
            return "Error: Unable to find version string in framework bundle"
        }
        
        return version
    }
}
