//
//  InterstitialTagBuilder.swift
//  mamba
//
//  Created by Migneco, Ray on 10/22/24.
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



/// A utility class for configuring and constructing an interstitial tag
/// The properties in this class are in accordance with the HLS spec
/// outlined in `draft-pantos-hls-rfc8216bis-15` Appendix D
/// https://datatracker.ietf.org/doc/html/draft-pantos-hls-rfc8216bis#appendix-D
public final class InterstitialTagBuilder {
    
    /// An Interstitial EXT-X-DATERANGE tag MUST have a CLASS attribute whose
    /// value is "com.apple.hls.interstitial".
    static let appleHLSInterstitialClassIdentifier = "com.apple.hls.interstitial"
    
    /// A quoted-string that uniquely identifies a Date Range in the
    /// Playlist.  This attribute is REQUIRED
    let id: String
    
    /// required to be "com.apple.hls.interstitial"
    let classId: String
    
    /// date/time at which the Date Range begins.  This attribute is REQUIRED.
    let startDate: Date
    
    /// The value of the X-ASSET-URI is a quoted-string absolute URI for a
    /// single interstitial asset.  An Interstitial EXT-X-DATERANGE tag
    /// MUST have either the X-ASSET-URI attribute or the X-ASSET-LIST
    /// attribute.  It MUST NOT have both.
    let assetUri: String?
    
    /// The value of the X-ASSET-LIST is a quoted-string URI to a JSON
    /// object.
    let assetList: String?
    
    /// the duration of the interstitial content in seconds
    var duration: Double?
    
    /// The value of X-RESUME-OFFSET is a decimal-floating-point of seconds that specifies where primary playback is to resume
    /// following the playback of the interstitial.
    var resumeOffset: Double?
    
    /// The value of X-PLAYOUT-LIMIT is a decimal-floating-point of seconds that specifies a limit for the playout time of the entire interstitial.
    var playoutLimit: Double?
    
    /// The value of the X-SNAP attribute is an enumerated-string-list of Snap Identifiers.
    /// The defined Snap Identifiers are: OUT and IN. This attribute is OPTIONAL.
    var alignment: HLSInterstitialAlignment?
    
    /// The value of the X-RESTRICT attribute is an enumerated-string-list of Navigation Restriction Identifiers.  The defined Navigation
    /// Restriction Identifiers are: SKIP and JUMP.  These restrictions are enforced at the player UI level.
    var restrictions: HLSInterstitialSeekRestrictions?
    
    /// This attribute indicates whether the interstitial is intended to be presented as distinct from the content ("HIGHLIGHT") or not differentiated ("PRIMARY").
    var timelineStyle: HLSInterstitialTimelineStyle?
    
    /// The attribute indicates whether the interstitial should be presented as a single point on the timeline or as a range.
    var timelineOccupation: HLSInterstitialTimelineOccupation?
    
    /// Provides a hint to the client to know how coordinated playback of the same asset will behave across multiple players
    var contentMayVary: Bool?
    
    /// The "X-" prefix defines a namespace reserved for client-defined attributes.  The client-attribute MUST be a legal AttributeName.
    /// Clients SHOULD use a reverse-DNS syntax when defining their own attribute names to avoid collisions.  The attribute value MUST be
    /// a quoted-string, a hexadecimal-sequence, or a decimal-floating- point.  An example of a client-defined attribute is X-COM-EXAMPLE-
    /// AD-ID="XYZ123".  These attributes are OPTIONAL.
    var clientAttributes: [String: LosslessStringConvertible]?
    
    /// Creates a Tag Builder using an asset Uri
    ///
    /// - Parameters:
    ///   - id: the identifier for the interstitial
    ///   - startDate: `Date` at which the interstitial begins
    ///   - assetUri: the URI locating the interstitial
    public init(id: String, startDate: Date, assetUri: String) {
        self.id = id
        self.startDate = startDate
        self.assetUri = assetUri
        self.assetList = nil
        self.classId = Self.appleHLSInterstitialClassIdentifier
    }
    
    /// Creates a Tag Builder using an Asset List Uri
    ///
    /// - Parameters:
    ///   - id: the identifier for the interstitial
    ///   - startDate: `Date` indicating when the interstitial begins
    ///   - assetList: the URI to a JSON object containing the assets
    public init(id: String, startDate: Date, assetList: String) {
        self.id = id
        self.startDate = startDate
        self.assetList = assetList
        self.assetUri = nil
        self.classId = Self.appleHLSInterstitialClassIdentifier
    }
    
    /// Specifies the duration of the interstitial
    ///
    /// - Parameter duration: `Double` indicating duration
    ///
    /// - Returns: an instance of the builder
    @discardableResult
    public func withDuration(_ duration: Double) -> Self {
        self.duration = duration
        
        return self
    }
    
    /// Configures the interstitial with a resume offset
    ///
    /// - Parameter offset: `Double` indicating the resume offset
    ///
    /// - Returns: an instance of the builder
    @discardableResult
    public func withResumeOffset(_ offset: Double) -> Self {
        self.resumeOffset = offset
        
        return self
    }
    
    /// Configures the interstitial with a playout limit
    ///
    /// - Parameter limit: `Double` indicating playout limit
    ///
    /// - Returns: an instance of the builder
    @discardableResult
    public func withPlayoutLimit(_ limit: Double) -> Self {
        self.playoutLimit = limit
        
        return self
    }
    
