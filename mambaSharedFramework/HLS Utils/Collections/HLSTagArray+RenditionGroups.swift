//
//  HLSTagArray+RenditionGroups.swift
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

public extension Collection where Iterator.Element == HLSTag {
    
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
    
    /// Convenience function to return all the values for a particular HLSTagValueIdentifier in a particular HLSTagDescriptor
    func extractValues(tagDescriptor: HLSTagDescriptor, valueIdentifier: HLSTagValueIdentifier) -> Set<String> {
        
        var values = Set<String>()
        let media = self.filter({ $0.tagDescriptor == tagDescriptor })

        media.forEach({ (tag) in
            
            if let value: String = tag.value(forValueIdentifier: valueIdentifier) {
                values.insert(value)
            }
        })
        
        return values
    }
    
    /// Convenience function to filter HLSTag collections by a particular HLSTagDescriptor
    func filtered(by tagDescriptor: HLSTagDescriptor) -> [HLSTag] {
        
        return self.filter({ $0.tagDescriptor == tagDescriptor })
    }
    
    /// returns a new HLSTag Array that's sorted by resolution and bandwidth (in that order)
    func sortedByResolutionBandwidth(tolerance: Double = 1.0) -> [HLSTag] {
        
        return self.sorted { (a, b) -> Bool in
        
            if let aResolution: HLSResolution = a.resolution(),
                let bResolution: HLSResolution = b.resolution() {
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
