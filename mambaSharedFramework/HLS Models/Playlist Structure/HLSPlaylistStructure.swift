//
//  HLSPlaylistStructure.swift
//  mamba
//
//  Created by David Coufal on 4/5/17.
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
 This object is responsible for maintaining a HLS playlist structure, including a array of tags and 
 a set of objects that describes the structure. Thoses objects are a header, a number of 
 mediaSegmentGroups and a footer, as well as a set of "spans" for tags that span over several
 media groups.
 
 This class is thread safe.
 
 Sample structures:
 
 -                       #EXTM3U
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
final class HLSPlaylistStructure: HLSPlaylistStructureInterface {
        
    init(withTags tags: [HLSTag]) {
        self._header = nil
        self._mediaSegmentGroups = [MediaSegmentTagGroup]()
        self._footer = nil
        self._mediaSpans = [TagSpan]()
        self._tags = tags
    }
    
    init(withStructure structure: HLSPlaylistStructure) {
        self._header = structure._header
        self._mediaSegmentGroups = structure._mediaSegmentGroups
        self._footer = structure._footer
        self._mediaSpans = structure._mediaSpans
        self._tags = structure._tags
        self.structureState = structure.structureState
    }
    
    var tags: [HLSTag] {
        return queue.sync {
            return _tags
        }
    }
    
    var header: TagGroup? {
        return queue.sync {
            rebuildIfRequired()
            return _header
        }
    }
    
    var mediaSegmentGroups: [MediaSegmentTagGroup] {
        return queue.sync {
            rebuildIfRequired()
            return _mediaSegmentGroups
        }
    }
    
    var footer: TagGroup? {
        return queue.sync {
            rebuildIfRequired()
            return _footer
        }
    }
    
    var mediaSpans: [TagSpan] {
        return queue.sync {
            rebuildIfRequired()
            return _mediaSpans
        }
    }
    
    /**
     Insert a single tag.
     
     - parameter tag: A `HLSTag` to be inserted into the playlist.
     
     - parameter atIndex: Position to insert the tag into the playlist.
     */
    func insert(tag: HLSTag, atIndex index: Int) {
        queue.sync {
            _tags.insert(tag, at: index)
            added(tags: [tag], atIndex: index)
        }
    }
    
    /**
     Insert multiple tags.
     
     - parameter tags: A `HLSTag` array to be inserted into the playlist.
     
     - parameter atIndex: Position to insert the tags into the playlist.
     */
    func insert(tags: [HLSTag], atIndex index: Int) {
        queue.sync {
            self._tags.insert(contentsOf: tags, at: index)
            added(tags: tags, atIndex: index)
        }
    }
    
    /**
     Delete a single tag.
     
     - parameter atIndex: Position of the tag to delete.
     */
    func delete(atIndex index: Int) {
        queue.sync {
            deleted(numberOfTags: 1, atIndex: index)
            _tags.remove(at: index)
        }
    }
    
    /**
     Delete multiple tags.
     
     - parameter atRange: Range of the tags to delete. If the range extends over more than
     one media group, we will automatically rebuild structure.
     */
    func delete(atRange range: HLSTagIndexRange) {
        queue.sync {
            deleted(numberOfTags: range.count, atIndex: range.lowerBound)
            _tags.removeSubrange(range)
        }
    }
    
    /**
     Perform a map on every tag in the tags array.
     
     - parameter: The mapping closure to use during the map.
     */
    func transform(_ mapping: (HLSTag) throws -> (HLSTag)) throws {
        try queue.sync {
            _tags = try _tags.map(mapping)
            structureState = .dirtyRequiresRebuild
        }
    }
    
    /**
     This function will rebuild structure elements based on the types of edits that have been
     done to the tags array since the last array.
     */
    private func rebuildIfRequired() {
        switch structureState {
        case .clean:
            return
        case .dirtyWithTagChanges(let tagChanges):
            for tagChange in tagChanges {
                changed(numberOfTags: tagChange.tagChangeCount,
                        atIndex: tagChange.index)
            }
        case .dirtyRequiresRebuild:
            rebuild()
        }
        structureState = .clean
    }

