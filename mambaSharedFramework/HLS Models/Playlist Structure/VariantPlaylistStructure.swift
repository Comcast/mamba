//
//  VariantPlaylistStructure.swift
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
 This object is responsible for maintaining a HLS playlist structure, including a array of tags and
 a set of objects that describes the structure. Thoses objects are a header, a number of
 mediaSegmentGroups and a footer, as well as a set of "spans" for tags that span over several
 media groups.
 
 This class is thread safe.
 
 Sample structures:
 
 -                                    #EXTM3U
 header                  #EXT-X-VERSION:4
 header                  #EXT-X-I-FRAMES-ONLY
 header                  #EXT-X-PLAYLIST-TYPE:VOD
 header                  #EXT-X-ALLOW-CACHE:NO
 header                  #EXT-X-TARGETDURATION:10
 header                  #EXT-X-MEDIA-SEQUENCE:1
 header                  #EXT-X-PROGRAM-DATE-TIME:2016-02-19T14:54:23.031+08:00
 header                  #EXT-X-INDEPENDENT-SEGMENTS
 header                  #EXT-X-START:TIME-OFFSET=0
 header                  #EXT-X-KEY:METHOD=NONE
 mediaSpan[0] mediaSegmentGroups[0]   #EXTINF:5220,1
 mediaSpan[0] mediaSegmentGroups[0]   http://media.example.com/segment1.ts
 mediaSpan[0] mediaSegmentGroups[1]   #EXTINF:5220,1
 mediaSpan[0] mediaSegmentGroups[1]   http://media.example.com/segment2.ts
 mediaSpan[1] mediaSegmentGroups[2]   #EXT-X-DISCONTINUITY
 mediaSpan[1] mediaSegmentGroups[2]   #EXT-X-KEY:METHOD=SAMPLE-AES,URI="https://priv.example.com/key.php?r=52",IV=0x9c7db8778570d05c3177c349fd9236aa,KEYFORMAT="com.apple.streamingkeydelivery",KEYFORMATVERSIONS="1"
 mediaSpan[1] mediaSegmentGroups[2]   #EXTINF:5220,2
 mediaSpan[1] mediaSegmentGroups[2]   #EXT-X-BYTERANGE:82112@752321
 mediaSpan[1] mediaSegmentGroups[2]   http://media.example.com/drmSegment1.ts
 footer                  #EXT-X-ENDLIST
 
 In the above structure there are two media spans. mediaSpan[0] would cover just mediaSegmentGroups[0] and [1] (range 0...1), and
 mediaSpans[1] would cover just mediaSegmentGroup[2] (range 2...2). Each media span has its own #EXT-X-KEY tag.
 
 */
public typealias VariantPlaylistStructure = PlaylistStructureCore<MediaPlaylistStructureData, VariantPlaylistStructureDelegate>

extension PlaylistStructureCore: TagSource, VariantPlaylistStructureInterface where PSD == VariantPlaylistStructureDelegate {
    
    convenience public init(withTags tags: [HLSTag]) {
        self.init(withTags: tags,
                  withDelegate: VariantPlaylistStructureDelegate(),
                  withStructureData: MediaPlaylistStructureData())
    }
    
    public var header: TagGroup? { return structureData.header }
    public var mediaSegmentGroups: [MediaSegmentTagGroup] { return structureData.mediaSegmentGroups }
    public var footer: TagGroup? { return structureData.footer }
    public var mediaSpans: [TagSpan] { return structureData.mediaSpans }
}

public protocol VariantPlaylistStructureInterface: TagSource {
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
     The `footer` is all `HLSTag`s at the end of the playlist that have the scope HLSTagDescriptorScope.wholePlaylist.
     */
    var footer: TagGroup? { get }
    
    /**
     The `mediaSpans` array keeps track of all the tags that describe many other tags.
     For example, the `#EXT-X-KEY` tag describes how many segments are encrypted.
     */
    var mediaSpans: [TagSpan] { get }
}

