//
//  HLSPlaylistCore.swift
//  mamba
//
//  Created by David Coufal on 9/27/17.
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
import CoreMedia

/**
 A structure representing a HLS playlist in easy to edit form.
 
 The main responsibility of this struct is to wrap the HLSPlaylistStructure class as a struct.
 
 This struct is thread safe.
 
 This struct is generic. Much of the mamba code assumes you'll be using `HLSPlaylist`, so that's
 probably the best suggestion unless you have special needs.
 
 If you'd like to add support for your own custom data, you can make your own concrete version
 from this generic core object.
 */
public struct HLSPlaylistCore<T>: HLSPlaylistInterface, CustomDebugStringConvertible {
    
    /// A read-only array of the `HLSTag`s in this playlist.
    public var tags: [HLSTag] {
        return structure.tags
    }
    
    public var header: TagGroup? {
        return structure.header
    }
    
    public var mediaSegmentGroups: [MediaSegmentTagGroup] {
        return structure.mediaSegmentGroups
    }
    
    public var mediaSpans: [TagSpan] {
        return structure.mediaSpans
    }
    
    public var footer: TagGroup? {
        return structure.footer
    }
    
    /// custom playlist data
    public var customData: T
    
    /// Many of the tags in this playlist contain `HLSStringRef`s with pointers to memory within a `MambaStaticMemoryBuffer` object.
    /// This reference is here to assure that the data will not go out of scope.
    public let hlsBuffer: MambaStaticMemoryBuffer
    
    /// Initializes HLSPlaylistCore
    public init(tags: [HLSTag], registeredTags: RegisteredHLSTags, hlsBuffer: MambaStaticMemoryBuffer, customData: T) {
        self.registeredTags = registeredTags
        self.structure = HLSPlaylistStructure(withTags: tags)
        self.customData = customData
        self.hlsBuffer = hlsBuffer
    }
    
    /**
     Insert a single tag.
     
     - parameter tag: A `HLSTag` to be inserted into the playlist.
     
     - parameter atIndex: Position to insert the tag into the playlist. The tag will be added to an
     existing TagGroupProtocol unless `withStructureRebuild` is set to true.
     */
    public mutating func insert(tag: HLSTag, atIndex index: Int) {
        mutatingStructure.insert(tag: tag, atIndex: index)
    }
    
    /**
     Insert multiple tags.
     
     - parameter tags: A `HLSTag` array to be inserted into the playlist.
     
     - parameter atIndex: Position to insert the tags into the playlist. The tags will be added to an
     existing TagGroupProtocol unless `withStructureRebuild` is set to true.
     */
    public mutating func insert(tags: [HLSTag], atIndex index: Int) {
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
    public mutating func delete(atRange range: HLSTagIndexRange) {
        mutatingStructure.delete(atRange: range)
    }
    
    /**
     Perform a map on every tag in the tags array.
     
     - parameter: The mapping closure to use during the map.
     */
    public mutating func transform(_ mapping: (HLSTag) throws -> (HLSTag)) throws {
        try mutatingStructure.transform(mapping)
    }
    
    /**
     Grab a ArraySlice representing the given Tag Group.
     
     - parameter forMediaGroup: The media group that is used for the tag selection.
     
     - returns: An ArraySlice of the tags in the given media group.
     */
    public func tags(forMediaGroup group: TagGroupProtocol) -> ArraySlice<HLSTag> {
        return tags[group.range]
    }
    
    /**
     Grab a ArraySlice representing the given Tag Group.
     
     - parameter forMediaGroupIndex: The index of the media group used for the tag selection.
     
     - returns: An ArraySlice of the tags in the given media group.
     */
    public func tags(forMediaGroupIndex index: Int) -> ArraySlice<HLSTag> {
        guard let range = structure.mediaSegmentGroups[safe: index]?.range else {
            return ArraySlice<HLSTag>()
        }
        return tags[range]
    }
    
    private var mutatingStructure: HLSPlaylistStructure {
        mutating get {
            if !isKnownUniquelyReferenced(&structure) {
                structure = HLSPlaylistStructure(withStructure: structure)
            }
            return structure
        }
    }
    
    public var debugDescription: String {
        return "HLSPlaylistCore \(playlistCoreDebugDescription)\n"
    }
    
    public var playlistCoreDebugDescription: String {
        guard let stream = try? self.write(),
            let debugDescription = String(data: stream, encoding: .utf8) else {
            return "Stream write failure. Raw Data: registeredTags:\(registeredTags) \nstructure:\(structure)\n"
        }
        return String(debugDescription)
    }
    
    /**
     Write a playlist.
     
     - throws: Errors for the `HLSWriter` whilst attempting to write
     - returns: `Data` if successful
     */
    public func write() throws -> Data {
        
        let writer = HLSWriter()
        
        let stream = OutputStream.toMemory()
        stream.open()
        
        defer {
            stream.close()
        }
        
        try writer.write(hlsPlaylist: self, toStream: stream)
        if let error = stream.streamError {
            throw OutputStreamError.couldNotWriteToStream(error as NSError)
        }
        else {
            guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
                assertionFailure("This method is expected to always return an NSData instance. Update this code to throw a more descriptive error.")
                throw OutputStreamError.couldNotWriteToStream(nil)
            }
            return data
        }
    }
    
    public private(set) var registeredTags: RegisteredHLSTags
    
    private var structure: HLSPlaylistStructure
}
