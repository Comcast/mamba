//
//  HLSInterstitialValueTypes.swift
//  mamba
//
//  Created by Migneco, Ray on 10/22/24.
//

import Foundation

/// specifies how the client should align interstitial content to the primary content
public struct HLSInterstitialAlignment: FailableStringLiteralConvertible {

    public enum Snap: String, CaseIterable {
        /// client SHOULD locate the segment boundary closest to the scheduled resumption point from the
        /// interstitial in the Media Playlist of the primary content and resume playback of primary content at that boundary.
        case snapIn = "IN"
        
        /// client SHOULD locate the segment boundary closest to the START-DATE of the interstitial in the
        /// Media Playlist of the primary content and transition to the interstitial at that boundary.
        case snapOut = "OUT"
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
    public init?(string: String) {
        let snapValues = string.components(separatedBy: ",")
            .compactMap({ Snap(rawValue: $0 )})
        
        guard !snapValues.isEmpty else { return nil }
        
        self.init(values: snapValues)
    }
}

/// specifies how the player should enforce seek restrictions for the interstitial content
public struct HLSInterstitialSeekRestrictions: FailableStringLiteralConvertible {
    
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
    public init?(string: String) {
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
    public init?(string: String) {
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
    public init?(string: String) {
        self.init(rawValue: string)
    }
}
