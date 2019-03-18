//
//  PlaylistTypeInterface.swift
//  mamba
//
//  Created by David Coufal on 3/11/19.
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
 A protocol defining a type of HLS playlist.
 
 The canonical types are "Master" and "Variant", but you can define your own types
 if that's useful to you. `mamba` contains `MasterPlaylistType` and
 `VariantPlaylistType` flavors.
 */
public protocol PlaylistTypeInterface {
    
    /**
     This value is the "custom type" of the `PlaylistCore` object.
     
     It's used to add custom data to your `PlaylistCore` object. It's
     used to add the `URL` and `creationTime` to ``MasterPlaylist`
     and `VariantPlaylist`.
     */
    associatedtype customPlaylistDataType
    
    /**
     This value is the type of the class that implements the
     `PlaylistStructureInterface` for this playlist type.
     
     If you are implementing your own playlist type, you should study
     "Master" and "Variant" implementations of this class very closely.
     Implementing this correctly is tricky. You should look very closely
     at `PlaylistCore` and it's `mutatingStructure` and usage of
     `isKnownUniquelyReferenced` as well. Consider using the common
     class `PlaylistStructureCore` as your base.
     */
    associatedtype playlistStructureType: PlaylistStructureInterface
}
