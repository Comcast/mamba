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
    
    public var header: TagGroup? { return structure.header }
    public var mediaSegmentGroups: [MediaSegmentTagGroup] { return structure.mediaSegmentGroups }
    public var footer: TagGroup? { return structure.footer }
    public var mediaSpans: [TagSpan] { return structure.mediaSpans }
    
    // MARK: PlaylistTypeDetermination

    public var playlistType: PlaylistType {
        get {
            guard
                let playlistTag = tags.first(where: { $0.tagDescriptor == PantosTag.EXT_X_PLAYLIST_TYPE }),
                let playlistType: PlaylistHLSType = playlistTag.value(forValueIdentifier: PantosValue.playlistType) else {
                    // if the #EXT-X-PLAYLIST-TYPE tag is not present, it's not 100% clear from the Pantos spec what to do.
                    // here, we choose to check for the #EXT-X-ENDLIST tag as well. If it is present, we can assume we are VOD.
                    // otherwise we assume live.
                    // other checks could be added here as needed.
                    if let _ = tags.first(where: { $0.tagDescriptor == PantosTag.EXT_X_ENDLIST }) {
                        return .vod
                    }
                    return .live
            }
            return playlistType.type == .VOD ? .vod : .event
        }
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
    
    public func tagIndexes(forMediaSequence mediaSequence: MediaSequence) -> HLSTagIndexRange? {
        guard let mediaGroup = mediaGroup(forMediaSequence: mediaSequence) else { return nil }
        
        return mediaGroup.startIndex...mediaGroup.endIndex
    }
    
    public func tagIndexes(forTime time: CMTime) -> HLSTagIndexRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let mediaGroup = mediaGroup(forTime: time) else { return nil }
        
        return mediaGroup.startIndex...mediaGroup.endIndex
    }
    
    // MARK: Utility functions to get media segment info from time/media sequence number/tag index
    
    /**
     Returns the MediaSegmentTagGroup for the given time, if the time is within our asset
     
     - parameter forTime: The CMTime that we are querying.
     
     - returns: The MediaSegmentTagGroup that the time occurs within, or nil if the time is outside asset range.
     */
    public func mediaGroup(forTime time: CMTime) -> MediaSegmentTagGroup? {
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
    
    /**
     Returns the MediaSegmentTagGroup for the given tag index, if the index is within our tag array
     
     - parameter forTagIndex: The tag index that we are querying.
     
     - returns: The MediaSegmentTagGroup that the tag index occurs within, or nil if the tag  is outside our tag array.
     */
    public func mediaGroup(forTagIndex tagIndex: Int) -> MediaSegmentTagGroup? {
        let segments = mediaSegmentGroups.filter { $0.startIndex <= tagIndex && $0.endIndex >= tagIndex }
        
        guard let segment = segments.first else { return nil }
        
        return segment
    }
    
    /**
     Returns the MediaSegmentTagGroup for the given MediaSequence, if the media sequence is within our asset
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: The MediaSegmentTagGroup that the MediaSequence occurs within, or nil if the media sequence is outside our asset.
     */
    public func mediaGroup(forMediaSequence mediaSequence: MediaSequence) -> MediaSegmentTagGroup? {
        let segments = mediaSegmentGroups.filter { $0.mediaSequence == mediaSequence }
        
        guard let segment = segments.first else { return nil }
        
        return segment
    }
    
    /**
     Returns the segment name of the media sequence, if that media sequence exists in this playlist.
     
     This function is intended to be useful in debugging and logging.
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: An optional String that is the segment name. Note that this could be a relative url or an absolute url, depending
     on how the original playlist is written.
     */
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
public protocol VariantPlaylistInterface: PlaylistInterface, VariantPlaylistStructureInterface, PlaylistTimelineTranslator, PlaylistTypeDetermination, PlaylistURLDataInterface {}
