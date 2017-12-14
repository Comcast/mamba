//
//  HLSManifestStructure.swift
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
 This object is responsible for maintaining a HLS manifest structure, including a array of tags and 
 a set of objects that describes the structure. Thoses objects are a header, a number of 
 mediaFragmentGroups and a footer, as well as a set of "spans" for tags that span over several
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
 mediaSpan[0] mediaFragmentGroups[0]  #EXTINF:5220,1
 mediaSpan[0] mediaFragmentGroups[0]  http://media.example.com/fragment1.ts
 mediaSpan[0] mediaFragmentGroups[1]  #EXTINF:5220,1
 mediaSpan[0] mediaFragmentGroups[1]  http://media.example.com/fragment2.ts
 mediaSpan[1] mediaFragmentGroups[2]  #EXT-X-DISCONTINUITY
 mediaSpan[1] mediaFragmentGroups[2]  #EXT-X-KEY:METHOD=SAMPLE-AES,URI="https://priv.example.com/key.php?r=52",IV=0x9c7db8778570d05c3177c349fd9236aa,KEYFORMAT="com.apple.streamingkeydelivery",KEYFORMATVERSIONS="1"
 mediaSpan[1] mediaFragmentGroups[2]  #EXTINF:5220,2
 mediaSpan[1] mediaFragmentGroups[2]  #EXT-X-BYTERANGE:82112@752321
 mediaSpan[1] mediaFragmentGroups[2]  http://media.example.com/drmFragment1.ts
              footer                  #EXT-X-ENDLIST
 
 In the above structure there are two media spans. mediaSpan[0] would cover just mediaFragmentGroups[0] and [1] (range 0...1), and
 mediaSpans[1] would cover just mediaFragmentGroup[2] (range 2...2). Each media span has its own #EXT-X-KEY tag.

 */
final class HLSManifestStructure: HLSManifestStructureInterface {
        
    init(withTags tags: [HLSTag]) {
        self._header = TagGroup(range: 0...0)
        self._mediaFragmentGroups = [MediaFragmentTagGroup]()
        self._footer = nil
        self._mediaSpans = [TagSpan]()
        self._tags = tags
    }
    
