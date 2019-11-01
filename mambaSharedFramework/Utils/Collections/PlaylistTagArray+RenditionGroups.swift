//
//  PlaylistTagArray+RenditionGroups.swift
//  mamba
//
//  Created by Philip McMahon on 1/17/17.
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

/// the hls file type (i.e. master vs media/variant vs indeterminate)
public enum FileType {
    /// cannot determine (likely a invalid playlist)
    case unknown
    /// a master playlist
    case master
    /// a variant/media playlist
    case media
}

public extension Collection where Iterator.Element == PlaylistTag {
    
    /// returns the FileType of this tag collection (i.e. master vs. variant)
    func type() -> FileType {
        
        for tag in self {
            if tag.tagDescriptor == PantosTag.EXTINF {
                return .media
            }
            if tag.tagDescriptor == PantosTag.EXT_X_TARGETDURATION {
                return .media
            }
            if tag.tagDescriptor == PantosTag.EXT_X_STREAM_INF {
                return .master
            }
            if tag.tagDescriptor == PantosTag.EXT_X_MEDIA {
                return .master
            }
        }
        return .unknown
    }
    
    /// Convenience function to return all the values for a particular PlaylistTagValueIdentifier in a particular PlaylistTagDescriptor
    func extractValues(tagDescriptor: PlaylistTagDescriptor, valueIdentifier: PlaylistTagValueIdentifier) -> Set<String> {
        
        var values = Set<String>()
        let media = self.filter({ $0.tagDescriptor == tagDescriptor })

        media.forEach({ (tag) in
            
            if let value: String = tag.value(forValueIdentifier: valueIdentifier) {
                values.insert(value)
            }
        })
        
        return values
    }
    
    /// Convenience function to filter PlaylistTag collections by a particular PlaylistTagDescriptor
    func filtered(by tagDescriptor: PlaylistTagDescriptor) -> [PlaylistTag] {
        return self.filter({ $0.tagDescriptor == tagDescriptor })
    }

    /// returns a new PlaylistTag Array that's sorted by resolution and bandwidth (in that order)
    func sortedByResolutionBandwidth(tolerance: Double = 1.0) -> [PlaylistTag] {
        
        return self.sorted { (a, b) -> Bool in
        
            if let aResolution: ResolutionValueType = a.resolution(),
                let bResolution: ResolutionValueType = b.resolution() {
                if aResolution < bResolution { return true }
                if aResolution > bResolution { return false }
            }
            else if let _ = b.resolution() {
                return true
            }
            
            if let aBandwidth: Double = a.bandwidth(),
                let bBandwidth: Double = b.bandwidth() {
                if aBandwidth * tolerance < bBandwidth { return true }
            }
            
            return false
        }
    }
}
