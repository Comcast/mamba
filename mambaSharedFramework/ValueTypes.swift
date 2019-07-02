//
//  ValueTypes.swift
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
public typealias PlaylistTagIndexRange = CountableClosedRange<Int>
public typealias MediaGroupIndexRange = CountableClosedRange<Int>

/// Represents a video resolution
///
/// Can be initialized with a string in the form of "1280x720"
public struct ResolutionValueType: Equatable, Comparable, FailableStringLiteralConvertible {
    public let w: Int
    public let h: Int
    public init?(failableInitWithString string: String) {
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
    public var is16x9: Bool { return abs(ratio - ResolutionValueType.ratio16x9) < 0.01 }
    public var is4x3: Bool { return abs(ratio - ResolutionValueType.ratio4x3) < 0.01 }
}

public func ==(lhs: ResolutionValueType, rhs: ResolutionValueType) -> Bool {
    return lhs.w == rhs.w && lhs.h == rhs.h
}

public func <(lhs: ResolutionValueType, rhs: ResolutionValueType) -> Bool {
    return lhs.h < rhs.h
}

public func <=(lhs: ResolutionValueType, rhs: ResolutionValueType) -> Bool {
    return lhs.h <= rhs.h
}

public func >=(lhs: ResolutionValueType, rhs: ResolutionValueType) -> Bool {
    return lhs.h >= rhs.h
}

public func >(lhs: ResolutionValueType, rhs: ResolutionValueType) -> Bool {
    return lhs.h > rhs.h
}


/// Represents a media type
///
/// Can be initialized with a string "AUDIO" or "VIDEO" for a valid value
public struct MediaType: Equatable, FailableStringLiteralConvertible {
    public let type: Media
    public enum Media: String {
        case Video = "VIDEO"
        case Audio = "AUDIO"
        case Subtitles = "SUBTITLES"
        case ClosedCaptions = "CLOSED-CAPTIONS"
    }
    public init?(failableInitWithString string: String) {
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

public func ==(lhs: MediaType, rhs: MediaType) -> Bool {
    return lhs.type == rhs.type
}

public func ==(lhs: MediaType, rhs: MediaType.Media) -> Bool {
    return lhs.type == rhs
}

public func ==(lhs: MediaType.Media, rhs: MediaType) -> Bool {
    return lhs == rhs.type
}

public func !=(lhs: MediaType, rhs: MediaType.Media) -> Bool {
    return !(lhs == rhs)
}

public func !=(lhs: MediaType.Media, rhs: MediaType) -> Bool {
    return !(lhs == rhs)
}

/// Represents an encryption method
///
/// Can be initialized with a string "NONE" or "AES-128" or "SAMPLE-AES" for a valid value
public struct EncryptionMethodType: Equatable, FailableStringLiteralConvertible {
    public let type: EncryptionMethod
    public enum EncryptionMethod: String {
        case None = "NONE"
        case AES128 = "AES-128"
        case SampleAES = "SAMPLE-AES"
    }
    public init?(failableInitWithString string: String) {
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

public func ==(lhs: EncryptionMethodType, rhs: EncryptionMethodType) -> Bool {
    return lhs.type == rhs.type
}

/// Represents a playlist type
///
/// Can be initialized with a string "EVENT" or "VOD" for a valid value
public struct PlaylistValueType: Equatable, FailableStringLiteralConvertible {
    public let type: PlaylistTypeString
    public enum PlaylistTypeString: String {
        case Event = "EVENT"
        case VOD = "VOD"
    }
    public init?(failableInitWithString string: String) {
        self.init(playlistType: string)
    }
    public init?(playlistType: String) {
        guard let type = PlaylistTypeString.init(rawValue: playlistType) else {
            return nil
        }
        self.type = type
    }
    public init(type: PlaylistTypeString) {
        self.type = type
    }
}

public func ==(lhs: PlaylistValueType, rhs: PlaylistValueType) -> Bool {
    return lhs.type == rhs.type
}

/// Represents a instreamId type
///
/// Can be initialized with a string "CC1" or "CC2" or "CC3" or "CC4" for a valid value

public enum InstreamId: String, FailableStringLiteralConvertible {
    case CC1 = "CC1"
    case CC2 = "CC2"
    case CC3 = "CC3"
    case CC4 = "CC4"
    
    public init?(failableInitWithString string: String) {
        self.init(rawValue:string)
    }
    
}


/// Represents a CLOSED-CAPTIONS
///
/// can be either a quoted-string or an enumerated-string with the value NONE for a valid value
public struct ClosedCaptionsValueType: FailableStringLiteralConvertible {
    let value: String
    public init?(failableInitWithString string: String) {
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
public struct CodecValueType: Equatable {
    
    static let audioPrefixes: [String] = ["mp4a", "mp3", "ec-3", "ac-3"]
    static let videoPrefixes: [String] = ["avc", "mp4v", "svc", "mvc", "sevc", "s263", "hvc", "vp9"]
    public let codecDescriptor: String
    
    init(codecDescriptor: String) {
        self.codecDescriptor = codecDescriptor
    }
}

public func ==(lhs: CodecValueType, rhs: CodecValueType) -> Bool {
    return lhs.codecDescriptor == rhs.codecDescriptor
}

/// Represents a list of RFC6381 codecs
///
/// Can be initialized with a comma seperated, quote-delimited array of RFC6381 codec descriptors
public struct CodecValueTypeArray: Equatable, FailableStringLiteralConvertible {
    
    typealias codecTypeTest = (_: CodecValueType) -> Bool
    
    public let codecs: [CodecValueType]
    
    public init?(failableInitWithString string: String) {
        let stringArray = StringArrayParser.parseToArray(fromParsableString: string, ignoreQuotes: true)
        if (stringArray.count == 0) {
            return nil
        }
        var codecs = [CodecValueType]()
        for string in stringArray {
            codecs.append(CodecValueType(codecDescriptor: string.trim()))
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
        return CodecValueType.audioPrefixes.filter( { audioPrefix in return self.codecs.filter( { $0.codecDescriptor.hasPrefix(audioPrefix) } ).count > 0 } ).count > 0
    }
   
    public func containsVideo() -> Bool {
        return CodecValueType.videoPrefixes.filter( { videoPrefix in return self.codecs.filter( { $0.codecDescriptor.hasPrefix(videoPrefix) } ).count > 0 } ).count > 0
    }
    
    public func containsAudioVideo() -> Bool {
        return self.containsAudio() && self.containsVideo()
    }
    
    public init(codecs: [CodecValueType]) {
        self.codecs = codecs
    }
}

extension CodecValueTypeArray {
    public func includes(codec: CodecValueType) -> Bool {
        return codecs.contains(codec)
    }
}

public func ==(lhs: CodecValueTypeArray, rhs: CodecValueTypeArray) -> Bool {
    return lhs.codecs == rhs.codecs
}


