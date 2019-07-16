//
//  VariantPlaylist.swift
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
 `VariantPlaylist` is a struct that represents a variant-style HLS playlist.
 */
public typealias VariantPlaylist = PlaylistCore<VariantPlaylistType>

extension PlaylistCore: PlaylistTypeDetermination, PlaylistTimelineTranslator, VariantPlaylistStructureInterface, VariantPlaylistInterface where PT == VariantPlaylistType {
    
    // MARK: VariantPlaylistStructureInterface
    
    public var header: PlaylistTagGroup? { return structure.header }
    public var mediaSegmentGroups: [MediaSegmentPlaylistTagGroup] { return structure.mediaSegmentGroups }
    public var footer: PlaylistTagGroup? { return structure.footer }
    public var mediaSpans: [PlaylistTagSpan] { return structure.mediaSpans }
    
    // MARK: PlaylistTypeDetermination

    public var playlistType: PlaylistType {
        return structure.playlistType
    }
    
    internal func canQueryTimeline() -> Bool {
        guard playlistType == .vod else { return false }
        return true
    }
    
    // MARK: PlaylistTimelineTranslator
    
    public func mediaSequence(forTime time: CMTime) -> MediaSequence? {
        guard canQueryTimeline() else { return nil }
        
        guard let mediaGroup = mediaGroup(forTime: time) else { return nil }
        
        return mediaGroup.mediaSequence
    }
    
    public func mediaSequence(forTagIndex tagIndex: Int) -> MediaSequence? {
        guard let mediaGroup = mediaGroup(forTagIndex: tagIndex) else { return nil }
        
        return mediaGroup.mediaSequence
    }
    
    public func timeRange(forTagIndex tagIndex: Int) -> CMTimeRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let mediaGroup = mediaGroup(forTagIndex: tagIndex) else { return nil }
        
        return mediaGroup.timeRange
    }
    
    public func timeRange(forMediaSequence mediaSequence: MediaSequence) -> CMTimeRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let mediaGroup = mediaGroup(forMediaSequence: mediaSequence) else { return nil }
        
        return mediaGroup.timeRange
    }
    
    public func tagIndexes(forMediaSequence mediaSequence: MediaSequence) -> PlaylistTagIndexRange? {
        guard let mediaGroup = mediaGroup(forMediaSequence: mediaSequence) else { return nil }
        
        return mediaGroup.startIndex...mediaGroup.endIndex
    }
    
    public func tagIndexes(forTime time: CMTime) -> PlaylistTagIndexRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let mediaGroup = mediaGroup(forTime: time) else { return nil }
        
        return mediaGroup.startIndex...mediaGroup.endIndex
    }
    
    public func mediaGroup(forTime time: CMTime) -> MediaSegmentPlaylistTagGroup? {
        let segments = mediaSegmentGroups.filter { $0.timeRange.containsTime(time) }
        
        guard let segment = segments.first else {
            // if we ask for a time that is our playlist's end time, we should return the last segment
            if CMTimeCompare(endTime, time) == 0 {
                return mediaSegmentGroups.last
            }
            return nil
        }
        
        return segment
    }
    
    public func mediaGroup(forTagIndex tagIndex: Int) -> MediaSegmentPlaylistTagGroup? {
        let segments = mediaSegmentGroups.filter { $0.startIndex <= tagIndex && $0.endIndex >= tagIndex }
        
        guard let segment = segments.first else { return nil }
        
        return segment
    }
    
    public func mediaGroup(forMediaSequence mediaSequence: MediaSequence) -> MediaSegmentPlaylistTagGroup? {
        let segments = mediaSegmentGroups.filter { $0.mediaSequence == mediaSequence }
        
        guard let segment = segments.first else { return nil }
        
        return segment
    }
    
    public func segmentName(forMediaSequence mediaSequence: MediaSequence) -> String? {
        guard let group = mediaGroup(forMediaSequence: mediaSequence) else {
            return nil
        }
        guard let locationTag = Array(tags[group.range]).filter({ $0.tagDescriptor == PantosTag.Location }).first else {
            return nil
        }
        return locationTag.tagData.stringValue()
    }
}

/**
 This is a protocol that defines the standard `VariantPlaylist` interface.
 
 This protocol should be used instead of the actual `VariantPlaylist` type when possible.
 */
public protocol VariantPlaylistInterface: PlaylistInterface, VariantPlaylistStructureInterface, PlaylistTimelineTranslator, PlaylistURLDataInterface {}
