//
//  PlaylistStructureCore.swift
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

public final class PlaylistStructureCore<PSD: PlaylistStructureDelegate>: PlaylistStructureInterface {
    
    private var structureState: StructureState = .dirtyRequiresRebuild
    
    private var _tags: [PlaylistTag]
    private let delegate: PSD
    
    var _structureData: PSD.StructureType
    
    private let queue = DispatchQueue(label: "com.comcast.mamba.playliststructurecore",
                                      qos: .userInitiated)
    
    public convenience init(withTags tags: [PlaylistTag]) {
        self.init(withTags: tags,
                  withDelegate: PSD(),
                  withStructureData: PSD.StructureType())
    }
    
    init(withTags tags: [PlaylistTag],
         withDelegate delegate: PSD,
         withStructureData structureData: PSD.StructureType) {
        self._tags = tags
        self.delegate = delegate
        self._structureData = structureData
    }
    
    required public init(withStructure structure: PlaylistStructureCore) {
        self._tags = structure.tags
        self.delegate = structure.delegate
        self.structureState = structure.structureState
        self._structureData = structure._structureData
    }
    
    public var tags: [PlaylistTag] {
        return queue.sync {
            return _tags
        }
    }

    public var structureData: PSD.StructureType {
        return queue.sync {
            rebuildIfRequired()
            return _structureData
        }
    }

    public func insert(tag: PlaylistTag, atIndex index: Int) {
        queue.sync {
            _tags.insert(tag, at: index)
            added(tags: [tag], atIndex: index)
        }
    }
    
    public func insert(tags: [PlaylistTag], atIndex index: Int) {
        queue.sync {
            self._tags.insert(contentsOf: tags, at: index)
            added(tags: tags, atIndex: index)
        }
    }
    
    public func delete(atIndex index: Int) {
        queue.sync {
            deleted(numberOfTags: 1, atIndex: index)
            _tags.remove(at: index)
        }
    }
    
    public func delete(atRange range: PlaylistTagIndexRange) {
        queue.sync {
            deleted(numberOfTags: range.count, atIndex: range.lowerBound)
            _tags.removeSubrange(range)
        }
    }
    
    public func transform(_ mapping: (PlaylistTag) throws -> (PlaylistTag)) throws {
        try queue.sync {
            _tags = try _tags.map(mapping)
            structureState = .dirtyRequiresRebuild
        }
    }
    
    /**
     This function will rebuild structure elements based on the types of edits that have been
     done to the tags array since the last array.
     */
    private func rebuildIfRequired() {
        defer {
            structureState = .clean
        }
        switch structureState {
        case .clean:
            return
        case .dirtyWithTagChanges(let tagChanges):
            for tagChange in tagChanges {
                let result = delegate.changed(numberOfTags: tagChange.tagChangeCount,
                                              atIndex: tagChange.index,
                                              inTagArray: _tags,
                                              withInitialStructure: _structureData)
                _structureData = result.structure
                if result.hadToRebuildFromScratch {
                    // we can early exit since we've already done a full rebuild
                    return
                }
            }
        case .dirtyRequiresRebuild:
            _structureData = delegate.rebuild(usingTagArray: _tags)
        }
    }
    
    private func added(tags: [PlaylistTag], atIndex index: Int) {
        
        if structureState == .dirtyRequiresRebuild {
            return
        }
        for tag in tags {
            if delegate.isTagStructural(tag) {
                structureState = .dirtyRequiresRebuild
                return
            }
        }
        if case let StructureState.dirtyWithTagChanges(tagChanges) = structureState {
            var newTagChanges = tagChanges
            newTagChanges.append(TagChangeRecord(tagChangeCount: tags.count, index: index))
            structureState = .dirtyWithTagChanges(newTagChanges)
        }
        else {
            structureState = .dirtyWithTagChanges([TagChangeRecord(tagChangeCount: tags.count, index: index)])
        }
    }
    
