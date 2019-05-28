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
/// Can be initialized with a string "NONE" or "AES-128" or "SAMPLE-AES" for a valid value
public struct HLSEncryptionMethodType: Equatable, FailableStringLiteralConvertible {
    public let type: EncryptionMethod
    public enum EncryptionMethod: String {
        case None = "NONE"
        case AES128 = "AES-128"
        case SampleAES = "SAMPLE-AES"
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

/// Represents a RFC6381 codec
///
/// We are currently not parsing these values further
public struct HLSCodec: Equatable {
    
    static let audioPrefix = "mp4a"
    static let videoPrefix = "avc"
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
        return self.codecs.filter({ $0.codecDescriptor.hasPrefix(HLSCodec.audioPrefix)}).count == self.codecs.count
    }

    public func containsAudio() -> Bool {
        return self.contains(codecTypeTest: { return $0.codecDescriptor.hasPrefix(HLSCodec.audioPrefix) })
    }
   
    public func containsVideo() -> Bool {
        return self.contains(codecTypeTest: { return $0.codecDescriptor.hasPrefix(HLSCodec.videoPrefix) })
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


