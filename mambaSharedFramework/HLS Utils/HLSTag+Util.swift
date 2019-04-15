//
//  HLSTag+Util.swift
//  mamba
//
//  Created by Philip McMahon on 1/27/17.
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

public extension HLSTag {
    
    /// convenience function to return the resolution of this tag (if present)
    func resolution() -> HLSResolution? {
        return self.value(forValueIdentifier: PantosValue.resolution)
    }
    
    /// convenience function to return the bandwidth of this tag (if present)
    func bandwidth() -> Double? {
        return self.value(forValueIdentifier: PantosValue.bandwidthBPS)
    }
    
    /// convenience function to return the codecs of this tag (if present)
    func codecs() -> HLSCodecArray? {
        if let value: String = self.value(forValueIdentifier: PantosValue.codecs) {
            return HLSCodecArray(string: value)
        }
        
        return nil
    }
    
    /// convenience function to return the language of this tag (if present)
    func language() -> String? {
        return self.value(forValueIdentifier: PantosValue.language)
    }
    
    /// convenience function to determine if this tag contains only an audio stream (will return false if called on a non-#EXT-X-STREAM-INF tag)
    func isAudioOnlyStream() -> IndeterminateBool {
        guard tagDescriptor == PantosTag.EXT_X_STREAM_INF else {
            return .FALSE
        }
        if let codecs = self.codecs() {
            return IndeterminateBool(boolValue: codecs.containsAudioOnly())
        }
        if resolution() != nil {
            // if we have a video resolution, we must be video
            return .FALSE
        }

        return .INDETERMINATE
    }
    
    /// convenience function to determine if this tag contains a video stream (will return false if called on a non-#EXT-X-STREAM-INF tag)
    func isVideoStream() -> IndeterminateBool {
        guard tagDescriptor == PantosTag.EXT_X_STREAM_INF else {
            return .FALSE
        }
        if let codecs = self.codecs() {
            return IndeterminateBool(boolValue: codecs.containsVideo())
        }
        if resolution() != nil {
            // if we have a video resolution, we must be video
            return .TRUE
        }

        return .INDETERMINATE
    }
    
    /// convenience function to determine if this tag contains both an audio and a video stream (will return false if called on a non-#EXT-X-STREAM-INF tag)
    func isAudioVideoStream() -> IndeterminateBool {
        guard tagDescriptor == PantosTag.EXT_X_STREAM_INF else {
            return .FALSE
        }
        if let codecs = self.codecs() {
            return IndeterminateBool(boolValue: codecs.containsAudioVideo())
        }

        return .INDETERMINATE
    }

    /// convenience function to determine if this tag is a SAP audio stream (will return false if we are not an appropriate tag to query for this info)
    func isSapStream() -> Bool {
        return self.language() != nil
    }
}