    private func deleted(numberOfTags: Int, atIndex index: Int) {
        
        if structureState == .dirtyRequiresRebuild {
            return
        }
        for tagIndex in index...(index + numberOfTags - 1) {
            if delegate.isTagStructural(_tags[tagIndex]) {
                structureState = .dirtyRequiresRebuild
                return
            }
        }
        if case let StructureState.dirtyWithTagChanges(tagChanges) = structureState {
            var newTagChanges = tagChanges
            newTagChanges.append(TagChangeRecord(tagChangeCount: -numberOfTags, index: index))
            structureState = .dirtyWithTagChanges(newTagChanges)
        }
        else {
            structureState = .dirtyWithTagChanges([TagChangeRecord(tagChangeCount: -numberOfTags, index: index)])
        }
    }
}

/**
 To use `PlaylistStructureCore`, you must supply an object that implements this interface.
 
 This object is intended to implement functions to rebuild structure while adding and
 deleting tags from your `PlaylistStructureCore`.
 
 For example, in variant playlists, you might want to keep track of "header" tags,
 tags that represent and describe each fragment, and the tags at the "footer". In fact,
 that is what the `VariantPlaylist` keeps track of in it's structure.
 
 You are guaranteed that each call this is made to this object will be on the
 private queue for `PlaylistStructureCore`, so no need to worry about thread safety.
 Your data will be protected in a queue the same way `PlaylistStructureCore` protects
 its private tag array.
 */
public protocol PlaylistStructureDelegate: class {
    
    associatedtype StructureType: PlaylistStructure
    
    init()
    
    /**
     Return true if this tag is a marker for structure boundaries in your structure definition.
     
     - parameter tag: The tag to query
     
     - returns: True if this tag is a structure boundary-defining tag.
     */
    func isTagStructural(_ tag: PlaylistTag) -> Bool
    
    /**
     `PlaylistStructureCore` has determined that the structure has changed so much that a
     complete rebuild is required.
     
     - parameter usingTagArray: The list of tags that defines our playlist.
     
     - returns: New structure of `StructureType` type
     */
    func rebuild(usingTagArray tags: [PlaylistTag]) -> StructureType
    
    /**
     `PlaylistStructureCore` has noted a minor change to the tag array and requests that
     we update the structure.

     - parameter numberOfTags: The number of tags added or deleted at our index point. Will be negative for deleted tags.
     - parameter atIndex: The insertion or deletion point.
     - parameter inTagArray: The list of tags that defines our playlist.
     - parameter withInitialStructure: The existing structure to be updated.

     - returns: A PlaylistStructureChangeResult given info about what the function did to rebuild and results.
     */
    func changed(numberOfTags alterCount: Int,
                 atIndex index: Int,
                 inTagArray tags: [PlaylistTag],
                 withInitialStructure structure: StructureType) -> PlaylistStructureChangeResult<StructureType>
}

public struct PlaylistStructureChangeResult<StructureType> {
    /// `false` if we were able to fix up ourselves, `true` if we has to rebuild structure from scratch
    let hadToRebuildFromScratch: Bool
    /// New structure after rebuild
    let structure: StructureType
}

struct PlaylistStructureConstructor {
    
    private let tagDescriptorForMediaGroupBoundaries: PantosTag
    
    init(withTagDescriptorForMediaGroupBoundaries tagDescriptorForMediaGroupBoundaries: PantosTag) {
        self.tagDescriptorForMediaGroupBoundaries = tagDescriptorForMediaGroupBoundaries
    }
    
