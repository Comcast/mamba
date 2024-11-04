//
//  VariantPlaylistTagMatchSegmentInfo.swift
//  mamba
//
//  Created by David Coufal on 6/10/19.
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


public protocol PlaylistSegmentMatcher {
    /**
     Query a variant playlist segment-based info with a predicate based on tags.
     
     It's pretty common to want to know "what segment(s) in my variant playlist have a particular tag
     descriptor?" This is useful for a variety of signaling situations. This function is syntatic sugar
     to easily get access to this info.
     
     Example: Your media server places signals for "chapters" in your variant playlists. You can use this
     function to figure out when those signals appear so you can create a custom UI for this media. The
     code might look something like this:
     
     ```
     let chapterMarkSegments = variantPlaylist.getPlaylistSegmentMatches(usingPredicate: { $0.tagDescriptor == ChapterMarkTagDescriptor.EXT_X_CHAPTERMARK })
     for chapterMarkSegment in chapterMarkSegments {
       // tell the UI about the chapter mark time
       switch (chapterMarkSegment.playlistTime) {
         case .timeMatch(let timeRange):
           markChapter(atTime: timeRange.start)
         default:
           break
       }
     }
     ```
     
     - parameter usingPredicate: A `VariantPlaylistTagMatchPredicate` closure that is used to select individual
     tags in the playlist. Any segments containing those tags will be returned in the result to this call.
     
     - parameter withMatchesInHeaderMatchingToFirstMediaSegment: Asks the algorithm to treat matching tags in
     the "header" section of the playlist as if they belong to the first segment. Since this is generally
     correct behavior for HLS, this defaults to `true` but it can be turned off if that behavior is not desireable.
     
     - returns: An array of `VariantPlaylistTagMatchSegmentInfo` structs describing each hit. (Note that if you have
     more than one hit per segment your segment will show up more than once).
     */
    func getPlaylistSegmentMatches(usingPredicate predicate: VariantPlaylistTagMatchPredicate,
                                   withMatchesInHeaderMatchingToFirstMediaSegment matchesInHeaderMatchToFirst: Bool) -> [VariantPlaylistTagMatchSegmentInfo]
}

extension PlaylistSegmentMatcher {
    func getPlaylistSegmentMatches(usingPredicate predicate: VariantPlaylistTagMatchPredicate) -> [VariantPlaylistTagMatchSegmentInfo] {
        return getPlaylistSegmentMatches(usingPredicate: predicate, withMatchesInHeaderMatchingToFirstMediaSegment: true)
    }
}

extension PlaylistCore where PT == VariantPlaylistType {
    
    public func getPlaylistSegmentMatches(usingPredicate predicate: VariantPlaylistTagMatchPredicate,
                                          withMatchesInHeaderMatchingToFirstMediaSegment matchesInHeaderMatchToFirst: Bool = true) -> [VariantPlaylistTagMatchSegmentInfo] {
        
        let matchingTagIndices = tags.indices.filter { predicate(tags[$0]) }
        
        var matches = [VariantPlaylistTagMatchSegmentInfo]()
        
        for tagIndex in matchingTagIndices {
            
            let matchingMediaGroup: MediaSegmentPlaylistTagGroup
            let foundInHeader: Bool
            
            if let mediaGroup = mediaGroup(forTagIndex: tagIndex) {
                matchingMediaGroup = mediaGroup
                foundInHeader = false
            }
            else if matchesInHeaderMatchToFirst,
                let firstMediaGroup = mediaSegmentGroups.first,
                header?.range.contains(tagIndex) == true {
                matchingMediaGroup = firstMediaGroup
                foundInHeader = true
            }
            else {
                // our tag match must be in the footer...
                continue
            }
            
            guard let tagGroupIndex = mediaSegmentGroups.firstIndex(of: matchingMediaGroup) else {
                assertionFailure("We should be able to find the index of the media group that we just found.")
                continue
            }
            
            let playlistTime: PlaylistTimeMatch
            if canQueryTimeline() {
                playlistTime = .timeMatch(matchingMediaGroup.timeRange)
            }
            else {
                playlistTime = .noTimeMatchForNonVODPlaylist
            }
            
            matches.append(VariantPlaylistTagMatchSegmentInfo(tagIndex: tagIndex,
                                                              mediaSequence: matchingMediaGroup.mediaSequence,
                                                              playlistTime: playlistTime,
                                                              tagIndexRangeOfMediaGroup: matchingMediaGroup.range,
                                                              tagGroupIndex: tagGroupIndex,
                                                              containsDiscontinuity: matchingMediaGroup.discontinuity,
                                                              foundInHeader: foundInHeader))
        }
        
        return matches
    }
}

/// A closure to determine if a given `PlaylistTag` is a match for a filter.
public typealias VariantPlaylistTagMatchPredicate = (PlaylistTag) -> (Bool)

/// A struct containing info about a segment match in a variant playlist.
public struct VariantPlaylistTagMatchSegmentInfo {
    /// The index of the tag in the tag array of the original playlist.
    public let tagIndex: Int
    /// The media sequence number of the segment where the match occurred.
    public let mediaSequence: MediaSequence
    /// The time in the VOD playlist of the segment where the match occurred (will be `.noTimeMatchForNonVODPlaylist` for non VOD playlists).
    public let playlistTime: PlaylistTimeMatch
    /// The tag index range (of the playlist tag array) of the segment where the match occurred.
    public let tagIndexRangeOfMediaGroup: PlaylistTagIndexRange
    /// The tag group index (of the `mediaSegmentGroups` array) of the segment where the match occurred.
    public let tagGroupIndex: Int
    /// The discontinuity status of the segment where the match occurred.
    public let containsDiscontinuity: Bool
    /// True if the match was found in the "header" of the playlist, false otherwise.
    public let foundInHeader: Bool
}

/// An enum value representing the time status of a VariantPlaylistTagMatchSegmentInfo
public enum PlaylistTimeMatch {
    /// We do not have a time match as the playlist was not a VOD playlist.
    case noTimeMatchForNonVODPlaylist
    /// A time match for the segment from a VOD playlist.
    case timeMatch(CMTimeRange)
}

