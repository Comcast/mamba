//
//  HLSManifestTypes.swift
//  mamba
//
//  Created by David Coufal on 11/3/16.
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

/// the manifest type (i.e. master vs media/variant vs indeterminate)
public enum ManifestType {
    /// cannot determine (likely a invalid manifest)
    case unknown
    /// a master playlist
    case master
    /// a variant/media playlist
    case media
}

/// the playlist type (i.e. VOD vs Event/CDVR vs Live/Linear)
public enum ManifestPlaylistType {
    /// a playlist is not ManifestType.media
    case unknown
    /// a playlist with a set begin time and set end time
    case vod
    /// a playlist with a set begin time but no set end time
    case event
    /// a playlist with no set begin or end
    case live
}

/// a protocol for objects that can report on a ManifestType
public protocol HLSManifestTypeDetermination {
    /// the manifest type (i.e. master vs media/variant vs we can't tell)
    var type: ManifestType { get }
}

/// a protocol for objects that can report on a ManifestPlaylistType
public protocol HLSManifestPlaylistTypeDetermination {
    /// the playlist type (i.e. VOD vs Event/CDVR vs Live/Linear)
    var playlistType: ManifestPlaylistType { get }
}