    private func added(tags: [HLSTag], atIndex index: Int) {
        
        if structureState == .dirtyRequiresRebuild {
            return
        }
        for tag in tags {
            if isTagStructural(tag) {
                structureState = .dirtyRequiresRebuild
                return
            }
        }
        if case let StructureState.dirtyWithTagChanges(tagChanges) = structureState {
            var newTagChanges = tagChanges
            newTagChanges.append(TagChangeRecord(tagChangeCount: tags.count, index: index))
            structureState = .dirtyWithTagChanges(newTagChanges)
        }
        else {
            structureState = .dirtyWithTagChanges([TagChangeRecord(tagChangeCount: tags.count, index: index)])
        }
    }
    
    private func deleted(numberOfTags: Int, atIndex index: Int) {
        
        if structureState == .dirtyRequiresRebuild {
            return
        }
        for tagIndex in index...(index + numberOfTags - 1) {
            if isTagStructural(_tags[tagIndex]) {
                structureState = .dirtyRequiresRebuild
                return
            }
        }
        if case let StructureState.dirtyWithTagChanges(tagChanges) = structureState {
            var newTagChanges = tagChanges
            newTagChanges.append(TagChangeRecord(tagChangeCount: -numberOfTags, index: index))
            structureState = .dirtyWithTagChanges(newTagChanges)
        }
        else {
            structureState = .dirtyWithTagChanges([TagChangeRecord(tagChangeCount: -numberOfTags, index: index)])
        }
    }
    
    /**
     Method to rebuild the playlist structure.
     
     This method steps through every tag in the tag array, so it is a little expensive for long playlists.
     */
    private func rebuild() {
        do {
            let result = try HLSPlaylistStructureConstructor.generateMediaGroups(fromTags: _tags)
            
            let mediaSpans = try HLSPlaylistStructureConstructor.generateMediaSpans(fromTags: _tags,
                                                                                    header: result.header,
                                                                                    mediaSegmentGroups: result.mediaSegmentGroups)
            
            self._header = result.header
            self._mediaSegmentGroups = result.mediaSegmentGroups
            self._footer = result.footer
            self._mediaSpans = mediaSpans
        }
        catch {
            self._header = TagGroup(range: _tags.startIndex...(_tags.endIndex - 1))
            self._mediaSegmentGroups = [MediaSegmentTagGroup]()
            self._footer = nil
            self._mediaSpans = [TagSpan]()
        }
    }
    
    /**
     Method to "fix up" the media groups and media spans after a insert or delete of tags that is not expected to wildly change the structure.
     
     We assume that the original caller knows what they were doing, so we do not check for any special tag values and descriptors.
     
     We do check for certain deletion conditions that might mean we cannot do a simple "fix up" i.e. if we try to delete over a tag
     group boundary or a tag span boundary. If that condition is found, we do a full rebuild.
     
     This method is much less expensive than calling `rebuild`.
     
     - parameter numberOfTags: The number of tags added or deleted.
     
     - parameter atIndex: The position at which the addition or deletion was made.
     
     - returns: True if we were able to fix up ourselves, False if we has to rebuild structure from scratch
     */
    @discardableResult
    private func changed(numberOfTags alterCount: Int, atIndex index: Int) -> Bool {
        
        // Fix up groups
        
        var foundChangePoint = false
        
        // is the insert in the header?
        if var header = _header {
            if header.range.contains(index) {
                if alterCount < 0 && !header.range.contains(index - alterCount) {
                    // deleted out of the header
                    rebuild()
                    return false
                }
                header.range = header.startIndex...(header.endIndex + alterCount)
                foundChangePoint = true
            }
            self._header = header
        }
        
        // is the insert in one of the media groups?
        for (groupIndex, _) in _mediaSegmentGroups.enumerated() {
            if foundChangePoint {
                _mediaSegmentGroups[groupIndex].range = (_mediaSegmentGroups[groupIndex].startIndex + alterCount)...(_mediaSegmentGroups[groupIndex].endIndex + alterCount)
            }
            else if alterCount < 0
                && _mediaSegmentGroups[groupIndex].range.contains(index)
                && !_mediaSegmentGroups[groupIndex].range.contains(index - alterCount) {
                // deleted out of the group
                rebuild()
                return false
            }
            else if _mediaSegmentGroups[groupIndex].range.contains(index) {
                foundChangePoint = true
                _mediaSegmentGroups[groupIndex].range = _mediaSegmentGroups[groupIndex].startIndex...(_mediaSegmentGroups[groupIndex].endIndex + alterCount)
            }
        }
        
        // is the insert in the footer?
        if var footer = _footer {
            if foundChangePoint {
                footer.range = (footer.startIndex + alterCount)...(footer.endIndex + alterCount)
            }
            else if alterCount < 0
                && footer.range.contains(index)
                && !footer.range.contains(index - alterCount) {
                // deleted out of the footer
                rebuild()
                return false
            }
            else if footer.range.contains(index) {
                footer.range = footer.startIndex...(footer.endIndex + alterCount)
            }
            self._footer = footer
        }
        
        return true
    }
    