extension VariantPlaylistStructureInterface {
    
    /**
     Returns the start time of this playlist.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a start time.
     */
    public var startTime: CMTime {
        guard let timeRange = mediaSegmentGroups.first?.timeRange else { return CMTime.invalid }
        return timeRange.start
    }
    
    /**
     Returns the end time of this playlist.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a end time.
     */
    public var endTime: CMTime {
        guard let timeRange = mediaSegmentGroups.last?.timeRange else { return CMTime.invalid }
        return timeRange.end
    }
    
    /**
     Returns the duration of this playlist.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a duration
     */
    public var duration: CMTime {
        guard startTime.isNumeric && endTime.isNumeric else {
            return CMTime.invalid
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
            #if swift(>=4.1)
            let tagNames: Set<HLSStringRef> = Set(tags[group.range].compactMap { $0.tagName })
            #else
            let tagNames: Set<HLSStringRef> = Set(tags[group.range].flatMap { $0.tagName })
            #endif
            
            if queryTagNameSet.intersection(tagNames).count > 0 {
                results.append(group)
            }
        }
        return results
    }
    
    /**
     Grab a ArraySlice representing the given Tag Group.
     
     - parameter forMediaGroupIndex: The index of the media group used for the tag selection.
     
     - returns: An ArraySlice of the tags in the given media group.
     */
    public func tags(forMediaGroupIndex index: Int) -> ArraySlice<HLSTag> {
        guard let range = mediaSegmentGroups[safe: index]?.range else {
            return ArraySlice<HLSTag>()
        }
        return tags[range]
    }
    
}

public struct MediaPlaylistStructureData: EmptyInitializerImplementor {
    public init() {
        self.header = nil
        self.mediaSegmentGroups = [MediaSegmentTagGroup]()
        self.footer = nil
        self.mediaSpans = [TagSpan]()
    }
    /// Use this constructor if we are unable to figure out structure
    public init(tags: [HLSTag]) {
        self.header = TagGroup(range: tags.startIndex...(tags.endIndex - 1))
        self.mediaSegmentGroups = [MediaSegmentTagGroup]()
        self.footer = nil
        self.mediaSpans = [TagSpan]()
    }
    public init(header: TagGroup?, mediaSegmentGroups: [MediaSegmentTagGroup], footer: TagGroup?, mediaSpans: [TagSpan]) {
        self.header = header
        self.mediaSegmentGroups = mediaSegmentGroups
        self.footer = footer
        self.mediaSpans = mediaSpans
    }
    var header: TagGroup?
    var mediaSegmentGroups: [MediaSegmentTagGroup]
    var footer: TagGroup?
    var mediaSpans: [TagSpan]
}

public final class VariantPlaylistStructureDelegate: PlaylistStructureDelegate, EmptyInitializerImplementor {
    
    public typealias T = MediaPlaylistStructureData
    
    public init() {}
    
    public func isTagStructural(_ tag: HLSTag) -> Bool {
        return tag.scope() == .mediaSpanner ||
            tag.tagDescriptor == PantosTag.Location ||
            tag.tagDescriptor == PantosTag.EXT_X_MEDIA_SEQUENCE ||
            tag.tagDescriptor == PantosTag.EXTINF ||
            tag.tagDescriptor == PantosTag.EXT_X_DISCONTINUITY
    }
    
    public func rebuild(usingTagArray tags: [HLSTag]) -> MediaPlaylistStructureData {
        do {
            let constructor = PlaylistStructureConstructor(withTagDescriptorForMediaGroupBoundaries: PantosTag.EXTINF)
            let result = try constructor.generateMediaGroups(fromTags: tags)

            let mediaSpans = try PlaylistStructureConstructor.generateMediaSpans(fromTags: tags,
                                                                                 header: result.header,
                                                                                 mediaSegmentGroups: result.mediaSegmentGroups)
            
            return MediaPlaylistStructureData(header: result.header,
                                              mediaSegmentGroups: result.mediaSegmentGroups,
                                              footer: result.footer,
                                              mediaSpans: mediaSpans)
        }
        catch {
            return MediaPlaylistStructureData(tags: tags)
        }
    }
    
