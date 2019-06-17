//
//  EXT_X_STARTTimeOffsetValidator.swift
//  mamba
//
//  Created by Mohan on 1/17/17.
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

// The EXT-X-START tag indicates a preferred point at which to start playing a Playlist. If the variant does not contain EXT-X-ENDLIST, the TIME-OFFSET should not be within 3 target durations from the end, else TIME-OFFSET absolute value should never be longer than the playlist
//#EXT-X-START:TIME-OFFSET=30,PRECISE=YES
class  EXT_X_STARTTimeOffsetValidator: VariantPlaylistValidator {

    static func validate(variantPlaylist: VariantPlaylistInterface) -> [PlaylistValidationIssue] {
        
        var startTag, targetDurationTag: PlaylistTag?
        var endListExist = false
        if let range = variantPlaylist.footer?.range {
            let footerTags = variantPlaylist.tags[range]
            endListExist = footerTags.contains(where: { (tag) -> Bool in return tag.tagDescriptor == PantosTag.EXT_X_ENDLIST })
        }
        if let header = variantPlaylist.header {
            let headerTags = variantPlaylist.tags[header.range]
            for tag in headerTags {
                if tag.tagDescriptor == PantosTag.EXT_X_START {
                    startTag = tag
                } else if tag.tagDescriptor == PantosTag.EXT_X_TARGETDURATION {
                    targetDurationTag = tag
                }
            }
        }
        guard let startTimeOffSet: CMTime = startTag?.value(forValueIdentifier: PantosValue.startTimeOffset),
            let targetDuration: CMTime = targetDurationTag?.value(forValueIdentifier: PantosValue.targetDurationSeconds)
            else { return [PlaylistValidationIssue]() }
        
        let latestAllowedStartTime = variantPlaylist.endTime - CMTimeMultiply(targetDuration, multiplier: 3)
        
        if (startTimeOffSet > variantPlaylist.endTime) || (!endListExist && startTimeOffSet > latestAllowedStartTime) {
            return [PlaylistValidationIssue(description: IssueDescription.EXT_X_STARTTimeOffsetValidator, severity: IssueSeverity.error)]
        }
        
        return [PlaylistValidationIssue]()
    }
}
