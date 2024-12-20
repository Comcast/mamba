//
//  InterstitialValueTypes.swift
//  mamba
//
//  Created by Migneco, Ray on 11/1/24.
//  Copyright © 2024 Comcast Corporation.
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

/// specifies how the client should align interstitial content to the primary content
public struct HLSInterstitialAlignment: FailableStringLiteralConvertible, Equatable {

    public enum Snap: String, CaseIterable {
        /// client SHOULD locate the segment boundary closest to the scheduled resumption point from the
        /// interstitial in the Media Playlist of the primary content and resume playback of primary content at that boundary.
        case `in` = "IN"
        
        /// client SHOULD locate the segment boundary closest to the START-DATE of the interstitial in the
        /// Media Playlist of the primary content and transition to the interstitial at that boundary.
        case out = "OUT"
    }
    
    /// the set of snap options for aligning interstitial content
    public let values: Set<Snap>
    
    /// creates a snap guide based on provided values
    ///
    /// - Parameter values: array of `Snap` values
    public init(values: [Snap]) {
        self.values = Set(values)
    }
    
    /// creates a snap guide based on the provided string value
    ///
    /// - Parameter string: a comma separated string indicating snap values
    public init?(failableInitWithString string: String) {
        let snapValues = string.components(separatedBy: ",")
            .compactMap({ Snap(rawValue: $0 )})
        
        guard !snapValues.isEmpty else { return nil }
        
        self.init(values: snapValues)
    }
}

/// specifies how the player should enforce seek restrictions for the interstitial content
public struct HLSInterstitialSeekRestrictions: FailableStringLiteralConvertible, Equatable {
    
    public enum Restriction: String, CaseIterable {
        /// If the list contains SKIP then while the interstitial is being played, the client MUST NOT
        /// allow the user to seek forward from the current playhead position or set the rate to
        /// greater than the regular playback rate until playback reaches the end of the interstitial.
        case skip = "SKIP"
        
        /// If the list contains JUMP then the client MUST NOT allow the user to seek from a position
        /// in the primary asset earlier than the START-DATE attribute to a position after it without
        /// first playing the interstitial asset, even if the interstitial at START-DATE was played
        /// through earlier.
        case jump = "JUMP"
    }
    
    /// set of restrictions applied to the interstitial content
    public let restrictions: Set<Restriction>
    
    /// Creates a set of restrictions based on provided values
    ///
    /// - Parameter restrictions: array of `Restriction`
    public init(restrictions: [Restriction]) {
        self.restrictions = Set(restrictions)
    }
    
    /// creates a snap guide based on the provided string value
    ///
    /// - Parameter string: a comma separated string indicating snap values
    public init?(failableInitWithString string: String) {
        let restrictions = string.components(separatedBy: ",")
            .compactMap({ Restriction(rawValue: $0 )})
        
        guard !restrictions.isEmpty else { return nil }
        
        self.init(restrictions: restrictions)
    }
}

public enum HLSInterstitialTimelineStyle: String, FailableStringLiteralConvertible {
    
    /// indicates whether the interstitial is intended to be presented as distinct from the content
    case highlight = "HIGHLIGHT"
    
    /// indicates that the interstitial should NOT be presented as differentiated from the content
    case primary = "PRIMARY"
    
    /// Creates a timeline style from the provided string
    public init?(failableInitWithString string: String) {
        self.init(rawValue: string)
    }
}

/// Type that indicates how an interstitial event should be presented on a timeline
public enum HLSInterstitialTimelineOccupation: String, FailableStringLiteralConvertible {
    
    /// the interstitial should be presented as a single point on the timeline
    case point = "POINT"
    
    /// the interstitial should be presented as a range on the timeline
    case range = "RANGE"
    
    /// Creates a timeline occupation from the provided string
    public init?(failableInitWithString string: String) {
        self.init(rawValue: string)
    }
}
