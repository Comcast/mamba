//
//  PantosTag.swift
//  mamba
//
//  Created by David Coufal on 7/11/16.
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

/**
 enum describing all playlist tags that mamba understands from the Pantos HLS specification
 
 `.Comment` is a special tag, indicating a HLS comment
 
 `.UnknownTag` is a special tag, indicating a tag recognized as a HLS tag, but one that we do not currently parse
 
 Other tags that are treated specially are:
 
 `.Location`: will not have a `tagName`
 
 `.EXTM3U`: will not actually show up in PlaylistTag arrays for playlists. It's here as a convenience.
 
 `.EXTINF`: Since this is such a common tag and appears in great numbers, the duration is available as a direct
 property on `PlaylistTag`. This allows us to speed parsing of these tags.
 */
public enum PantosTag: String {
    
    // MARK: special tags
    
    /// Special Tag Indicating a Comment line
    case Comment = "Comment"
    /// Special Tag Indicating that we found a tag that we did not recognize
    case UnknownTag = "UnknownTag"
    /// Special Tag Indicating that we found a media location
    case Location = "Location"
    
    // MARK: Basic tags
    case EXTM3U = "EXTM3U"
    case EXT_X_VERSION = "EXT-X-VERSION"
    
    // MARK: master playlist tags
    case EXT_X_MEDIA = "EXT-X-MEDIA"
    case EXT_X_STREAM_INF = "EXT-X-STREAM-INF"
    case EXT_X_I_FRAME_STREAM_INF = "EXT-X-I-FRAME-STREAM-INF"
    case EXT_X_SESSION_DATA = "EXT-X-SESSION-DATA"
    case EXT_X_SESSION_KEY = "EXT-X-SESSION-KEY"
    case EXT_X_CONTENT_STEERING = "EXT-X-CONTENT-STEERING"

    // MARK: Variant playlist tags
    case EXT_X_TARGETDURATION = "EXT-X-TARGETDURATION"
    case EXT_X_MEDIA_SEQUENCE = "EXT-X-MEDIA-SEQUENCE"
    case EXT_X_ENDLIST = "EXT-X-ENDLIST"
    case EXT_X_PLAYLIST_TYPE = "EXT-X-PLAYLIST-TYPE"
    case EXT_X_I_FRAMES_ONLY = "EXT-X-I-FRAMES-ONLY"
    case EXT_X_ALLOW_CACHE = "EXT-X-ALLOW-CACHE"
    case EXT_X_INDEPENDENT_SEGMENTS = "EXT-X-INDEPENDENT-SEGMENTS"
    case EXT_X_START = "EXT-X-START"
    
    // MARK: Variant playlist - Media segment tags
    case EXTINF = "EXTINF"
    case EXT_X_BITRATE = "EXT-X-BITRATE"
    case EXT_X_BYTERANGE = "EXT-X-BYTERANGE"
    case EXT_X_KEY = "EXT-X-KEY"
    case EXT_X_MAP = "EXT-X-MAP"
    case EXT_X_PROGRAM_DATE_TIME = "EXT-X-PROGRAM-DATE-TIME"
    case EXT_X_DISCONTINUITY = "EXT-X-DISCONTINUITY"
    case EXT_X_DISCONTINUITY_SEQUENCE = "EXT-X-DISCONTINUITY-SEQUENCE"
    
    // MARK: Variant playlist - Media metadata tags
    case EXT_X_DATERANGE = "EXT-X-DATERANGE"
}

extension PantosTag: PlaylistTagDescriptor, Equatable {
    
    public static func constructTag(tag: String) -> PlaylistTagDescriptor? {
        return PantosTag(rawValue: tag)
    }
    
    public func toString() -> String {
        return self.rawValue
    }
    
    public func isEqual(toTagDescriptor tagDescriptor: PlaylistTagDescriptor) -> Bool {
        guard let pantos = tagDescriptor as? PantosTag else {
            return false
        }
        return pantos.rawValue == self.rawValue
    }
    
