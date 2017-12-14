//
//  HLSManifestInterface.swift
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

/// This defines the interface of a HLS manifest
public protocol HLSManifestInterface: HLSManifestStructureInterface, RegisteredHLSTagsProvider, HLSManifestTimelineTranslator, HLSManifestTypeDetermination, HLSManifestPlaylistTypeDetermination {}


// MARK: HLSManifestTypeDetermination

extension HLSManifestInterface {
    
    /**
     Returns the ManifestType of this manifest (master or variant)
     */
    public var type: ManifestType {
        get {
            return tags.type()
        }
    }
}


// MARK: HLSManifestPlaylistTypeDetermination

extension HLSManifestInterface {
    
    /**
     Returns the ManifestPlaylistType of this manifest (VOD, Live or Event)
     */
    public var playlistType: ManifestPlaylistType {
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


// MARK: HLSManifestTimelineTranslator

extension HLSManifestInterface {
    
    internal func canQueryTimeline() -> Bool {
        guard type == .media else { return false }
        guard playlistType == .vod else { return false }
        return true
    }
    
    // MARK: Timeline/Sequencing Functions
    
    public func mediaSequence(forTime time: CMTime) -> MediaSequence? {
        guard canQueryTimeline() else { return nil }
        
        guard let fragmentGroup = fragmentGroup(forTime: time) else { return nil }
        
        return fragmentGroup.mediaSequence
    }
    
    public func mediaSequence(forTagIndex tagIndex: Int) -> MediaSequence? {
        guard canQueryTimeline() else { return nil }
        
        guard let fragmentGroup = fragmentGroup(forTagIndex: tagIndex) else { return nil }
        
        return fragmentGroup.mediaSequence
    }
    
    public func timeRange(forTagIndex tagIndex: Int) -> CMTimeRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let fragmentGroup = fragmentGroup(forTagIndex: tagIndex) else { return nil }
        
        return fragmentGroup.timeRange
    }
    
    public func timeRange(forMediaSequence mediaSequence: MediaSequence) -> CMTimeRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let fragmentGroup = fragmentGroup(forMediaSequence: mediaSequence) else { return nil }
        
        return fragmentGroup.timeRange
    }
    
    public func tagIndexes(forMediaSequence mediaSequence: MediaSequence) -> HLSTagIndexRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let fragmentGroup = fragmentGroup(forMediaSequence: mediaSequence) else { return nil }
        
        return fragmentGroup.startIndex...fragmentGroup.endIndex
    }
    
    public func tagIndexes(forTime time: CMTime) -> HLSTagIndexRange? {
        guard canQueryTimeline() else { return nil }
        
        guard let fragmentGroup = fragmentGroup(forTime: time) else { return nil }
        
        return fragmentGroup.startIndex...fragmentGroup.endIndex
    }
}

    
// MARK: Translators between media sequence/time/tag index
    
extension HLSManifestInterface {
    
    /**
     Returns the MediaFragmentTagGroup for the given time, if the time is within our asset
     
     - parameter forTime: The CMTime that we are querying.
     
     - returns: The MediaFragmentTagGroup that the time occurs within, or nil if the time is outside asset range.
     */
    public func fragmentGroup(forTime time: CMTime) -> MediaFragmentTagGroup? {
        let fragments = mediaFragmentGroups.filter { $0.timeRange.containsTime(time) }
        
        guard let fragment = fragments.first else {
            // if we ask for a time that is our manifest's end time, we should return the last fragment
            if CMTimeCompare(endTime, time) == 0 {
                return mediaFragmentGroups.last
            }
            return nil
        }
        
        return fragment
    }
    
    /**
     Returns the MediaFragmentTagGroup for the given tag index, if the index is within our tag array
     
     - parameter forTagIndex: The tag index that we are querying.
     
     - returns: The MediaFragmentTagGroup that the tag index occurs within, or nil if the tag  is outside our tag array.
     */
    public func fragmentGroup(forTagIndex tagIndex: Int) -> MediaFragmentTagGroup? {
        let fragments = mediaFragmentGroups.filter { $0.startIndex <= tagIndex && $0.endIndex >= tagIndex }
        
        guard let fragment = fragments.first else { return nil }
        
        return fragment
    }
    
    /**
     Returns the MediaFragmentTagGroup for the given MediaSequence, if the media sequence is within our asset
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: The MediaFragmentTagGroup that the MediaSequence occurs within, or nil if the media sequence is outside our asset.
     */
    public func fragmentGroup(forMediaSequence mediaSequence: MediaSequence) -> MediaFragmentTagGroup? {
        let fragments = mediaFragmentGroups.filter { $0.mediaSequence == mediaSequence }
        
        guard let fragment = fragments.first else { return nil }
        
        return fragment
    }
    
    /**
     Returns the fragment name of the media sequence, if that media sequence exists in this manifest.
     
     This function is intended to be useful in debugging and logging.
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: An optional String that is the fragment name. Note that this could be a relative url or a absolute url, depending
     on how the original manifest is written.
     */
    public func fragmentName(forMediaSequence mediaSequence: MediaSequence) -> String? {
        guard let group = fragmentGroup(forMediaSequence: mediaSequence) else {
            return nil
        }
        guard let locationTag = Array(tags[group.range]).filter({ $0.tagDescriptor == PantosTag.Location }).first else {
            return nil
        }
        return locationTag.tagData.stringValue()
    }
}