    func generateMediaGroups(fromTags tags: [PlaylistTag]) throws -> (header: PlaylistTagGroup?, mediaSegmentGroups: [MediaSegmentPlaylistTagGroup], footer: PlaylistTagGroup?) {
        
        var mediaSegmentGroups = [MediaSegmentPlaylistTagGroup]()
        
        var currentMediaSequence: MediaSequence = defaultMediaSequence
        var lastRecordedTime: CMTime = CMTime.invalid
        var currentSegmentDuration: CMTime = CMTime.invalid
        var discontinuity = false
        
        // collect indices for media sequence and skip tags as they impact the initial media sequence value
        var mediaSequenceTagIndices = [Int]()
        var skipTagIndices = [Int]()
        tags.enumerated().forEach {
            switch $0.element.tagDescriptor {
            case PantosTag.EXT_X_MEDIA_SEQUENCE: mediaSequenceTagIndices.append($0.offset)
            case PantosTag.EXT_X_SKIP: skipTagIndices.append($0.offset)
            default: break
            }
        }

        // figure out our media sequence start (defaults to 1 if not specified)
        if mediaSequenceTagIndices.count > 0 {
            assert(mediaSequenceTagIndices.count == 1, "Unexpected to have more than one media sequence")
            if
                let mediaSequenceIndex = mediaSequenceTagIndices.first,
                let startMediaSequence: MediaSequence = tags[mediaSequenceIndex].value(
                    forValueIdentifier: PantosValue.sequence
                )
            {
                currentMediaSequence = startMediaSequence
            }
        }

        // account for any skip tags (since a delta update replaces all segments earlier than the skip boundary, the
        // SKIPPED-SEGMENTS value will effectively update the current media sequence value of the first segment, so safe
        // to do this here and not within the looping through media group tags below).
        if skipTagIndices.count > 0 {
            assert(skipTagIndices.count == 1, "Unexpected to have more than one skip tag")
            if
                let skipTagIndex = skipTagIndices.first,
                let skippedSegments: Int = tags[skipTagIndex].value(forValueIdentifier: PantosValue.skippedSegments)
            {
                currentMediaSequence += skippedSegments
            }
        }
        
        // find the "header" portion by finding the first ".mediaSegment" scoped tag
        let mediaStartIndexOptional = tags.firstIndex(where: { $0.scope() == .mediaSegment })
        
        guard let mediaStartIndex = mediaStartIndexOptional else {
            if tags.count == 0 {
                // if we have no tags, we have no content at all
                return (header: nil,
                        mediaSegmentGroups: mediaSegmentGroups,
                        footer: nil)
            }
            // if we don't have any media segment tags, it's all header
            return (header: PlaylistTagGroup(range: 0...(tags.endIndex - 1)),
                    mediaSegmentGroups: mediaSegmentGroups,
                    footer: nil)
        }
        
        var headerEndIndex: Int
        if mediaStartIndex > 0 {
            headerEndIndex = tags.index(mediaStartIndex, offsetBy: -1) // move back one to get to the end of header tags
        }
        else {
            headerEndIndex = 0
        }
        
        // find the "footer" portion by finding the last ".mediaSegment" scoped tag
        let mediaGroupsEndIndexOptional = tags.findIndexBeforeIndex(index: tags.endIndex, predicate: { $0.scope() == .mediaSegment })
        
        var footerTags: [PlaylistTag]
        var lastIndex = tags.endIndex
        var mediaGroupsEndIndex: Int
        if let mediaGroupsEndIndexNonOptional = mediaGroupsEndIndexOptional {
            mediaGroupsEndIndex = mediaGroupsEndIndexNonOptional
            lastIndex = tags.index(mediaGroupsEndIndex, offsetBy: 1) // we move forward one, because mediaGroupsEndIndex is the last media segment tag (likely a Location), and we want the tag _after_ that
            footerTags = Array(tags[lastIndex..<tags.endIndex])
        }
        else {
            mediaGroupsEndIndex = tags.index(tags.endIndex, offsetBy: -1)
            // we don't have any footer tags
            footerTags = [PlaylistTag]()
        }
        let footerStartIndex = tags.endIndex - footerTags.count
        let footerEndIndex = footerStartIndex + footerTags.count - 1
        
        // find the media groups by stepping through each tag
        // we have to scan for media group metadata at the same time, so this is likely the most efficient way of doing this
        
        var mediaGroupBeginIndex = mediaStartIndex
        
        for tagIndex in mediaStartIndex...mediaGroupsEndIndex {
            
            let tag = tags[tagIndex]
            
            if tag.tagDescriptor == tagDescriptorForMediaGroupBoundaries {
                currentSegmentDuration = tag.duration
            }
            
            if tag.tagDescriptor == PantosTag.EXT_X_DISCONTINUITY {
                discontinuity = true
            }
            
            if tag.tagDescriptor == PantosTag.Location {
                
                // this marks the end of our current media segment group
                // if we're doing segments we care about durations
                if tagDescriptorForMediaGroupBoundaries == PantosTag.EXTINF {
                    lastRecordedTime = lastRecordedTime.isValid ? lastRecordedTime : CMTime(seconds: 0, preferredTimescale: CMTimeScale.defaultMambaTimeScale)
                    if !(currentSegmentDuration.isNumeric && currentSegmentDuration.seconds > 0.0) {
                        throw ParseError.foundMediaSegmentWithoutDuration(inMediaSequence: currentMediaSequence)
                    }
                }
                
                let timeRange = CMTimeRange(start: lastRecordedTime, duration: currentSegmentDuration)
                
                mediaSegmentGroups.append(MediaSegmentPlaylistTagGroup(range: mediaGroupBeginIndex...tagIndex,
                                                                       mediaSequence: currentMediaSequence,
                                                                       timeRange: timeRange,
                                                                       discontinuity: discontinuity))
                
                // move forward for next media group
                currentMediaSequence += 1
                lastRecordedTime += currentSegmentDuration
                mediaGroupBeginIndex = tagIndex + 1
                
                // reset for next media group
                currentSegmentDuration = CMTime.invalid
                discontinuity = false
            }
        }
        
        return (header: PlaylistTagGroup(range: 0...headerEndIndex),
                mediaSegmentGroups: mediaSegmentGroups,
                footer: footerTags.count > 0 ? PlaylistTagGroup(range: footerStartIndex...footerEndIndex) : nil)
    }
    
