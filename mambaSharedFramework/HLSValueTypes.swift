//
//  HLSValueTypes.swift
//  mamba
//
//  Created by David Coufal on 8/4/16.
//  Copyright © 2016 Comcast Cable Communications Management, LLC
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

public typealias MediaSequence = Int
public typealias HLSTagIndexRange = CountableClosedRange<Int>
public typealias HLSMediaGroupIndexRange = CountableClosedRange<Int>

/// Represents a video resolution
///
/// Can be initialized with a string in the form of "1280x720"
public struct HLSResolution: Equatable, Comparable, FailableStringLiteralConvertible {
    public let w: Int
    public let h: Int
    public init?(string: String) {
        self.init(resolution: string)
    }
    public init?(resolution: String) {
        let values = resolution.split{$0 == "x"}.map(String.init)
        guard values.count == 2, let w = Int(values[0]), let h = Int(values[1]) else {
            return nil
        }
        self.w = w
        self.h = h
    }
    public init(width: Int, height: Int) {
        self.w = width
        self.h = height
    }
    
    static let ratio16x9: Float = 16.0 / 9.0
    static let ratio4x3: Float = 4.0 / 3.0
    public var ratio: Float { return Float(w)/Float(h) }
    public var is16x9: Bool { return abs(ratio - HLSResolution.ratio16x9) < 0.01 }
    public var is4x3: Bool { return abs(ratio - HLSResolution.ratio4x3) < 0.01 }
}

public func ==(lhs: HLSResolution, rhs: HLSResolution) -> Bool {
    return lhs.w == rhs.w && lhs.h == rhs.h
}

public func <(lhs: HLSResolution, rhs: HLSResolution) -> Bool {
    return lhs.h < rhs.h
}

public func <=(lhs: HLSResolution, rhs: HLSResolution) -> Bool {
    return lhs.h <= rhs.h
}

public func >=(lhs: HLSResolution, rhs: HLSResolution) -> Bool {
    return lhs.h >= rhs.h
}

public func >(lhs: HLSResolution, rhs: HLSResolution) -> Bool {
    return lhs.h > rhs.h
}


/// Represents a media type
///
/// Can be initialized with a string "AUDIO" or "VIDEO" for a valid value
public struct HLSMediaType: Equatable, FailableStringLiteralConvertible {
    public let type: Media
    public enum Media: String {
        case Video = "VIDEO"
        case Audio = "AUDIO"
        case Subtitles = "SUBTITLES"
        case ClosedCaptions = "CLOSED-CAPTIONS"
    }
    public init?(string: String) {
        self.init(mediaType: string)
    }
    public init?(mediaType: String) {
        guard let type = Media.init(rawValue: mediaType) else {
            return nil
        }
        self.type = type
    }
    public init(media: Media) {
        self.type = media
    }
}

public func ==(lhs: HLSMediaType, rhs: HLSMediaType) -> Bool {
    return lhs.type == rhs.type
}

/// Represents an encryption method
///
/// Can be initialized with a string "NONE" or "AES-128" or "SAMPLE-AES" or "SAMPLE-AES-CTR" for a valid value
public struct HLSEncryptionMethodType: Equatable, FailableStringLiteralConvertible {
    public let type: EncryptionMethod
    public enum EncryptionMethod: String {
        case None = "NONE"
        case AES128 = "AES-128"
        case SampleAES = "SAMPLE-AES"
        case SampleAESCTR = "SAMPLE-AES-CTR"
    }
    public init?(string: String) {
        self.init(encryption: string)
    }
    public init?(encryption: String) {
        guard let type = EncryptionMethod.init(rawValue: encryption) else {
            return nil
        }
        self.type = type
    }
    public init(encryptionType: EncryptionMethod) {
        self.type = encryptionType
    }
}

public func ==(lhs: HLSEncryptionMethodType, rhs: HLSEncryptionMethodType) -> Bool {
    return lhs.type == rhs.type
}

/// Represents a minimum required HDCP level needed to play content.
public struct HLSHDCPLevel: Equatable, FailableStringLiteralConvertible {
    public let type: HDCPLevel
    public enum HDCPLevel: String {
        /// Indicates that the content does not require output copy protections.
        case none = "NONE"
        /// Indicates that the Variant Stream could fail to play unless the output is protected by High-bandwidth
        /// Digital Content Protection (HDCP) Type 0 or equivalent.
        case type0 = "TYPE-0"
        /// Indicates that the Variant Stream could fail to play unless the output is protected by HDCP Type 1 or
        /// equivalent.
        case type1 = "TYPE-1"
    }
    public init?(string: String) {
        self.init(hdcpLevel: string)
    }
    public init?(hdcpLevel: String) {
        guard let type = HDCPLevel(rawValue: hdcpLevel) else {
            return nil
        }
        self.type = type
    }
    public init(hdcpLevel: HDCPLevel) {
        self.type = hdcpLevel
    }
}