    public func changed(numberOfTags alterCount: Int,
                        atIndex index: Int,
                        inTagArray tags: [HLSTag],
                        withInitialStructure structure: MediaPlaylistStructureData) -> PlaylistStructureChangeResult<MediaPlaylistStructureData> {
        
        // Fix up groups
        
        var foundChangePoint = false
        
        var calc_header: TagGroup? = nil
        var calc_mediaSegmentGroups = structure.mediaSegmentGroups
        var calc_footer: TagGroup? = nil

        // is the insert in the header?
        if var header = structure.header {
            if header.range.contains(index) {
                if alterCount < 0 && !header.range.contains(index - alterCount) {
                    // deleted out of the header
                    let structure = rebuild(usingTagArray: tags)
                    return PlaylistStructureChangeResult<MediaPlaylistStructureData>(hadToRebuildFromScratch: true, structure: structure)
                }
                header.range = header.startIndex...(header.endIndex + alterCount)
                foundChangePoint = true
            }
            calc_header = header
        }
        
        // is the insert in one of the media groups?
        for (groupIndex, _) in structure.mediaSegmentGroups.enumerated() {
            if foundChangePoint {
                calc_mediaSegmentGroups[groupIndex].range = (calc_mediaSegmentGroups[groupIndex].startIndex + alterCount)...(calc_mediaSegmentGroups[groupIndex].endIndex + alterCount)
            }
            else if alterCount < 0
                && calc_mediaSegmentGroups[groupIndex].range.contains(index)
                && !calc_mediaSegmentGroups[groupIndex].range.contains(index - alterCount) {
                // deleted out of the group
                let structure = rebuild(usingTagArray: tags)
                return PlaylistStructureChangeResult<MediaPlaylistStructureData>(hadToRebuildFromScratch: true, structure: structure)
            }
            else if calc_mediaSegmentGroups[groupIndex].range.contains(index) {
                foundChangePoint = true
                calc_mediaSegmentGroups[groupIndex].range = calc_mediaSegmentGroups[groupIndex].startIndex...(calc_mediaSegmentGroups[groupIndex].endIndex + alterCount)
            }
        }
        
        // is the insert in the footer?
        if var footer = structure.footer {
            if foundChangePoint {
                footer.range = (footer.startIndex + alterCount)...(footer.endIndex + alterCount)
            }
            else if alterCount < 0
                && footer.range.contains(index)
                && !footer.range.contains(index - alterCount) {
                // deleted out of the footer
                let structure = rebuild(usingTagArray: tags)
                return PlaylistStructureChangeResult<MediaPlaylistStructureData>(hadToRebuildFromScratch: true, structure: structure)
            }
            else if footer.range.contains(index) {
                footer.range = footer.startIndex...(footer.endIndex + alterCount)
            }
            calc_footer = footer
        }
        
        let mediaSpans: [TagSpan]
        do {
            mediaSpans = try PlaylistStructureConstructor.generateMediaSpans(fromTags: tags,
                                                                             header: calc_header,
                                                                             mediaSegmentGroups: calc_mediaSegmentGroups)
        }
        catch {
            mediaSpans = [TagSpan]()
        }
        
        return PlaylistStructureChangeResult<MediaPlaylistStructureData>(hadToRebuildFromScratch: false,
                                                                         structure: MediaPlaylistStructureData(header: calc_header,
                                                                                                               mediaSegmentGroups: calc_mediaSegmentGroups,
                                                                                                               footer: calc_footer,
                                                                                                               mediaSpans: mediaSpans))
        
    }
}
