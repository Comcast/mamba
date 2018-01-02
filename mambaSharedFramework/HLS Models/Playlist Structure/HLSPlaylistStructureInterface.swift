//
//  HLSPlaylistStructureInterface.swift
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
 This protocol defines the interface of a object that represents HLS playlist structure.
 */
public protocol HLSPlaylistStructureInterface {
    
    /**
     This array is a list of every line in a HLS playlist. Each line is defined by a `HLSTag` object.
     */
    var tags: [HLSTag] { get }
    
    /**
     The `header` is all tags that describe the playlist initially. All `HLSTag`s at the top of the playlist that
     have the scope HLSTagDescriptorScope.wholePlaylist or HLSTagDescriptorScope.mediaSpanner are part of this
     structure.
     */
    var header: TagGroup? { get }
    
    /**
     All the `HLSTag`s in the middle of the playlist that generally have the scope HLSTagDescriptorScope.mediaSegment
     make up the `mediaSegmentGroups`. They are deliniated by "divider" tags, such as `#EXTINF`. Every divider tag
     begins a new media segment group. Each media segment group describes a segment (in the case of a variant
     playlist) or another playlist (in the case of a master playlist).
     */
    var mediaSegmentGroups: [MediaSegmentTagGroup] { get }
    
    /**
     The `mediaSpans` array keeps track of all the tags that describe many other tags.
     For example, the `#EXT-X-KEY` tag describes how many segments are encrypted.
     */
    var mediaSpans: [TagSpan] { get }
    
    /**
     The `footer` is all `HLSTag`s at the end of the playlist that have the scope HLSTagDescriptorScope.wholePlaylist.
     */
    var footer: TagGroup? { get }
}

// MARK: Playlist Convenience Functions

extension HLSPlaylistStructureInterface {
    
    /**
     Returns the start time of this playlist.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a start time.
     */
    public var startTime: CMTime {
        guard let timeRange = mediaSegmentGroups.first?.timeRange else { return kCMTimeInvalid }
        return timeRange.start
    }
    
    /**
     Returns the end time of this playlist.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a end time.
     */
    public var endTime: CMTime {
        guard let timeRange = mediaSegmentGroups.last?.timeRange else { return kCMTimeInvalid }
        return timeRange.end
    }
    
    /**
     Returns the duration of this playlist.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a duration
     */
    public var duration: CMTime {
        guard startTime.isNumeric && endTime.isNumeric else {
            return kCMTimeInvalid
        }
        return CMTimeSubtract(endTime, startTime)
    }
    
    /**
     Returns all `MediaSegmentTagGroup`s that contain tags with particular names.
     */
    public func mediaSegmentGroups<T:Sequence>(containingTagsNamed tagNames: T) -> [MediaSegmentTagGroup]
        where T.Iterator.Element == HLSStringRef
    {
        let queryTagNameSet = Set(tagNames)
        
        var results = [MediaSegmentTagGroup]()
        
        for group in mediaSegmentGroups {
            let tagNames: Set<HLSStringRef> = Set(tags[group.range].flatMap { $0.tagName })
            if queryTagNameSet.intersection(tagNames).count > 0 {
                results.append(group)
            }
        }
        return results
    }
}
