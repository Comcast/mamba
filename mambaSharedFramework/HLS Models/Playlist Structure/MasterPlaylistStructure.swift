//
//  MasterPlaylistStructure.swift
//  mamba
//
//  Created by David Coufal on 3/11/19.
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
 This object is responsible for maintaining a HLS master playlist structure, including
 an array of tags and an array of `variantTagGroups` that describe linked `EXT-X-STREAM-INF`
 and `URL` variant playlist locations.
 
 This class is thread safe.
 
 Sample structures:
 ```
 -                     #EXTM3U
 -                     #EXT-X-VERSION:4
 -                     #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio0",NAME="spa",DEFAULT=YES,AUTOSELECT=YES,LANGUAGE="spa",URI="audio_spa.m3u8"
 -                     #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio0",NAME="eng",DEFAULT=NO,AUTOSELECT=YES,LANGUAGE="eng",URI="audio_eng.m3u8"
 -                     #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subtitles0",NAME="eng_subtitle",DEFAULT=NO,AUTOSELECT=YES,LANGUAGE="eng",URI="subtitle_eng.m3u8"
 variantTagGroups[0]   #EXT-X-STREAM-INF:PROGRAM-ID=0,BANDWIDTH=1170400,CODECS="avc1",RESOLUTION=320x240,AUDIO="audio0",CLOSED-CAPTIONS=NONE,SUBTITLES="subtitles0"
 variantTagGroups[0]   1.m3u8
 variantTagGroups[1]   #EXT-X-STREAM-INF:PROGRAM-ID=0,BANDWIDTH=3630000,CODECS="avc1",RESOLUTION=854x480,AUDIO="audio0",CLOSED-CAPTIONS=NONE,SUBTITLES="subtitles0"
 variantTagGroups[1]   2.m3u8
 variantTagGroups[2]   #EXT-X-STREAM-INF:PROGRAM-ID=0,BANDWIDTH=6380000,CODECS="avc1",RESOLUTION=1920x1080,AUDIO="audio0",CLOSED-CAPTIONS=NONE,SUBTITLES="subtitles0"
 variantTagGroups[2]   3.m3u8
 ```
 */
public typealias MasterPlaylistStructure = PlaylistStructureCore<MasterPlaylistStructureData, MasterPlaylistStructureDelegate>

extension PlaylistStructureCore: MasterPlaylistTagGroupProvider where PSD == MasterPlaylistStructureDelegate {
    
    convenience public init(withTags tags: [HLSTag]) {
        self.init(withTags: tags,
                  withDelegate: MasterPlaylistStructureDelegate(),
                  withStructureData: MasterPlaylistStructureData())
    }
    
    public var variantTagGroups: [VariantTagGroup] { return structureData.variantTagGroups }
}

public struct VariantTagGroup: TagGroupProtocol, CustomDebugStringConvertible {
    
    public var range: HLSTagIndexRange
    
    public var debugDescription: String {
        return "VariantTagGroup startIndex: \(startIndex) endIndex:\(endIndex)"
    }
}

public protocol MasterPlaylistTagGroupProvider {
    /// An array of `VariantTagGroup`s found in the tag array. Updated on changes to the master playlist.
    var variantTagGroups: [VariantTagGroup] { get }
}

public struct MasterPlaylistStructureData: EmptyInitializerImplementor {
    public init() {
        self.variantTagGroups = [VariantTagGroup]()
    }
    public init(variantTagGroups: [VariantTagGroup]) {
        self.variantTagGroups = variantTagGroups
    }
    var variantTagGroups: [VariantTagGroup]
}

public final class MasterPlaylistStructureDelegate: PlaylistStructureDelegate, EmptyInitializerImplementor {

    public typealias T = MasterPlaylistStructureData
    
    public init() {}
    
    public func isTagStructural(_ tag: HLSTag) -> Bool {
        return tag.scope() == .mediaSpanner ||
            tag.tagDescriptor == PantosTag.Location ||
            tag.tagDescriptor == PantosTag.EXT_X_STREAM_INF ||
            tag.tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF
    }
    
    public func rebuild(usingTagArray tags: [HLSTag]) -> MasterPlaylistStructureData {
        do {
            // using the general purpose `PlaylistStructureConstructor` to calculate our variant groups, since the
            // calculation is just a simpler form of the Fragment Groups algorithm.
            let constructor = PlaylistStructureConstructor(withTagDescriptorForMediaGroupBoundaries: PantosTag.EXT_X_STREAM_INF)
            let result = try constructor.generateMediaGroups(fromTags: tags)
            
            let variantTagGroups = result.mediaSegmentGroups.map { mediaSegmentTagGroup in return VariantTagGroup(range: mediaSegmentTagGroup.range) }
            
            return MasterPlaylistStructureData(variantTagGroups: variantTagGroups)
        }
        catch {
            return MasterPlaylistStructureData()
        }
    }
    
    public func changed(numberOfTags alterCount: Int,
                        atIndex index: Int,
                        inTagArray tags: [HLSTag],
                        withInitialStructure structure: MasterPlaylistStructureData) -> PlaylistStructureChangeResult<MasterPlaylistStructureData> {
        
        // the master playlist structure is usually very small and is heavily interdependant on other tags. Just rebuild from scratch every time.
        let rebuiltStructureData = rebuild(usingTagArray: tags)
        return PlaylistStructureChangeResult<MasterPlaylistStructureData>(hadToRebuildFromScratch: true, structure: rebuiltStructureData)
    }
}
