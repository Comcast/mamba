//
//  PlaylistTagGroup.swift
//  mamba
//
//  Created by David Coufal on 4/6/17.
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
 A protocol for a object that represents a group of `PlaylistTag`s
 */
public protocol PlaylistTagGroupProtocol {
    /**
     The range of this group within the PlaylistInterface's `tags` array.
     
     Note that this is a closed style range, i.e. 12...17.
     */
    var range: PlaylistTagIndexRange { get }
}

public extension PlaylistTagGroupProtocol {
    
    /// Convenience function to get the start index of the range of this PlaylistTagGroup
    public var startIndex: Int {
        return range.lowerBound
    }
    
    /// Convenience function to get the end index of the range of this PlaylistTagGroup
    public var endIndex: Int {
        return range.upperBound
    }
}

/**
 An object to model a group of related and contiguous tags within a PlaylistInterface.
 */
public struct PlaylistTagGroup: PlaylistTagGroupProtocol, CustomDebugStringConvertible {
    
    public var range: PlaylistTagIndexRange
    
    public var debugDescription: String {
        return "PlaylistTagGroup startIndex: \(startIndex) endIndex:\(endIndex)"
    }
}

/**
 An object to model a group of related and contiguous tags that represent a "media segment"
 within a PlaylistInterface.
 
 Note that we currently also use this to model variant playlist "groups" in master playlists.
 This is convenient but not semantically correct.
 */
public struct MediaSegmentPlaylistTagGroup: PlaylistTagGroupProtocol, CustomDebugStringConvertible {
    
    public var range: PlaylistTagIndexRange
    
    public let mediaSequence: MediaSequence
    public let timeRange: CMTimeRange
    public let discontinuity: Bool
    
    public var debugDescription: String {
        return "MediaSegmentPlaylistTagGroup startIndex: \(startIndex) endIndex:\(endIndex) mediaSequence:\(mediaSequence) timeRange:\(timeRange) discontinuity:\(discontinuity)"
    }
}

/**
 An object to model the tags that are all "spanned" by one particualr tag.
 
 See `TagDescriptorScope.mediaSpanner` for more info, but briefly, some
 kinds of tags (such as `#EXT-X-KEY`) that can span multiple tags (and
 multiple MediaSegmentPlaylistTagGroup's)
 */
public struct PlaylistTagSpan: CustomDebugStringConvertible {
    
    public let parentTag: PlaylistTag
    public var tagMediaSpan: MediaGroupIndexRange
    
    public var startIndex: Int {
        return tagMediaSpan.lowerBound
    }
    public var endIndex: Int {
        return tagMediaSpan.upperBound
    }
    
    public var debugDescription: String {
        return "PlaylistTagSpan parentTag:\(parentTag) tagMediaSpan:\(tagMediaSpan)"
    }
}
