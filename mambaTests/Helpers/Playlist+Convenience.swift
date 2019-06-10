//
//  Playlist+Convenience.swift
//  mamba
//
//  Created by David Coufal on 11/4/16.
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

@testable import mamba

/*
 It's a PITA to have to manage RegisteredTags all over the place.
 
 This extension has utilities to just create a standard Pantos RegisteredTags.
 
 Unit tests can create their own RegisteredTags using the mamba versions if they want, this is just if the test doesn't care
 */
public extension PlaylistCore where PT.customPlaylistDataType == PlaylistURLData {
    
    init() {
        let registeredPlaylistTags = RegisteredPlaylistTags()
        self.init(url: fakePlaylistURL(), tags: [PlaylistTag](), registeredPlaylistTags: registeredPlaylistTags, playlistMemoryStorage: StaticMemoryStorage())
    }
    
    init(tags: [PlaylistTag]) {
        let registeredPlaylistTags = RegisteredPlaylistTags()
        self.init(url: fakePlaylistURL(), tags: tags, registeredPlaylistTags: registeredPlaylistTags, playlistMemoryStorage: StaticMemoryStorage())
    }
    
}

public func fakePlaylistURL() -> URL {
    return URL(string: "http://fake.unit.test.server.nowhere/playlist/\(UUID().uuidString)")!
}