/// Represents the dynamic range of the video.
///
/// This is represented by an enumeration where each case covers a group of similar opto-electronic transfer
/// characteristic functions that could have been used to encode the media file.
///
/// For example, `SDR` covers TransferCharacteristics code points 1, 6, 13, 14 and 15. More information on what each
/// code point represents can be found in _"Information technology - MPEG systems technologies - Part 8: Coding-_
/// _independent code points" ISO/IEC International Standard 23001-8, 2016_ [CICP].
public struct HLSVideoRange: Equatable, FailableStringLiteralConvertible {
    public let type: VideoRange
    public enum VideoRange: String {
        /// The value MUST be SDR if the video in the Variant Stream is encoded using one of the following reference
        /// opto-electronic transfer characteristic functions specified by the TransferCharacteristics code point: 1, 6,
        /// 13, 14, 15. Note that different TransferCharacteristics code points can use the same transfer function.
        case sdr = "SDR"
        /// The value MUST be HLG if the video in the Variant Stream is encoded using a reference opto-electronic
        /// transfer characteristic function specified by the TransferCharacteristics code point 18, or consists of such
        /// video mixed with video qualifying as SDR.
        case hlg = "HLG"
        /// The value MUST be PQ if the video in the Variant Stream is encoded using a reference opto-electronic
        /// transfer characteristic function specified by the TransferCharacteristics code point 16, or consists of such
        /// video mixed with video qualifying as SDR or HLG.
        case pq = "PQ"
    }
    public init?(string: String) {
        self.init(videoRange: string)
    }
    public init?(videoRange: String) {
        guard let type = VideoRange(rawValue: videoRange) else {
            return nil
        }
        self.type = type
    }
    public init(videoRange: VideoRange) {
        self.type = videoRange
    }
}

/// Represents a playlist type
///
/// Can be initialized with a string "EVENT" or "VOD" for a valid value
public struct HLSPlaylistType: Equatable, FailableStringLiteralConvertible {
    public let type: PlaylistType
    public enum PlaylistType: String {
        case Event = "EVENT"
        case VOD = "VOD"
    }
    public init?(string: String) {
        self.init(playlistType: string)
    }
    public init?(playlistType: String) {
        guard let type = PlaylistType.init(rawValue: playlistType) else {
            return nil
        }
        self.type = type
    }
    public init(type: PlaylistType) {
        self.type = type
    }
}

public func ==(lhs: HLSPlaylistType, rhs: HLSPlaylistType) -> Bool {
    return lhs.type == rhs.type
}

/// Represents a instreamId type
///
/// Can be initialized with a string "CC1" or "CC2" or "CC3" or "CC4" for a valid value

public enum HLSInstreamId: String, FailableStringLiteralConvertible {
    case CC1 = "CC1"
    case CC2 = "CC2"
    case CC3 = "CC3"
    case CC4 = "CC4"
    
    public init?(string: String) {
        self.init(rawValue:string)
    }
    
}


/// Represents a CLOSED-CAPTIONS
///
/// can be either a quoted-string or an enumerated-string with the value NONE for a valid value
public struct HLSClosedCaptions: FailableStringLiteralConvertible {
    let value: String
    public init?(string: String) {
        if !(string.hasPrefix("\"") && string.hasSuffix("\"")){
            if string != "NONE" {
                return nil
            }
        }
        self.value = string
    }
}

/// Represents CHANNELS
public struct HLSChannels: Equatable, FailableStringLiteralConvertible {
    /// A count of audio channels, indicating the maximum number of independent, simultaneous audio channels present in
    /// any Media Segment in the Rendition.
    ///
    /// For example, an AC-3 5.1 Rendition would have a CHANNELS="6" attribute.
    public let count: Int
    /// Identifies the presence of spatial audio of some kind, for example, object-based audio, in the Rendition. The
    /// Audio Coding Identifiers are codec-specific.
    public let spatialAudioCodingIdentifiers: [String]
    /// Supplementary indications of special channel usage that are necessary for informed selection and processing.
    /// This parameter is an array of Special Usage Identifiers.
    public let specialUsageIdentifiers: [SpecialUsageIdentifier]

    public enum SpecialUsageIdentifier: String {
        /// The audio is binaural (either recorded or synthesized). It SHOULD NOT be dynamically spatialized. It is best
        /// suited for delivery to headphones.
        case binaural = "BINAURAL"
        /// The audio is pre-processed content that SHOULD NOT be dynamically spatialized. It is suitable to deliver to
        /// either headphones or speakers.
        case immersive = "IMMERSIVE"
        /// The audio is a downmix derivative of some other audio. If desired, the downmix may be used as a subtitute
        /// for alternative Renditions in the same group with compatible attributes and a greater channel count. It MAY
        /// be dynamically spatialized.
        case downmix = "DOWNMIX"

        /// Allows `init` without having to allocate a new `String` object.
        init?(str: Substring) {
            switch str {
            case "BINAURAL": self = .binaural
            case "IMMERSIVE": self = .immersive
            case "DOWNMIX": self = .downmix
            default: return nil
            }
        }
    }

