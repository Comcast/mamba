//
//  URLSchemeChangeExtension.swift
//  mamba
//
//  Created by David Coufal on 10/10/16.
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

extension URL {
    
    public static let http_scheme = "http"
    public static let https_scheme = "https"
    
    /// Convenience function to change the scheme of a url
    @discardableResult
    public mutating func changeScheme(to newScheme: String) -> Bool {
        let newComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)
        guard var components = newComponents else {
            return false
        }
        components.scheme = newScheme
        guard let newUrl = components.url else {
            return false
        }
        self = newUrl
        return true
    }
}
