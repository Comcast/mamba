//
//  MasterPlaylist.swift
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

/**
 `MasterPlaylist` is a struct that represents a master-style HLS playlist.
 */
public typealias MasterPlaylist = PlaylistCore<MasterPlaylistType>

extension PlaylistCore: MasterPlaylistTagGroupProvider, MasterStreamSummaryCalculator, MasterPlaylistInterface where PT == MasterPlaylistType {
    public var variantTagGroups: [VariantTagGroup] { return structure.variantTagGroups }
}

/**
 This is a protocol that defines the standard `MasterPlaylist` interface.
 
 This protocol should be used instead of the actual `MasterPlaylist` type when possible.
 */
public protocol MasterPlaylistInterface: PlaylistInterface, MasterPlaylistTagGroupProvider, PlaylistURLDataInterface, MasterStreamSummaryCalculator {}