    static func generateMediaSpans(fromTags tags:[PlaylistTag],
                                   header: PlaylistTagGroup?,
                                   mediaSegmentGroups: [MediaSegmentPlaylistTagGroup]) throws -> [PlaylistTagSpan] {
        
        var mediaSpans = [PlaylistTagSpan]()
        
        // handle our only known spannable tag, `EXT-X-KEY`
        let keyTags = tags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
        var keyCount = 0
        var startKeyIndex: Int? = nil
        var currentIndex: Int = 0
        var startKeyTag: PlaylistTag? = nil
        
        // handle any X-KEY tags in the header
        if let header = header {
            let headerTags = tags[header.range]
            let headerKeyTags = headerTags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
            if let firstXKeyTag = headerKeyTags.last {
                // we only have to handle the last X-KEY in the header, as previous X-KEY's will be superceded by this one
                keyCount += headerKeyTags.count
                startKeyIndex = 0 // if we find one in the header, we are always starting at the first index
                startKeyTag = firstXKeyTag
            }
        }
        
        // handle X-KEY tags found interior to the playlist
        for mediaSegmentGroup in mediaSegmentGroups {
            
            let segmentTags = tags[mediaSegmentGroup.range]
            let localKeyTags = segmentTags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
            
            if localKeyTags.count > 0 {
                keyCount += localKeyTags.count
                
                // if we have a tag in the first mediaGroup, we just forget all about our header tags and this overrides it
                if (currentIndex == 0) {
                    startKeyIndex = nil
                    startKeyTag = nil
                }
                
                if let startKeyIndex = startKeyIndex, let startKeyTag = startKeyTag {
                    // we are closing out our last key
                    mediaSpans.append(PlaylistTagSpan(parentTag: startKeyTag, tagMediaSpan: startKeyIndex...currentIndex - 1))
                }
                
                startKeyIndex = currentIndex
                // we only look for the last tag, as previous X-KEY tags are superceded by this one
                startKeyTag = localKeyTags.last! // forced unwrap is safe, we checked above for count > 0
            }
            
            currentIndex += 1
        }
        
        // close out our last tag
        if let startKeyIndex = startKeyIndex, let startKeyTag = startKeyTag {
            mediaSpans.append(PlaylistTagSpan(parentTag: startKeyTag, tagMediaSpan: startKeyIndex...(currentIndex - 1)))
        }
        
        assert(keyCount == keyTags.count, "we missed a key tag")
        
        return mediaSpans
    }
    
    private enum ParseError: Error {
        case foundMediaSegmentWithoutDuration(inMediaSequence: MediaSequence)
    }
}

public protocol PlaylistStructure {
    init()
}