    /// Specifies the alignment of the interstitial with respect to content
    ///
    /// - Parameter alignment: `HLSInterstitialAlignment` specifying alignment guides
    ///
    /// - Returns: an instance of the builder
    @discardableResult
    public func withAlignment(_ alignment: HLSInterstitialAlignment) -> Self {
        self.alignment = alignment
        
        return self
    }
    
    /// Specifies seek restrictions applied to the interstitial
    ///
    /// - Parameter restrictions: instance of `HLSInterstitialSeekRestrictions`
    ///
    /// - Returns: an instance of the builder
    public func withRestrictions(_ restrictions: HLSInterstitialSeekRestrictions) -> Self {
        self.restrictions = restrictions
        
        return self
    }
    
    /// Specifies how the interstitial is styled on the timeline
    ///
    /// - Parameter style: `HLSInterstitialTimelineStyle` type
    ///
    /// - Returns: an instance of the builder
    @discardableResult
    public func withTimelineStyle(_ style: HLSInterstitialTimelineStyle) -> Self {
        self.timelineStyle = style
        
        return self
    }
    
    /// Describes how the interstitial occupies the content timeline
    ///
    /// - Parameter occupation: `HLSInterstitialTimelineOccupation` type
    ///
    /// - Returns: an instance of the builder
    @discardableResult
    public func withTimelineOccupation(_ occupation: HLSInterstitialTimelineOccupation) -> Self {
        self.timelineOccupation = occupation
        
        return self
    }
    
    /// Indicates if the interstitial content varies or stays the same during a shared watching activity
    ///
    /// - Parameter variation: `Bool` indicating if there's variation
    ///
    /// - Returns: an instance of the builder
    @discardableResult
    public func withContentVariation(_ variation: Bool) -> Self {
        self.contentMayVary = variation
        
        return self
    }
    
    /// Specifies client attributes describing the interstitial
    ///
    /// - Parameter attributes: a map of `[String: LosslessStringConvertible]` describing the attributes
    ///
    /// - Returns: an instance of the builder
    @discardableResult
    public func withClientAttributes(_ attributes: [String: LosslessStringConvertible]) -> Self {
        self.clientAttributes = attributes
        
        return self
    }
    
    /// Builds the DateRange tag utilizing the configured HLS interstitial properties
    ///
    /// - Returns: `HLSTag`
    public func buildTag() -> HLSTag {
        
        var hlsTagDictionary = HLSTagDictionary()
        
        hlsTagDictionary[PantosValue.id.rawValue] = HLSValueData(value: id, quoteEscaped: true)
        let startDateString = String.DateFormatter.iso8601MS.string(from: startDate)
        hlsTagDictionary[PantosValue.startDate.rawValue] = HLSValueData(value: startDateString,
                                                                        quoteEscaped: true)
        hlsTagDictionary[PantosValue.classAttribute.rawValue] = HLSValueData(value: classId,
                                                                             quoteEscaped: true)
        
        if let assetUri {
            hlsTagDictionary[PantosValue.assetUri.rawValue] = HLSValueData(value: assetUri, quoteEscaped: true)
        }
        
        if let assetList {
            hlsTagDictionary[PantosValue.assetList.rawValue] = HLSValueData(value: assetList, quoteEscaped: true)
        }
        
        if let duration {
            hlsTagDictionary[PantosValue.duration.rawValue] = HLSValueData(value: String(duration), quoteEscaped: true)
        }
        
        if let resumeOffset {
            hlsTagDictionary[PantosValue.resumeOffset.rawValue] = HLSValueData(value: String(resumeOffset),
                                                                               quoteEscaped: true)
        }
        
        if let playoutLimit {
            hlsTagDictionary[PantosValue.playoutLimit.rawValue] = HLSValueData(value: String(playoutLimit),
                                                                               quoteEscaped: true)
        }
        
        if let restrictions {
            let str = restrictions.restrictions.map({ $0.rawValue }).joined(separator: ",")
            hlsTagDictionary[PantosValue.restrict.rawValue] = HLSValueData(value: str, quoteEscaped: true)
        }
        
        if let alignment {
            let str = alignment.values.map({ $0.rawValue }).joined(separator: ",")
            hlsTagDictionary[PantosValue.snap.rawValue] = HLSValueData(value: str, quoteEscaped: true)
        }
        
        if let timelineStyle {
            hlsTagDictionary[PantosValue.timelineStyle.rawValue] = HLSValueData(value: timelineStyle.rawValue,
                                                                                quoteEscaped: true)
        }
        
        if let timelineOccupation {
            hlsTagDictionary[PantosValue.timelineOccupies.rawValue] = HLSValueData(value: timelineOccupation.rawValue,
                                                                                   quoteEscaped: true)
        }
        
        if let contentMayVary {
            hlsTagDictionary[PantosValue.contentMayVary.rawValue] = HLSValueData(value: contentMayVary == true ? "YES" : "NO",
                                                                                 quoteEscaped: true)
        }
        
        if let clientAttributes {
            for (k, v) in clientAttributes {
                hlsTagDictionary[k] = HLSValueData(value: String(v), quoteEscaped: true)
            }
        }
        
        return HLSTag(tagDescriptor: PantosTag.EXT_X_DATERANGE,
                      stringTagData: nil,
                      parsedValues: hlsTagDictionary)
    }
}
