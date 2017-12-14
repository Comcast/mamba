//
//  HLSManifestTimelineTranslator.swift
//  helio
//
//  Created by David Coufal on 10/13/16.
//  Copyright © 2016 Comcast Corporation.
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
 within a HLS manifest.
 */
public protocol HLSManifestTimelineTranslator {
    
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
     Returns the fragment time range for the given tag, if the tag index exists
     
     - parameter forTagIndex: The tag index that we are querying.
     
     - returns: The CMTimeRange covering the tag index, or nil if the tag index does not exist or point to valid times.
     */
    func timeRange(forTagIndex tagIndex: Int) -> CMTimeRange?
    
    /**
     Returns the fragment time range for the given media sequence, if the media sequence exists
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: The CMTimeRange covering the media sequence number, or nil if the tag index does not exist or point to valid times.
     */
    func timeRange(forMediaSequence mediaSequence: MediaSequence) -> CMTimeRange?
    
    /**
     Returns the tag indexes for the given media sequence, if the media sequence exists
     
     - parameter forMediaSequence: The MediaSequence that we are querying.
     
     - returns: The HLSTagIndexRange that covers the media sequence number, or nil if the media sequence is not present.
     */
    func tagIndexes(forMediaSequence mediaSequence: MediaSequence) -> HLSTagIndexRange?
    
    /**
     Returns the tag indexes for the given time, if the time is within our asset
     
     - parameter forTime: The CMTime that we are querying.
     
     - returns: The HLSTagIndexRange that the time occurs within, or nil if the time is outside asset range.
     */
    func tagIndexes(forTime time: CMTime) -> HLSTagIndexRange?
    
    /// Returns the start time of the timeline if valid and determinable, kCMTimeInvalid otherwise
    var startTime: CMTime { get }
    
    /// Returns the end time of the timeline if valid and determinable, kCMTimeInvalid otherwise
    var endTime: CMTime { get }
}