    public init?(string: String) {
        var count: Int?
        var spatialAudioCodingIdentifiers: [String]?
        var specialUsageIdentifiers: [SpecialUsageIdentifier]?
        let enumeratedSplit = string.split(separator: "/").enumerated()
        for (index, str) in enumeratedSplit {
            switch index {
            case 0: count = Self.parseChannelCount(str: str)
            case 1: spatialAudioCodingIdentifiers = Self.parseSpatialAudioCodingIdentifiers(str: str)
            case 2:
                guard let ids = Self.parseSpecialUsageIdentifiers(str: str) else {
                    // In the case that we don't recognize one of the special usage identifiers, leading to nil being
                    // parsed out, I believe it is better to fail the entire parsing, as otherwise we could mislead the
                    // user of the library into thinking that there are less special usage identifiers than there
                    // actually are in the CHANNELS attribtue.
                    return nil
                }
                specialUsageIdentifiers = ids
            default: break // In the future there may be more parameters defined.
            }
        }
        // Count is required to have been parsed.
        guard let count else {
            return nil
        }
        self.count = count
        self.spatialAudioCodingIdentifiers = spatialAudioCodingIdentifiers ?? []
        self.specialUsageIdentifiers = specialUsageIdentifiers ?? []
    }

    public init(
        count: Int,
        spatialAudioCodingIdentifiers: [String],
        specialUsageIdentifiers: [SpecialUsageIdentifier]
    ) {
        self.count = count
        self.spatialAudioCodingIdentifiers = spatialAudioCodingIdentifiers
        self.specialUsageIdentifiers = specialUsageIdentifiers
    }

    private static func parseChannelCount(str: Substring) -> Int? {
        Int(string: String(str))
    }

    private static func parseSpatialAudioCodingIdentifiers(str: Substring) -> [String] {
        let split = str.split(separator: ",")
        var identifiers = [String]()
        for id in split where id != "-" {
            identifiers.append(String(id))
        }
        return identifiers
    }

    private static func parseSpecialUsageIdentifiers(str: Substring) -> [SpecialUsageIdentifier]? {
        let split = str.split(separator: ",")
        var identifiers = [SpecialUsageIdentifier]()
        for id in split {
            guard let specialUsageId = SpecialUsageIdentifier(str: id) else {
                return nil
            }
            identifiers.append(specialUsageId)
        }
        return identifiers
    }
}

/// Represents a RFC6381 codec
///
/// We are currently not parsing these values further
public struct HLSCodec: Equatable {
    
    static let audioPrefixes: [String] = ["mp4a", "mp3", "ec-3", "ac-3"]
    static let videoPrefixes: [String] = ["avc", "mp4v", "svc", "mvc", "sevc", "s263", "hvc", "vp9"]
    public let codecDescriptor: String
    
    init(codecDescriptor: String) {
        self.codecDescriptor = codecDescriptor
    }
}

public func ==(lhs: HLSCodec, rhs: HLSCodec) -> Bool {
    return lhs.codecDescriptor == rhs.codecDescriptor
}

/// Represents a list of RFC6381 codecs
///
/// Can be initialized with a comma seperated, quote-delimited array of RFC6381 codec descriptors
public struct HLSCodecArray: Equatable, FailableStringLiteralConvertible {
    
    typealias codecTypeTest = (_: HLSCodec) -> Bool
    
    public let codecs: [HLSCodec]
    
    public init?(string: String) {
        let stringArray = StringArrayParser.parseToArray(fromParsableString: string, ignoreQuotes: true)
        if (stringArray.count == 0) {
            return nil
        }
        var codecs = [HLSCodec]()
        for string in stringArray {
            codecs.append(HLSCodec(codecDescriptor: string.trim()))
        }
        self.codecs = codecs
    }
    
    internal func contains(codecTypeTest: codecTypeTest) -> Bool {
        for codec in codecs {
            if codecTypeTest(codec) { return true }
        }
        return false
    }

    public func containsAudioOnly() -> Bool {
        return containsAudio() && !containsVideo()
    }

    public func containsAudio() -> Bool {
        return HLSCodec.audioPrefixes.filter( { audioPrefix in return self.codecs.filter( { $0.codecDescriptor.hasPrefix(audioPrefix) } ).count > 0 } ).count > 0
    }
   
    public func containsVideo() -> Bool {
        return HLSCodec.videoPrefixes.filter( { videoPrefix in return self.codecs.filter( { $0.codecDescriptor.hasPrefix(videoPrefix) } ).count > 0 } ).count > 0
    }
    
    public func containsAudioVideo() -> Bool {
        return self.containsAudio() && self.containsVideo()
    }
    
    public init(codecs: [HLSCodec]) {
        self.codecs = codecs
    }
}

extension HLSCodecArray {
    public func includes(codec: HLSCodec) -> Bool {
        return codecs.contains(codec)
    }
}

public func ==(lhs: HLSCodecArray, rhs: HLSCodecArray) -> Bool {
    return lhs.codecs == rhs.codecs
}


