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
 It's a PITA to have to manage RegisteredHLSTags all over the place.
 
 This extension has utilities to just create a standard Pantos RegisteredHLSTags.
 
 Unit tests can create their own RegisteredHLSTags using the mamba versions if they want, this is just if the test doesn't care
 */
public extension PlaylistCore where PT.customPlaylistDataType == PlaylistURLData {
    
    init() {
        let registeredTags = RegisteredHLSTags()
        self.init(url: fakePlaylistURL(), tags: [HLSTag](), registeredTags: registeredTags, playlistMemoryStorage: StaticMemoryStorage())
    }
    
    init(tags: [HLSTag]) {
        let registeredTags = RegisteredHLSTags()
        self.init(url: fakePlaylistURL(), tags: tags, registeredTags: registeredTags, playlistMemoryStorage: StaticMemoryStorage())
    }
    
}

public func fakePlaylistURL() -> URL {
    return URL(string: "http://fake.unit.test.server.nowhere/playlist/\(UUID().uuidString)")!
}