    private var structureState: StructureState = .dirtyRequiresRebuild

    private var _tags: [HLSTag]
    private var _header: TagGroup?
    private var _mediaSegmentGroups: [MediaSegmentTagGroup]
    private var _footer: TagGroup?
    private var _mediaSpans: [TagSpan]
    
    private let queue = DispatchQueue(label: "com.comcast.mamba.hlsplayliststructure",
                                      qos: .userInitiated)
}

extension HLSPlaylistStructure: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "HLSPlaylistStructure header: \(String(describing: header)) \nmediaSegmentGroups:\(mediaSegmentGroups) \nfooter:\(String(describing: footer)) \nmediaSpans:\(mediaSpans) \ntags:\(tags)\n"
    }
}


fileprivate struct HLSPlaylistStructureConstructor {
    
    fileprivate static func tagDescriptor(forTags tags: [HLSTag]) -> PantosTag {
        return tags.type() == .master ? PantosTag.EXT_X_STREAM_INF :  PantosTag.EXTINF
    }
    
    fileprivate static func generateMediaGroups(fromTags tags: [HLSTag]) throws -> (header: TagGroup?, mediaSegmentGroups: [MediaSegmentTagGroup], footer: TagGroup?) {
        
        var mediaSegmentGroups = [MediaSegmentTagGroup]()
        
        var currentMediaSequence: MediaSequence = defaultMediaSequence
        var lastRecordedTime: CMTime = CMTime.invalid
        var currentSegmentDuration: CMTime = CMTime.invalid
        var discontinuity = false
        let tagDescriptor = self.tagDescriptor(forTags: tags)

        // collect media sequence and skip tag (if they exist) as they impact the initial media sequence value
        var mediaSequenceTag: HLSTag?
        var skipTag: HLSTag?
        for tag in tags {
            switch tag.tagDescriptor {
            case PantosTag.EXT_X_MEDIA_SEQUENCE: mediaSequenceTag = tag
            case PantosTag.EXT_X_SKIP: skipTag = tag
            case PantosTag.Location:
                // Both the EXT-X-MEDIA-SEQUNCE and the EXT-X-SKIP tag are expected to occur before any Media Segments.
                //
                // For EXT-X-MEDIA-SEQUNCE section 4.4.3.2 indicates:
                //     The EXT-X-MEDIA-SEQUENCE tag MUST appear before the first Media Segment in the Playlist.
                //
                // For EXT-X-SKIP section 4.4.5.2 indicates:
                //     A server produces a Playlist Delta Update (Section 6.2.5.1), by replacing tags earlier than the
                //     Skip Boundary with an EXT-X-SKIP tag. When replacing Media Segments, the EXT-X-SKIP tag replaces
                //     the segment URI lines and all Media Segment Tags tags that are applied to those segments.
                //
                // Exiting early at the first Location helps us avoid having to loop through the entire playlist when we
                // know that the tags we're looking for MUST NOT exist.
                break
            default: continue
            }
        }

        // figure out our media sequence start (defaults to 0 if not specified)
        if let startMediaSequence: MediaSequence = mediaSequenceTag?.value(forValueIdentifier: PantosValue.sequence) {
            currentMediaSequence = startMediaSequence
        }

        // account for any skip tag (since a delta update replaces all segments earlier than the skip boundary, the
        // SKIPPED-SEGMENTS value will effectively update the current media sequence value of the first segment, so safe
        // to do this here and not within the looping through media group tags below).
        if let skippedSegments: Int = skipTag?.value(forValueIdentifier: PantosValue.skippedSegments) {
            currentMediaSequence += skippedSegments
        }

        // find the "header" portion by finding the first ".mediaSegment" scoped tag
        let mediaStartIndexOptional = tags.firstIndex(where: { $0.scope() == .mediaSegment })
        
        guard let mediaStartIndex = mediaStartIndexOptional else {
            if tags.count == 0 {
                // if we have no tags, we have no content at all
                return (header: nil,
                        mediaSegmentGroups: mediaSegmentGroups,
                        footer: nil)
            }
            // if we don't have any media segment tags, it's all header
            return (header: TagGroup(range: 0...(tags.endIndex - 1)),
                    mediaSegmentGroups: mediaSegmentGroups,
                    footer: nil)
        }
        
        var headerEndIndex: Int
        if mediaStartIndex > 0 {
            headerEndIndex = tags.index(mediaStartIndex, offsetBy: -1) // move back one to get to the end of header tags
        }
        else {
            headerEndIndex = 0
        }
        
        // find the "footer" portion by finding the last ".mediaSegment" scoped tag
        let mediaGroupsEndIndexOptional = tags.findIndexBeforeIndex(index: tags.endIndex, predicate: { $0.scope() == .mediaSegment })
        
        var footerTags: [HLSTag]
        var lastIndex = tags.endIndex
        var mediaGroupsEndIndex: Int
        if let mediaGroupsEndIndexNonOptional = mediaGroupsEndIndexOptional {
            mediaGroupsEndIndex = mediaGroupsEndIndexNonOptional
            lastIndex = tags.index(mediaGroupsEndIndex, offsetBy: 1) // we move forward one, because mediaGroupsEndIndex is the last media segment tag (likely a Location), and we want the tag _after_ that
            footerTags = Array(tags[lastIndex..<tags.endIndex])
        }
        else {
            mediaGroupsEndIndex = tags.index(tags.endIndex, offsetBy: -1)
            // we don't have any footer tags
            footerTags = [HLSTag]()
        }
        let footerStartIndex = tags.endIndex - footerTags.count
        let footerEndIndex = footerStartIndex + footerTags.count - 1
        
        // find the media groups by stepping through each tag
        // we have to scan for media group metadata at the same time, so this is likely the most efficient way of doing this
        
        var mediaGroupBeginIndex = mediaStartIndex
        
        for tagIndex in mediaStartIndex...mediaGroupsEndIndex {
            
            let tag = tags[tagIndex]
            
            if tag.tagDescriptor == tagDescriptor {
                currentSegmentDuration = tag.duration
            }
            
            if tag.tagDescriptor == PantosTag.EXT_X_DISCONTINUITY {
                discontinuity = true
            }
            
            if tag.tagDescriptor == PantosTag.Location {
                
                // this marks the end of our current media segment group
                // if we're doing segments we care about durations
                if tagDescriptor == PantosTag.EXTINF {
                    lastRecordedTime = lastRecordedTime.isValid ? lastRecordedTime : CMTime(seconds: 0, preferredTimescale: CMTimeScale.defaultMambaTimeScale)
                    if !(currentSegmentDuration.isNumeric && currentSegmentDuration.seconds > 0.0) {
                        throw ParseError.foundMediaSegmentWithoutDuration(inMediaSequence: currentMediaSequence)
                    }
                }
                
                let timeRange = CMTimeRange(start: lastRecordedTime, duration: currentSegmentDuration)
                
                mediaSegmentGroups.append(MediaSegmentTagGroup(range: mediaGroupBeginIndex...tagIndex,
                                                               mediaSequence: currentMediaSequence,
                                                               timeRange: timeRange,
                                                               discontinuity: discontinuity))
                
                // move forward for next media group
                currentMediaSequence += 1
                lastRecordedTime += currentSegmentDuration
                mediaGroupBeginIndex = tagIndex + 1
                
                // reset for next media group
                currentSegmentDuration = CMTime.invalid
                discontinuity = false
            }
        }
        
        return (header: TagGroup(range: 0...headerEndIndex),
                mediaSegmentGroups: mediaSegmentGroups,
                footer: footerTags.count > 0 ? TagGroup(range: footerStartIndex...footerEndIndex) : nil)
    }
    
    fileprivate static func generateMediaSpans(fromTags tags:[HLSTag],
                                               header: TagGroup?,
                                               mediaSegmentGroups: [MediaSegmentTagGroup]) throws -> [TagSpan] {
        
        var mediaSpans = [TagSpan]()
        
        // handle our only known spannable tag, `EXT-X-KEY`
        let keyTags = tags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
        var keyCount = 0
        var startKeyIndex: Int? = nil
        var currentIndex: Int = 0
        var startKeyTag: HLSTag? = nil
        
        // handle any X-KEY tags in the header
        if let header = header {
            let headerTags = tags[header.range]
            let headerKeyTags = headerTags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
            if let firstXKeyTag = headerKeyTags.last {
                // we only have to handle the last X-KEY in the header, as previous X-KEY's will be superceded by this one
                keyCount += headerKeyTags.count
                startKeyIndex = 0 // if we find one in the header, we are always starting at the first index
                startKeyTag = firstXKeyTag
            }
        }
        
        // handle X-KEY tags found interior to the playlist
        for mediaSegmentGroup in mediaSegmentGroups {
            
            let segmentTags = tags[mediaSegmentGroup.range]
            let localKeyTags = segmentTags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
            
            if localKeyTags.count > 0 {
                keyCount += localKeyTags.count
                
                // if we have a tag in the first mediaGroup, we just forget all about our header tags and this overrides it
                if (currentIndex == 0) {
                    startKeyIndex = nil
                    startKeyTag = nil
                }
                
                if let startKeyIndex = startKeyIndex, let startKeyTag = startKeyTag {
                    // we are closing out our last key
                    mediaSpans.append(TagSpan(parentTag: startKeyTag, tagMediaSpan: startKeyIndex...currentIndex - 1))
                }
                
                startKeyIndex = currentIndex
                // we only look for the last tag, as previous X-KEY tags are superceded by this one
                startKeyTag = localKeyTags.last! // forced unwrap is safe, we checked above for count > 0
            }
            
            currentIndex += 1
        }
        
        // close out our last tag
        if let startKeyIndex = startKeyIndex, let startKeyTag = startKeyTag {
            mediaSpans.append(TagSpan(parentTag: startKeyTag, tagMediaSpan: startKeyIndex...(currentIndex - 1)))
        }
        
        assert(keyCount == keyTags.count, "we missed a key tag")
        
        return mediaSpans
    }
    
    private enum ParseError: Error {
        case foundMediaSegmentWithoutDuration(inMediaSequence: MediaSequence)
    }
}

/**
 Function to determine if a given tag will affect the `HLSPlaylistStructure` object.
 */
func isTagStructural(_ tag: HLSTag) -> Bool {
    return tag.scope() == .mediaSpanner ||
        tag.tagDescriptor == PantosTag.Location ||
        tag.tagDescriptor == PantosTag.EXT_X_MEDIA_SEQUENCE ||
        tag.tagDescriptor == PantosTag.EXTINF ||
        tag.tagDescriptor == PantosTag.EXT_X_DISCONTINUITY ||
        tag.tagDescriptor == PantosTag.EXT_X_STREAM_INF ||
        tag.tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF
}
