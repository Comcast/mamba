//
//  PlaylistTimelineTranslator.swift
//  mamba
//
//  Created by David Coufal on 10/13/16.
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
import CoreMedia

/**
 This protocol describes an object that can translate between times, media sequence and index of a tag
 within a HLS playlist.
 */
public protocol PlaylistTimelineTranslator {
    
    /**
     Returns the media sequence for the given time, if the time is within our asset.
     
     - parameter forTime: The CMTime that we are querying.
     
     - returns: The MediaSequence number of the time, or nil if the time is outside asset range.
     */
    func mediaSequence(forTime time: CMTime) -> MediaSequence?
    
    /**
     Returns the media sequence for the given tag, if the tag index exists
     
     - parameter forTagIndex: The tag index that we are querying.
     
     - returns: The MediaSequence number of the time, or nil.
     */
    func mediaSequence(forTagIndex tagIndex: Int) -> MediaSequence?
    
    /**
     Returns the segment time range for the given tag, if the tag index exists
     
     - parameter forTagIndex: The tag index that we are querying.
     
     - returns: The CMTimeRange covering the tag index, or nil if the tag index does not exist or point to valid times.
     */
    func timeRange(forTagIndex tagIndex: Int) -> CMTimeRange?
    
    /**
     Returns the segment time range for the given media sequence, if the media sequence exists
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: The CMTimeRange covering the media sequence number, or nil if the tag index does not exist or point to valid times.
     */
    func timeRange(forMediaSequence mediaSequence: MediaSequence) -> CMTimeRange?
    
    /**
     Returns the tag indexes for the given media sequence, if the media sequence exists
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: The PlaylistTagIndexRange that covers the media sequence number, or nil if the media sequence is not present.
     */
    func tagIndexes(forMediaSequence mediaSequence: MediaSequence) -> PlaylistTagIndexRange?
    
    /**
     Returns the tag indexes for the given time, if the time is within our asset
     
     - parameter forTime: The CMTime that we are querying.
     
     - returns: The PlaylistTagIndexRange that the time occurs within, or nil if the time is outside asset range.
     */
    func tagIndexes(forTime time: CMTime) -> PlaylistTagIndexRange?
    
    /**
     Returns the MediaSegmentPlaylistTagGroup for the given time, if the time is within our asset
     
     - parameter forTime: The CMTime that we are querying.
     
     - returns: The MediaSegmentPlaylistTagGroup that the time occurs within, or nil if the time is outside asset range.
     */
    func mediaGroup(forTime time: CMTime) -> MediaSegmentPlaylistTagGroup?
    
    /**
     Returns the MediaSegmentPlaylistTagGroup for the given tag index, if the index is within our tag array
     
     - parameter forTagIndex: The tag index that we are querying.
     
     - returns: The MediaSegmentPlaylistTagGroup that the tag index occurs within, or nil if the tag  is outside our tag array.
     */
    func mediaGroup(forTagIndex tagIndex: Int) -> MediaSegmentPlaylistTagGroup?
    
    /**
     Returns the MediaSegmentPlaylistTagGroup for the given MediaSequence, if the media sequence is within our asset
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: The MediaSegmentPlaylistTagGroup that the MediaSequence occurs within, or nil if the media sequence is outside our asset.
     */
    func mediaGroup(forMediaSequence mediaSequence: MediaSequence) -> MediaSegmentPlaylistTagGroup?
    
    /**
     Returns the segment name of the media sequence, if that media sequence exists in this playlist.
     
     This function is intended to be useful in debugging and logging.
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: An optional String that is the segment name. Note that this could be a relative url or an absolute url, depending
     on how the original playlist is written.
     */
    func segmentName(forMediaSequence mediaSequence: MediaSequence) -> String?
    
    /// Returns the start time of the timeline if valid and determinable, kCMTimeInvalid otherwise
    var startTime: CMTime { get }
    
    /// Returns the end time of the timeline if valid and determinable, kCMTimeInvalid otherwise
    var endTime: CMTime { get }
}
