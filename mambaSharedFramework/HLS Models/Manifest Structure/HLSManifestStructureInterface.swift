//
//  HLSManifestStructureInterface.swift
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
 This protocol defines the interface of a object that represents HLS manifest structure.
 */
public protocol HLSManifestStructureInterface {
    
    /**
     This array is a list of every line in a HLS manifest. Each line is defined by a `HLSTag` object.
     */
    var tags: [HLSTag] { get }
    
    /**
     The `header` is all tags that describe the manifest initially. All `HLSTag`s at the top of the manifest that
     have the scope HLSTagDescriptorScope.wholeManifest or HLSTagDescriptorScope.mediaSpanner are part of this
     structure.
     */
    var header: TagGroup { get }
    
    /**
     All the `HLSTag`s in the middle of the manifest that generally have the scope HLSTagDescriptorScope.mediaFragment
     make up the `mediaFragmentGroups`. They are deliniated by "divider" tags, such as `#EXTINF`. Every divider tag
     begins a new media fragment group. Each media fragment group describes a fragment (in the case of a variant
     manifest) or another manifest (in the case of a master manifest).
     */
    var mediaFragmentGroups: [MediaFragmentTagGroup] { get }
    
    /**
     The `mediaSpans` array keeps track of all the tags that describe many other tags.
     For example, the `#EXT-X-KEY` tag describes how many fragments are encrypted.
     */
    var mediaSpans: [TagSpan] { get }
    
    /**
     The `footer` is all `HLSTag`s at the end of the manifest that have the scope HLSTagDescriptorScope.wholeManifest.
     */
    var footer: TagGroup? { get }
}

// MARK: Manifest Convenience Functions

extension HLSManifestStructureInterface {
    
    /**
     Returns the start time of this manifest.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a start time.
     */
    public var startTime: CMTime {
        guard let timeRange = mediaFragmentGroups.first?.timeRange else { return kCMTimeInvalid }
        return timeRange.start
    }
    
    /**
     Returns the end time of this manifest.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a end time.
     */
    public var endTime: CMTime {
        guard let timeRange = mediaFragmentGroups.last?.timeRange else { return kCMTimeInvalid }
        return timeRange.end
    }
    
    /**
     Returns the duration of this manifest.
     
     The CMTime will be kCMTimeInvalid if we cannot determine a duration
     */
    public var duration: CMTime {
        guard startTime.isNumeric && endTime.isNumeric else {
            return kCMTimeInvalid
        }
        return CMTimeSubtract(endTime, startTime)
    }
    
    /**
     Returns all `MediaFragmentTagGroup`s that contain tags with particular names.
     */
    public func mediaFragmentGroups<T:Sequence>(containingTagsNamed tagNames: T) -> [MediaFragmentTagGroup]
        where T.Iterator.Element == HLSStringRef
    {
        let queryTagNameSet = Set(tagNames)
        
        var results = [MediaFragmentTagGroup]()
        
        for group in mediaFragmentGroups {
            let tagNames: Set<HLSStringRef> = Set(tags[group.range].flatMap { $0.tagName })
            if queryTagNameSet.intersection(tagNames).count > 0 {
                results.append(group)
            }
        }
        return results
    }
}
