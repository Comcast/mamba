//
//  PlaylistCore.swift
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

import CoreMedia

/**
 A structure representing a HLS playlist in easy to edit form.
 
 The main responsibility of this struct is to wrap the generic PlaylistStructure class as a struct.
 
 This struct is thread safe.
 
 This struct is generic. Much of the mamba code assumes you'll be using either `MasterPlaylist`
 or `VariantPlaylist`. These two concrete implementations should meet your needs unless you have
 exotic requirements.
 
 If you'd like to add support for your own custom data, you can make your own concrete version
 from this generic core object.
 */
public struct PlaylistCore<PT>: PlaylistInterface, CustomDebugStringConvertible where PT: PlaylistTypeInterface {
    
    /// A read-only array of the `Tag`s in this playlist.
    public var tags: [PlaylistTag] {
        return structure.tags
    }
        
    /// custom playlist data
    public var customData: PT.customPlaylistDataType
    
    /// Many of the tags in this playlist contain `MambaStringRef`s with pointers to memory within a `Data` object.
    /// This reference is here to assure that the data will not go out of scope.
    public let playlistMemoryStorage: StaticMemoryStorage
    
    /// The registered tag types for this playlist
    public private(set) var registeredTags: RegisteredTags
    
    var structure: PT.playlistStructureType

    /// Initializes PlaylistCore
    public init(tags: [PlaylistTag],
                registeredTags: RegisteredTags,
                playlistMemoryStorage: StaticMemoryStorage,
                customData: PT.customPlaylistDataType) {
        self.registeredTags = registeredTags
        self.structure = PT.playlistStructureType(withTags: tags)
        self.customData = customData
        self.playlistMemoryStorage = playlistMemoryStorage
    }
    
    /**
     Insert a single tag.
     
     - parameter tag: A `Tag` to be inserted into the playlist.
     
     - parameter atIndex: Position to insert the tag into the playlist. The tag will be added to an
     existing PlaylistTagGroupProtocol unless `withStructureRebuild` is set to true.
     */
    public mutating func insert(tag: PlaylistTag, atIndex index: Int) {
        mutatingStructure.insert(tag: tag, atIndex: index)
    }
    
    /**
     Insert multiple tags.
     
     - parameter tags: A `Tag` array to be inserted into the playlist.
     
     - parameter atIndex: Position to insert the tags into the playlist. The tags will be added to an
     existing PlaylistTagGroupProtocol unless `withStructureRebuild` is set to true.
     */
    public mutating func insert(tags: [PlaylistTag], atIndex index: Int) {
        mutatingStructure.insert(tags: tags, atIndex: index)
    }
    
    /**
     Delete a single tag.
     
     - parameter atIndex: Position of the tag to delete.
     */
    public mutating func delete(atIndex index: Int) {
        mutatingStructure.delete(atIndex: index)
    }
    
    /**
     Delete multiple tags.
     
     - parameter atRange: Range of the tags to delete. If the range extends over more than
     one media group, we will automatically rebuild structure.
     */
    public mutating func delete(atRange range: PlaylistTagIndexRange) {
        mutatingStructure.delete(atRange: range)
    }
    
    /**
     Perform a map on every tag in the tags array.
     
     - parameter: The mapping closure to use during the map.
     */
    public mutating func transform(_ mapping: (PlaylistTag) throws -> (PlaylistTag)) throws {
        try mutatingStructure.transform(mapping)
    }
            
    private var mutatingStructure: PT.playlistStructureType {
        mutating get {
            if !isKnownUniquelyReferenced(&structure) {
                structure = PT.playlistStructureType(withStructure: structure)
            }
            return structure
        }
    }
    
    public var debugDescription: String {
        return "PlaylistCore \(playlistCoreDebugDescription)\n"
    }
    
    public var playlistCoreDebugDescription: String {
        guard
            let stream = try? self.write(),
            let debugDescription = String(data: stream, encoding: .utf8) else {
                return "Stream write failure. Raw Data: registeredTags:\(registeredTags) \nstructure:\(structure)\n"
        }
        return String(debugDescription)
    }
    
    /**
     Grab a ArraySlice representing the given Tag Group.
     
     - parameter forMediaGroup: The media group that is used for the tag selection.
     
     - returns: An ArraySlice of the tags in the given media group.
     */
    public func tags(forMediaGroup group: PlaylistTagGroupProtocol) -> ArraySlice<PlaylistTag> {
        return tags[group.range]
    }

    /**
     Write a playlist.
     
     - throws: Errors from a `PlaylistWriter` whilst attempting to write
     - returns: `Data` if successful
     */
    public func write() throws -> Data {
        
        let writer = PlaylistWriter()
        return try writer.write(playlist: self)
    }
}