    public func scope() -> PlaylistTagDescriptorScope {
        switch self {
            
        case .Location:
            fallthrough
        case .EXT_X_STREAM_INF:
            fallthrough
        case .EXT_X_BYTERANGE:
            fallthrough
        case .EXT_X_PROGRAM_DATE_TIME:
            fallthrough
        case .EXT_X_DISCONTINUITY:
            fallthrough
        case .EXTINF:
            return .mediaSegment
            
        case .EXTM3U:
            fallthrough
        case .EXT_X_I_FRAMES_ONLY:
            fallthrough
        case .EXT_X_MEDIA_SEQUENCE:
            fallthrough
        case .EXT_X_ALLOW_CACHE:
            fallthrough
        case .EXT_X_VERSION:
            fallthrough
        case .EXT_X_PLAYLIST_TYPE:
            fallthrough
        case .EXT_X_MEDIA:
            fallthrough
        case .EXT_X_I_FRAME_STREAM_INF:
            fallthrough
        case .EXT_X_SESSION_DATA:
            fallthrough
        case .EXT_X_SESSION_KEY:
            fallthrough
        case .EXT_X_CONTENT_STEERING:
            fallthrough
        case .EXT_X_ENDLIST:
            fallthrough
        case .EXT_X_INDEPENDENT_SEGMENTS:
            fallthrough
        case .EXT_X_START:
            fallthrough
        case .EXT_X_DISCONTINUITY_SEQUENCE:
            fallthrough
        case .EXT_X_TARGETDURATION:
            fallthrough
        case .EXT_X_DATERANGE:
            return .wholePlaylist
        
        case .EXT_X_BITRATE:
            fallthrough
        case .EXT_X_MAP:
            fallthrough
        case .EXT_X_KEY:
            return .mediaSpanner
            
        case .Comment:
            fallthrough
        case .UnknownTag:
            return .unknown
        }
    }
    
    public func type() -> PlaylistTagDescriptorType {
        switch self {
            
        case .EXTM3U:
            fallthrough
        case .EXT_X_DISCONTINUITY:
            fallthrough
        case .EXT_X_I_FRAMES_ONLY:
            fallthrough
        case .EXT_X_INDEPENDENT_SEGMENTS:
            fallthrough
        case .EXT_X_ENDLIST:
            return .noValue
            
        case .EXT_X_BITRATE:
            fallthrough
        case .EXT_X_BYTERANGE:
            fallthrough
        case .EXT_X_PROGRAM_DATE_TIME:
            fallthrough
        case .EXT_X_MEDIA_SEQUENCE:
            fallthrough
        case .EXT_X_ALLOW_CACHE:
            fallthrough
        case .EXT_X_VERSION:
            fallthrough
        case .EXT_X_PLAYLIST_TYPE:
            fallthrough
        case .EXT_X_DISCONTINUITY_SEQUENCE:
            fallthrough
        case .EXT_X_TARGETDURATION:
            return .singleValue
            
        case .EXTINF:
            return .array
            
        case .EXT_X_I_FRAME_STREAM_INF:
            fallthrough
        case .EXT_X_SESSION_DATA:
            fallthrough
        case .EXT_X_SESSION_KEY:
            fallthrough
        case .EXT_X_CONTENT_STEERING:
            fallthrough
        case .EXT_X_MEDIA:
            fallthrough
        case .EXT_X_STREAM_INF:
            fallthrough
        case .EXT_X_MAP:
            fallthrough
        case .EXT_X_START:
            fallthrough
        case .EXT_X_KEY:
            fallthrough
        case .EXT_X_DATERANGE:
            return .keyValue
            
        case .Location:
            fallthrough
        case .Comment:
            fallthrough
        case .UnknownTag:
            return .special
        }
    }
    
