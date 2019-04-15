//
//  HLSPlaylist.swift
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
 `HLSPlaylist` represents a playlist that was downloaded from the network.
 
 It has a url that represents its network location.
 
 It is a concrete version of the generic class `HLSPlaylistCore`.
 */
public typealias HLSPlaylist = HLSPlaylistCore<HLSPlaylistURLData>

public extension HLSPlaylistCore where T == HLSPlaylistURLData {
    
    public init(playlist: HLSPlaylist) {
        self.init(url: playlist.url, tags: playlist.tags, registeredTags: playlist.registeredTags, hlsBuffer: playlist.hlsBuffer)
    }

    // care should be taken when constructing `HLSPlaylist` manually. Users should construct these objects using `HLSParser`
    public init(url: URL, tags: [HLSTag], registeredTags: RegisteredHLSTags, hlsBuffer: MambaStaticMemoryBuffer) {
        let customData = HLSPlaylistURLData(url: url)
        self.init(tags: tags, registeredTags: registeredTags, hlsBuffer: hlsBuffer, customData: customData)
    }

    /// The URL where this playlist is located
    public var url: URL {
        get {
            return customData.url
        }
        set {
            customData.url = newValue
        }
    }
    
    /// The time this playlist was created. Based on `CACurrentMediaTime`, so only comparable with that time system.
    public var creationTime: TimeInterval {
        get {
            return customData.creationTime
        }
    }
    
    public var debugDescription: String {
        return "HLSPlaylist url:\(url) createTime:\(creationTime)\n\(self.playlistCoreDebugDescription)"
    }
}

/// A type used internally by HLSPlaylist
public struct HLSPlaylistURLData {
    var url: URL
    let creationTime = CACurrentMediaTime()
}
