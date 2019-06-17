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
            if tag.tagDescriptor == PantosTag.EXT_X_STREAM_INF {
                return .master
            }
        }
        return .unknown
    }
    
    /// returns true if we can detect a SAP stream (only works for master playlists)
    func hasSap() -> Bool {
        
        let languages = Set(self.extractValues(tagDescriptor: PantosTag.EXT_X_MEDIA, valueIdentifier: PantosValue.language))
        return languages.count > 1
    }
    
    /// returns the #EXT-X-MEDIA tags for SAP audio streams if present (only works for master playlists)
    public func sapStreams() -> [PlaylistTag]? {
        
        return self.filter({ $0.tagDescriptor == PantosTag.EXT_X_MEDIA }).filter({
            return $0.value(forValueIdentifier: PantosValue.language) != nil
        })
    }
    
    /// Convenience function to return all the values for a particular PlaylistTagValueIdentifier in a particular PlaylistTagDescriptor
    public func extractValues(tagDescriptor: PlaylistTagDescriptor, valueIdentifier: PlaylistTagValueIdentifier) -> Set<String> {
        
        var values = Set<String>()
        let media = self.filter({ $0.tagDescriptor == tagDescriptor })

        media.forEach({ (tag) in
            
            if let value: String = tag.value(forValueIdentifier: valueIdentifier) {
                values.insert(value)
            }
        })
        
        return values
    }
    
    /// returns true if we are a master playlist and have a audio only stream
    func hasAudioOnlyStream() -> Bool {
        
        guard let _ = firstAudioOnlyStreamInfTag() else { return false }
        return true
    }
    
    /// returns the first audio only #EXT-X-STREAMINF tag found in this PlaylistTag collection
    public func firstAudioOnlyStreamInfTag() -> PlaylistTag? {
        return first(where: { $0.tagDescriptor == PantosTag.EXT_X_STREAM_INF && $0.isAudioOnlyStream() == .TRUE })
    }
    
    /// Convenience function to filter PlaylistTag collections by a particular PlaylistTagDescriptor
    public func filtered(by tagDescriptor: PlaylistTagDescriptor) -> [PlaylistTag] {
        return self.filter({ $0.tagDescriptor == tagDescriptor })
    }

    /// Convenience function to return just the video streams in a PlaylistTag collection
    public func filteredByVideoCodec() -> [PlaylistTag] {
        
        return self.filter { return $0.isVideoStream() == .TRUE }
    }
    
    /// returns a new PlaylistTag Array that's sorted by resolution and bandwidth (in that order)
    public func sortedByResolutionBandwidth(tolerance: Double = 1.0) -> [PlaylistTag] {
        
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