    public static func parser(forTag tag: PlaylistTagDescriptor) -> PlaylistTagParser? {
        guard let pantostag = PantosTag(rawValue: tag.toString()) else {
            return nil
        }
        switch pantostag {
            
        // All the special tags
            
        case .Comment:
            fallthrough
        case .Location:
            fallthrough
        case .UnknownTag:
            fallthrough
        case .EXTINF:
            assert(false) // should not be specifically asking for parsers for any of the above tags
            return nil
            
        // GenericSingleValueTagParser
            
        case .EXT_X_TARGETDURATION:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.targetDurationSeconds)
        case .EXT_X_MEDIA_SEQUENCE:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.sequence)
        case .EXT_X_ALLOW_CACHE:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.allowCache)
        case .EXT_X_PROGRAM_DATE_TIME:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.programDateTime)
        case .EXT_X_VERSION:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.version)
        case .EXT_X_PLAYLIST_TYPE:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.playlistType)
        case .EXT_X_BYTERANGE:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.byterange)
        case .EXT_X_DISCONTINUITY_SEQUENCE:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.discontinuitySequence)
        case .EXT_X_BITRATE:
            return GenericSingleValueTagParser(tag: pantostag,
                                               singleValueIdentifier:PantosValue.bandwidthBPS)

        // GenericDictionaryTagParser
            
        case .EXT_X_STREAM_INF:
            fallthrough
        case .EXT_X_MEDIA:
            fallthrough
        case .EXT_X_I_FRAME_STREAM_INF:
            fallthrough
        case .EXT_X_SESSION_DATA:
            fallthrough
        case .EXT_X_SESSION_KEY:
            fallthrough
        case .EXT_X_CONTENT_STEERING:
            fallthrough
        case .EXT_X_MAP:
            fallthrough
        case .EXT_X_START:
            fallthrough
        case .EXT_X_KEY:
            fallthrough
        case .EXT_X_DATERANGE:
            return GenericDictionaryTagParser(tag: pantostag)
            
        // No Data tags
            
        case .EXTM3U:
            fallthrough
        case .EXT_X_ENDLIST:
            fallthrough
        case .EXT_X_DISCONTINUITY:
            fallthrough
        case .EXT_X_INDEPENDENT_SEGMENTS:
            fallthrough
        case .EXT_X_I_FRAMES_ONLY:
            assert(false) // should not be specifically asking for parsers for any no data tags
            return nil
        }
    }
    
    public static func writer(forTag tag: PlaylistTagDescriptor) -> PlaylistTagWriter? {
        guard let pantostag = PantosTag(rawValue: tag.toString()) else {
            return nil
        }
        
        switch pantostag {
            
        case .Location:
            return LocationTagWriter()
            
        // GenericSingleTagWriter
        
        case .EXT_X_TARGETDURATION:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.targetDurationSeconds)
        case .EXT_X_MEDIA_SEQUENCE:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.sequence)
        case .EXT_X_ALLOW_CACHE:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.allowCache)
        case .EXT_X_PROGRAM_DATE_TIME:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.programDateTime)
        case .EXT_X_VERSION:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.version)
        case .EXT_X_PLAYLIST_TYPE:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.playlistType)
        case .EXT_X_BYTERANGE:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.byterange)
        case .EXT_X_DISCONTINUITY_SEQUENCE:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.discontinuitySequence)
        case .EXT_X_BITRATE:
            return GenericSingleTagWriter(singleTagValueIdentifier: PantosValue.bandwidthBPS)

        // GenericDictionaryTagWriter
            
        case .EXT_X_STREAM_INF:
            fallthrough
        case .EXT_X_MEDIA:
            fallthrough
        case .EXT_X_I_FRAME_STREAM_INF:
            fallthrough
        case .EXT_X_SESSION_DATA:
            fallthrough
        case .EXT_X_SESSION_KEY:
            fallthrough
        case .EXT_X_CONTENT_STEERING:
            fallthrough
        case .EXT_X_MAP:
            fallthrough
        case .EXT_X_START:
            fallthrough
        case .EXT_X_KEY:
            fallthrough
        case .EXT_X_DATERANGE:
            return GenericDictionaryTagWriter()
            
        // These tags cannot be modified and therefore these cases are invalid.
            
        case .Comment:
            fallthrough
        case .UnknownTag:
            fallthrough
        case .EXTINF:
            fallthrough
        case .EXTM3U:
            fallthrough
        case .EXT_X_ENDLIST:
            fallthrough
        case .EXT_X_DISCONTINUITY:
            fallthrough
        case .EXT_X_INDEPENDENT_SEGMENTS:
            fallthrough
        case .EXT_X_I_FRAMES_ONLY:
            return nil
        }
    }
    
    public static func validator(forTag tag: PlaylistTagDescriptor) -> PlaylistTagValidator? {
        guard let pantostag = PantosTag(rawValue: tag.toString()) else {
            return nil
        }
        switch pantostag {
            
        case .EXT_X_TARGETDURATION:
            return GenericSingleTagValidator<Int>(tag: pantostag,
                                                  singleValueIdentifier:PantosValue.targetDurationSeconds)
        case .EXT_X_VERSION:
            return GenericSingleTagValidator<Int>(tag: pantostag,
                                                  singleValueIdentifier:PantosValue.version)
        case .EXT_X_MEDIA_SEQUENCE:
            return GenericSingleTagValidator<Int>(tag: pantostag,
                                                  singleValueIdentifier:PantosValue.sequence)
        case .EXT_X_ALLOW_CACHE:
            return GenericSingleTagValidator<Bool>(tag: pantostag,
                                                   singleValueIdentifier:PantosValue.allowCache)
        case .EXT_X_PLAYLIST_TYPE:
            return GenericSingleTagValidator<PlaylistValueType>(tag: pantostag,
                                                                singleValueIdentifier:PantosValue.playlistType)
        case .EXT_X_PROGRAM_DATE_TIME:
            return GenericSingleTagValidator<Date>(tag: pantostag,
                                                   singleValueIdentifier:PantosValue.programDateTime)
        case .EXT_X_DISCONTINUITY_SEQUENCE:
            return GenericSingleTagValidator<Int>(tag: pantostag,
                                                  singleValueIdentifier:PantosValue.discontinuitySequence)
        case .EXT_X_BITRATE:
            return GenericSingleTagValidator<Double>(tag: pantostag,
                                                     singleValueIdentifier:PantosValue.bandwidthBPS)

        case .EXT_X_STREAM_INF:
            return GenericDictionaryTagValidator(tag: pantostag, dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.bandwidthBPS, optional: false, expectedType: Int.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.averageBandwidthBPS, optional: true, expectedType: Int.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.score, optional: true, expectedType: Double.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.programId, optional: true, expectedType: Int.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.codecs, optional: true, expectedType: CodecValueTypeArray.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.supplementalCodecs, optional: true, expectedType: CodecValueTypeArray.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.resolution, optional: true, expectedType: ResolutionValueType.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.frameRate, optional: true, expectedType: Double.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.hdcpLevel, optional: true, expectedType: HDCPLevel.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.allowedCpc, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.videoRange, optional: true, expectedType: VideoRange.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.reqVideoLayout, optional: true, expectedType: VideoLayout.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.stableVariantId, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.audioGroup, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.videoGroup, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.subtitlesGroup, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.closedCaptionsGroup, optional: true, expectedType: ClosedCaptionsValueType.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.pathwayId, optional: true, expectedType: String.self)
                ])
            
        case .EXT_X_MEDIA:
            return GenericDictionaryTagValidator(tag: pantostag, dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.uri, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.type, optional: true, expectedType: MediaType.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.groupId, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.language, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.assocLanguage, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.name, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.stableRenditionId, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.defaultMedia, optional: true, expectedType: Bool.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.autoselect, optional: true, expectedType: Bool.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.forced, optional: true, expectedType: Bool.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.instreamId, optional: true, expectedType: InstreamId.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.bitDepth, optional: true, expectedType: Int.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.sampleRate, optional: true, expectedType: Int.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.characteristics, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.channels, optional: true, expectedType: Channels.self)
                ])
            
        case .EXT_X_I_FRAME_STREAM_INF:
            return GenericDictionaryTagValidator(tag: pantostag, dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.uri, optional: false, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.bandwidthBPS, optional: false, expectedType: Int.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.averageBandwidthBPS, optional: true, expectedType: Int.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.score, optional: true, expectedType: Double.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.programId, optional: true, expectedType: Int.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.codecs, optional: true, expectedType: CodecValueTypeArray.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.supplementalCodecs, optional: true, expectedType: CodecValueTypeArray.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.resolution, optional: true, expectedType: ResolutionValueType.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.hdcpLevel, optional: true, expectedType: HDCPLevel.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.allowedCpc, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.videoRange, optional: true, expectedType: VideoRange.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.reqVideoLayout, optional: true, expectedType: VideoLayout.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.stableVariantId, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.videoGroup, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.pathwayId, optional: true, expectedType: String.self),
                ])

        case .EXT_X_SESSION_DATA:
            return EXT_X_SESSION_DATATagValidator()

        case .EXT_X_SESSION_KEY:
            return EXT_X_SESSION_KEYValidator()

        case .EXT_X_CONTENT_STEERING:
            return GenericDictionaryTagValidator(tag: pantostag, dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.serverUri,
                                                 optional: false,
                                                 expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.pathwayId,
                                                 optional: true,
                                                 expectedType: String.self)
            ])

        case .EXT_X_KEY:
            return EXT_X_KEYValidator(tag: pantostag, dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.method, optional: true, expectedType: EncryptionMethodType.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.uri, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.ivector, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.keyformat, optional: true, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.keyformatVersions, optional: true, expectedType: String.self)
                ])
            
        case .EXT_X_MAP:
            return GenericDictionaryTagValidator(tag: pantostag, dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.uri, optional: false, expectedType: String.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.byterange, optional: true, expectedType: String.self),
                ])
            
        case .EXTINF:
            return EXTINFValidator()
            
        case .EXT_X_BYTERANGE:
            return GenericDictionaryTagValidator(tag: pantostag, dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.byterange, optional: true, expectedType: String.self)
                ])
        
        case .EXT_X_START:
            return GenericDictionaryTagValidator(tag: pantostag, dictionaryValueIdentifiers: [
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.startTimeOffset, optional: false, expectedType: Float.self),
                DictionaryTagValueIdentifierImpl(valueId: PantosValue.precise, optional: true, expectedType: Bool.self)
                ])
            
        case .EXT_X_DATERANGE:
            return EXT_X_DATERANGETagValidator()
            
        case .Location:
            return nil

        // No validation required
        case .EXT_X_ENDLIST,.EXT_X_DISCONTINUITY,.EXT_X_INDEPENDENT_SEGMENTS,.EXT_X_I_FRAMES_ONLY,.Comment,.UnknownTag,.EXTM3U:
            return nil
        }
    }
    
    public static func constructDescriptor(fromStringRef string: MambaStringRef) -> PlaylistTagDescriptor? {
        
        let possiblematchs = stringRefLookup[string.length]
        if let possiblematchs = possiblematchs {
            for possiblematch in possiblematchs {
                if possiblematch.string == string {
                    return possiblematch.descriptor
                }
            }
        }
        return nil
    }
    
    static let stringRefLookup: [UInt: [(descriptor: PantosTag, string: MambaStringRef)]] = {
        
        let tagList = [PantosTag.EXTM3U,
                       PantosTag.EXT_X_VERSION,
                       PantosTag.EXT_X_MEDIA,
                       PantosTag.EXT_X_I_FRAME_STREAM_INF,
                       PantosTag.EXT_X_SESSION_DATA,
                       PantosTag.EXT_X_SESSION_KEY,
                       PantosTag.EXT_X_CONTENT_STEERING,
                       PantosTag.EXT_X_TARGETDURATION,
                       PantosTag.EXT_X_MEDIA_SEQUENCE,
                       PantosTag.EXT_X_ENDLIST,
                       PantosTag.EXT_X_PLAYLIST_TYPE,
                       PantosTag.EXT_X_I_FRAMES_ONLY,
                       PantosTag.EXT_X_ALLOW_CACHE,
                       PantosTag.EXTINF,
                       PantosTag.EXT_X_KEY,
                       PantosTag.EXT_X_MAP,
                       PantosTag.EXT_X_PROGRAM_DATE_TIME,
                       PantosTag.EXT_X_STREAM_INF,
                       PantosTag.EXT_X_BYTERANGE,
                       PantosTag.EXT_X_DISCONTINUITY_SEQUENCE,
                       PantosTag.EXT_X_INDEPENDENT_SEGMENTS,
                       PantosTag.EXT_X_START,
                       PantosTag.EXT_X_DISCONTINUITY,
                       PantosTag.EXT_X_BITRATE,
                       PantosTag.EXT_X_DATERANGE]

        var dictionary = [UInt: [(descriptor: PantosTag, string: MambaStringRef)]]()
        
        for tag in tagList {
            let string = MambaStringRef(string: "#\(tag.toString())")
            if let _ = dictionary[string.length] {
                dictionary[string.length]!.append((descriptor: tag, string: string))
            }
            else {
                var array = [MambaStringRef]()
                array.append(string)
                dictionary[string.length] = [(descriptor: tag, string: string)]
            }
        }
        
        return dictionary
    }()
}