    init(withStructure structure: HLSManifestStructure) {
        self._header = structure._header
        self._mediaFragmentGroups = structure._mediaFragmentGroups
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
    
    var header: TagGroup {
        return queue.sync {
            rebuildIfRequired()
            return _header
        }
    }
    
    var mediaFragmentGroups: [MediaFragmentTagGroup] {
        return queue.sync {
            rebuildIfRequired()
            return _mediaFragmentGroups
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
     
     - parameter tag: A `HLSTag` to be inserted into the manifest.
     
     - parameter atIndex: Position to insert the tag into the manifest.
     */
    func insert(tag: HLSTag, atIndex index: Int) {
        queue.sync {
            _tags.insert(tag, at: index)
            added(tags: [tag], atIndex: index)
        }
    }
    
    /**
     Insert multiple tags.
     
     - parameter tags: A `HLSTag` array to be inserted into the manifest.
     
     - parameter atIndex: Position to insert the tags into the manifest.
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
     Method to rebuild the manifest structure.
     
     This method steps through every tag in the tag array, so it is a little expensive for long manifests.
     */
    private func rebuild() {
        do {
            let result = try HLSManifestStructureConstructor.generateMediaGroups(fromTags: _tags)
            
            let mediaSpans = try HLSManifestStructureConstructor.generateMediaSpans(fromTags: _tags,
                                                                                    header: result.header,
                                                                                    mediaFragmentGroups: result.mediaFragmentGroups)
            
            self._header = result.header
            self._mediaFragmentGroups = result.mediaFragmentGroups
            self._footer = result.footer
            self._mediaSpans = mediaSpans
        }
        catch {
            self._header = TagGroup(range: _tags.startIndex...(_tags.endIndex - 1))
            self._mediaFragmentGroups = [MediaFragmentTagGroup]()
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
        if _header.range.contains(index) {
            if alterCount < 0 && !_header.range.contains(index - alterCount) {
                // deleted out of the header
                rebuild()
                return false
            }
            _header.range = _header.startIndex...(_header.endIndex + alterCount)
            foundChangePoint = true
        }
        
        // is the insert in one of the media groups?
        for (groupIndex, _) in _mediaFragmentGroups.enumerated() {
            if foundChangePoint {
                _mediaFragmentGroups[groupIndex].range = (_mediaFragmentGroups[groupIndex].startIndex + alterCount)...(_mediaFragmentGroups[groupIndex].endIndex + alterCount)
            }
            else if alterCount < 0
                && _mediaFragmentGroups[groupIndex].range.contains(index)
                && !_mediaFragmentGroups[groupIndex].range.contains(index - alterCount) {
                // deleted out of the group
                rebuild()
                return false
            }
            else if _mediaFragmentGroups[groupIndex].range.contains(index) {
                foundChangePoint = true
                _mediaFragmentGroups[groupIndex].range = _mediaFragmentGroups[groupIndex].startIndex...(_mediaFragmentGroups[groupIndex].endIndex + alterCount)
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
    private var _header: TagGroup
    private var _mediaFragmentGroups: [MediaFragmentTagGroup]
    private var _footer: TagGroup?
    private var _mediaSpans: [TagSpan]
    
    private let queue = DispatchQueue(label: "com.comcast.mamba.hlsmanifeststructure",
                                      qos: .userInitiated)
}

extension HLSManifestStructure: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "HLSManifestStructure header: \(header) \nmediaFragmentGroups:\(mediaFragmentGroups) \nfooter:\(String(describing: footer)) \nmediaSpans:\(mediaSpans) \ntags:\(tags)\n"
    }
}


fileprivate struct HLSManifestStructureConstructor {
    
    fileprivate static func tagDescriptor(forTags tags: [HLSTag]) -> PantosTag {
        return tags.type() == .master ? PantosTag.EXT_X_STREAM_INF :  PantosTag.EXTINF
    }
    
    fileprivate static func generateMediaGroups(fromTags tags: [HLSTag]) throws -> (header: TagGroup, mediaFragmentGroups: [MediaFragmentTagGroup], footer: TagGroup?) {
        
        var mediaFragmentGroups = [MediaFragmentTagGroup]()
        
        var currentMediaSequence: MediaSequence = defaultMediaSequence
        var lastRecordedTime: CMTime = kCMTimeInvalid
        var currentFragmentDuration: CMTime = kCMTimeInvalid
        var discontinuity = false
        let tagDescriptor = self.tagDescriptor(forTags: tags)
        
        // figure out our media sequence start (defaults to 1 if not specified)
        let mediaSequenceTags = tags.filter{ $0.tagDescriptor == PantosTag.EXT_X_MEDIA_SEQUENCE }
        if mediaSequenceTags.count > 0 {
            assert(mediaSequenceTags.count == 1, "Unexpected to have more than one media sequence")
            if let startMediaSequence: MediaSequence = mediaSequenceTags.first?.value(forValueIdentifier: PantosValue.sequence) {
                currentMediaSequence = startMediaSequence
            }
        }
        
        // find the "header" portion by finding the first ".mediaFragment" scoped tag
        let mediaStartIndexOptional = tags.index(where: { $0.scope() == .mediaFragment })
        
        guard let mediaStartIndex = mediaStartIndexOptional else {
            // if we don't have any media fragment tags, it's all header
            return (header: TagGroup(range: 0...(tags.endIndex - 1)),
                    mediaFragmentGroups: mediaFragmentGroups,
                    footer: nil)
        }
        
        var headerEndIndex: Int
        if mediaStartIndex > 0 {
            headerEndIndex = tags.index(mediaStartIndex, offsetBy: -1) // move back one to get to the end of header tags
        }
        else {
            headerEndIndex = 0
        }
        
        // find the "footer" portion by finding the last ".mediaFragment" scoped tag
        let mediaGroupsEndIndexOptional = tags.findIndexBeforeIndex(index: tags.endIndex, predicate: { $0.scope() == .mediaFragment })
        
        var footerTags: [HLSTag]
        var lastIndex = tags.endIndex
        var mediaGroupsEndIndex: Int
        if let mediaGroupsEndIndexNonOptional = mediaGroupsEndIndexOptional {
            mediaGroupsEndIndex = mediaGroupsEndIndexNonOptional
            lastIndex = tags.index(mediaGroupsEndIndex, offsetBy: 1) // we move forward one, because mediaGroupsEndIndex is the last media fragment tag (likely a Location), and we want the tag _after_ that
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
                currentFragmentDuration = tag.duration
            }
            
            if tag.tagDescriptor == PantosTag.EXT_X_DISCONTINUITY {
                discontinuity = true
            }
            
            if tag.tagDescriptor == PantosTag.Location {
                
                // this marks the end of our current media fragment group
                // if we're doing fragments we care about durations
                if tagDescriptor == PantosTag.EXTINF {
                    lastRecordedTime = lastRecordedTime.isValid ? lastRecordedTime : CMTime(seconds: 0, preferredTimescale: CMTimeScale.defaultMambaTimeScale)
                    if !(currentFragmentDuration.isNumeric && currentFragmentDuration.seconds > 0.0) {
                        throw ParseError.foundMediaFragmentWithoutDuration(inMediaSequence: currentMediaSequence)
                    }
                }
                
                let timeRange = CMTimeRange(start: lastRecordedTime, duration: currentFragmentDuration)
                
                mediaFragmentGroups.append(MediaFragmentTagGroup(range: mediaGroupBeginIndex...tagIndex,
                                                                 mediaSequence: currentMediaSequence,
                                                                 timeRange: timeRange,
                                                                 discontinuity: discontinuity))
                
                // move forward for next media group
                currentMediaSequence += 1
                lastRecordedTime += currentFragmentDuration
                mediaGroupBeginIndex = tagIndex + 1
                
                // reset for next media group
                currentFragmentDuration = kCMTimeInvalid
                discontinuity = false
            }
        }
        
        return (header: TagGroup(range: 0...headerEndIndex),
                mediaFragmentGroups: mediaFragmentGroups,
                footer: footerTags.count > 0 ? TagGroup(range: footerStartIndex...footerEndIndex) : nil)
    }
    
    fileprivate static func generateMediaSpans(fromTags tags:[HLSTag],
                                               header: TagGroup,
                                               mediaFragmentGroups: [MediaFragmentTagGroup]) throws -> [TagSpan] {
        
        var mediaSpans = [TagSpan]()
        
        // handle our only known spannable tag, `EXT-X-KEY`
        let keyTags = tags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
        var keyCount = 0
        var startKeyIndex: Int? = nil
        var currentIndex: Int = 0
        var startKeyTag: HLSTag? = nil
        
        // handle any X-KEY tags in the header
        let headerTags = tags[header.range]
        let headerKeyTags = headerTags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
        if let firstXKeyTag = headerKeyTags.last {
            // we only have to handle the last X-KEY in the header, as previous X-KEY's will be superceded by this one
            keyCount += headerKeyTags.count
            startKeyIndex = 0 // if we find one in the header, we are always starting at the first index
            startKeyTag = firstXKeyTag
        }
        
        // handle X-KEY tags found interior to the manifest
        for mediaFragmentGroup in mediaFragmentGroups {
            
            let fragmentTags = tags[mediaFragmentGroup.range]
            let localKeyTags = fragmentTags.filter{ $0.tagDescriptor == PantosTag.EXT_X_KEY }
            
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
        case foundMediaFragmentWithoutDuration(inMediaSequence: MediaSequence)
    }
}

/**
 Function to determine if a given tag will affect the `HLSManifestStructure` object.
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
