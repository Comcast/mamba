//
//  HLSPlaylistInterface.swift
//  mamba
//
//  Created by David Coufal on 4/18/17.
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

/// This defines the interface of a HLS playlist
public protocol HLSPlaylistInterface: HLSPlaylistStructureInterface, RegisteredHLSTagsProvider, HLSPlaylistTimelineTranslator, HLSFileTypeDetermination, HLSPlaylistTypeDetermination {}


// MARK: HLSPlaylistTypeDetermination

extension HLSPlaylistInterface {
    
    /**
     Returns the FileType of this playlist (master or variant)
     */
    public var type: FileType {
        get {
            return tags.type()
        }
    }
}


// MARK: HLSPlaylistPlaylistTypeDetermination

extension HLSPlaylistInterface {
    
    /**
     Returns the PlaylistType of this playlist (VOD, Live or Event)
     */
    public var playlistType: PlaylistType {
        get {
            if type != .media {
                return .unknown
            }
            guard
                let playlistTag = tags.first(where: { $0.tagDescriptor == PantosTag.EXT_X_PLAYLIST_TYPE }),
                let playlistType: HLSPlaylistType = playlistTag.value(forValueIdentifier: PantosValue.playlistType) else {
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
}


// MARK: HLSPlaylistTimelineTranslator

extension HLSPlaylistInterface {
    
    internal func canQueryTimeline() -> Bool {
        guard type == .media else { return false }
        guard playlistType == .vod else { return false }
        return true
    }
    
    // MARK: Timeline/Sequencing Functions
    
    public func mediaSequence(forTime time: CMTime) -> MediaSequence? {
        guard canQueryTimeline() else { return nil }
        
        guard let segmentGroup = segmentGroup(forTime: time) else { return nil }
        
        return segmentGroup.mediaSequence
    }
    
    public func mediaSequence(forTagIndex tagIndex: Int) -> MediaSequence? {
        guard let segmentGroup = segmentGroup(forTagIndex: tagIndex) else { return nil }
        
        return segmentGroup.mediaSequence
    }
    
    public func timeRange(forTagIndex tagIndex: Int) -> CMTimeRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let segmentGroup = segmentGroup(forTagIndex: tagIndex) else { return nil }
        
        return segmentGroup.timeRange
    }
    
    public func timeRange(forMediaSequence mediaSequence: MediaSequence) -> CMTimeRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let segmentGroup = segmentGroup(forMediaSequence: mediaSequence) else { return nil }
        
        return segmentGroup.timeRange
    }
    
    public func tagIndexes(forMediaSequence mediaSequence: MediaSequence) -> HLSTagIndexRange? {
        guard let segmentGroup = segmentGroup(forMediaSequence: mediaSequence) else { return nil }
        
        return segmentGroup.startIndex...segmentGroup.endIndex
    }
    
    public func tagIndexes(forTime time: CMTime) -> HLSTagIndexRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let segmentGroup = segmentGroup(forTime: time) else { return nil }
        
        return segmentGroup.startIndex...segmentGroup.endIndex
    }
}

    
// MARK: Translators between media sequence/time/tag index
    
extension HLSPlaylistInterface {
    
    /**
     Returns the MediaSegmentTagGroup for the given time, if the time is within our asset
     
     - parameter forTime: The CMTime that we are querying.
     
     - returns: The MediaSegmentTagGroup that the time occurs within, or nil if the time is outside asset range.
     */
    public func segmentGroup(forTime time: CMTime) -> MediaSegmentTagGroup? {
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
    public func segmentGroup(forTagIndex tagIndex: Int) -> MediaSegmentTagGroup? {
        let segments = mediaSegmentGroups.filter { $0.startIndex <= tagIndex && $0.endIndex >= tagIndex }
        
        guard let segment = segments.first else { return nil }
        
        return segment
    }
    
    /**
     Returns the MediaSegmentTagGroup for the given MediaSequence, if the media sequence is within our asset
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: The MediaSegmentTagGroup that the MediaSequence occurs within, or nil if the media sequence is outside our asset.
     */
    public func segmentGroup(forMediaSequence mediaSequence: MediaSequence) -> MediaSegmentTagGroup? {
        let segments = mediaSegmentGroups.filter { $0.mediaSequence == mediaSequence }
        
        guard let segment = segments.first else { return nil }
        
        return segment
    }
    
    /**
     Returns the segment name of the media sequence, if that media sequence exists in this playlist.
     
     This function is intended to be useful in debugging and logging.
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: An optional String that is the segment name. Note that this could be a relative url or a absolute url, depending
     on how the original playlist is written.
     */
    public func segmentName(forMediaSequence mediaSequence: MediaSequence) -> String? {
        guard let group = segmentGroup(forMediaSequence: mediaSequence) else {
            return nil
        }
        guard let locationTag = Array(tags[group.range]).filter({ $0.tagDescriptor == PantosTag.Location }).first else {
            return nil
        }
        return locationTag.tagData.stringValue()
    }
}
