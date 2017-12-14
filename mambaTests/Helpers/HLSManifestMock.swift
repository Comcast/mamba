//
//  HLSManifestMock.swift
//  mamba
//
//  Created by David Coufal on 11/2/16.
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

/// Factory that will produce minimal HLSManifests for unit testing
public struct HLSManifestMockFactory {
    
    /// produce a minimal HLSManifest that will pass a type or playlist type test
    static public func constructMockManifest(withType type:ManifestType, withPlaylistType playlistType:ManifestPlaylistType) -> HLSManifest {
        var tags = [HLSTag]()
        switch type {
        case .master:
            tags.append(createHLSTag(tagDescriptor: PantosTag.EXT_X_STREAM_INF, tagData: ""))
            tags.append(createHLSTag(tagDescriptor: PantosTag.Location, tagData: "notareal.m3u8"))
            break
        case .media:
            switch playlistType {
            case .event:
                tags.append(createHLSTag(tagDescriptor: PantosTag.EXT_X_PLAYLIST_TYPE, tagData: HLSPlaylistType.PlaylistType.Event.rawValue))
                break
            case .vod:
                tags.append(createHLSTag(tagDescriptor: PantosTag.EXT_X_PLAYLIST_TYPE, tagData: HLSPlaylistType.PlaylistType.VOD.rawValue))
                break
            default:
                break
            }
            tags.append(createHLSTag(tagDescriptor: PantosTag.EXTINF, tagData: "2.002"))
            tags.append(createHLSTag(tagDescriptor: PantosTag.Location, tagData: "notareal.ts"))
            break
        case .unknown:
            break
        }
        let data = Data()
        return HLSManifest(url: fakeManifestURL(), tags: tags, registeredTags: RegisteredHLSTags(), hlsData: data)
    }
}

public func fakeManifestURL() -> URL {
    return URL(string: "http://fake.unit.test.server.nowhere/manifest/\(UUID().uuidString)")!
}
