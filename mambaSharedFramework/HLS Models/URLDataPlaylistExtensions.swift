//
//  URLDataPlaylistExtensions.swift
//  mamba
//
//  Created by David Coufal on 3/12/19.
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

/// Specialized custom data modifier for VariantPlaylist and MasterPlaylist
public struct PlaylistURLData {
    var url: URL
    let creationTime = CACurrentMediaTime()
}

extension PlaylistCore: PlaylistURLDataInterface where PT.customPlaylistDataType == PlaylistURLData {
    
    public init(playlist: PlaylistCore) {
        self.init(url: playlist.url, tags: playlist.tags, registeredTags: playlist.registeredTags, playlistData: playlist.playlistData)
    }
    
    // care should be taken when constructing `Playlist`s manually. Users should construct these objects using `Parser`.
    public init(url: URL, tags: [HLSTag], registeredTags: RegisteredHLSTags, playlistData: Data) {
        let customData = PlaylistURLData(url: url)
        self.init(tags: tags, registeredTags: registeredTags, playlistData: playlistData, customData: customData)
    }
    
    public var url: URL {
        get {
            return customData.url
        }
        set {
            customData.url = newValue
        }
    }
    
    public var creationTime: TimeInterval {
        get {
            return customData.creationTime
        }
    }
    
    public var debugDescription: String {
        return "Playlist url:\(url) createTime:\(creationTime)\n\(self.playlistCoreDebugDescription)"
    }
}

public protocol PlaylistURLDataInterface {
    /// The URL where this playlist is located
    var url: URL { get set }
    /// The time this playlist was created. Based on `CACurrentMediaTime`, so only comparable with that time system.
    var creationTime: TimeInterval { get }
}
