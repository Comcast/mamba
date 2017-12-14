//
//  HLSManifest.swift
//  mamba
//
//  Created by David Coufal on 3/6/17.
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

/**
 `HLSManifest` represents a manifest that was downloaded from the network.
 
 It has a url that represents its network location.
 
 It is a concrete version of the generic class `HLSManifestCore`.
 */
public typealias HLSManifest = HLSManifestCore<HLSManifestURLData>

public extension HLSManifestCore where T == HLSManifestURLData {
    
    public init(manifest: HLSManifest) {
        self.init(url: manifest.url, tags: manifest.tags, registeredTags: manifest.registeredTags, hlsData: manifest.hlsData)
    }

    // care should be taken when constructing `HLSManifest` manually. Most users should construct these objects using `HLSParser`
    public init(url: URL, tags: [HLSTag], registeredTags: RegisteredHLSTags, hlsData: Data) {
        let customData = HLSManifestURLData(url: url)
        self.init(tags: tags, registeredTags: registeredTags, hlsData: hlsData, customData: customData)
    }

    /// The URL where this manifest is located
    public var url: URL {
        get {
            return customData.url
        }
        set {
            customData.url = newValue
        }
    }
    
    public var debugDescription: String {
        return "HLSManifest url:\(url)\n\(self.manifestCoreDebugDescription)"
    }
}

/// A type used internally by HLSManifest
public struct HLSManifestURLData {
    var url: URL
}
