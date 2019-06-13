//
//  MasterPlaylistStreamSummary.swift
//  mamba
//
//  Created by David Coufal on 6/11/19.
//  Copyright © 2019 Comcast Corporation.
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

extension PlaylistCore where PT == MasterPlaylistType {
    
    /**
     Calculates a summary of all the independantly addressable (i.e. has a uri) streams in a given master HLS playlist.
     
     It's worth noting that this function captures the state of the playlist when it's called. The
     `PlaylistStreamSummary` object that is returned will not update if the master playlist is edited.
     
     This function is also not thread safe. Please esnure that no other threads are editing this master playlist
     while executing.
     
     - returns: A `Result` object with either a `PlaylistStreamSummary` for success or a `StreamSummaryError` for failure.
     */
    public func calculateStreamSummary() -> Result<PlaylistStreamSummary, StreamSummaryError> {
        
        var streams = [PlaylistStream]()
        var nonStreamMediaGroupInfo = [NonStreamMediaGroupInfo]()
        
        // parse iframe streams
        let iFrameStreamInfIndices = tags.indices.filter { tags[$0].tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF }
        for iFrameStreamInfIndex in iFrameStreamInfIndices {
            guard let mediaTag = tags[safe: iFrameStreamInfIndex] else {
                assertionFailure("It's odd that the index we just calculated for the iframestreaminf tag is no longer valid")
                return .failure(.internalIndexError)
            }
            guard let uri: String = mediaTag.value(forValueIdentifier: PantosValue.uri) else {
                return .failure(.invalidMasterPlaylistError(errorText: "URI is required for iFrameStreamInf tags"))
            }
            streams.append(.iFrameStream(iFrameStreamInfIndex: iFrameStreamInfIndex, uri: uri))
        }
        
        // parse the media streams
        let mediaIndices = tags.indices.filter { tags[$0].tagDescriptor == PantosTag.EXT_X_MEDIA }
        for mediaIndex in mediaIndices {
            guard let mediaTag = tags[safe: mediaIndex] else {
                assertionFailure("It's odd that the index we just calculated for the media tag is no longer valid")
                return .failure(.internalIndexError)
            }
            guard
                let type: MediaType = mediaTag.value(forValueIdentifier: PantosValue.type) else {
                    return .failure(.invalidMasterPlaylistError(errorText: "Type is required for media tags"))
            }
            guard type != .ClosedCaptions else {
                // not an error!
                continue
            }
            guard
                let groupId: String = mediaTag.value(forValueIdentifier: PantosValue.groupId),
                let name: String = mediaTag.value(forValueIdentifier: PantosValue.name) else {
                    return .failure(.invalidMasterPlaylistError(errorText: "GroupId and Name are required for media tags"))
            }
            guard let uri: String = mediaTag.value(forValueIdentifier: PantosValue.uri) else {
                // if we do not have a uri this is not a seperately available stream and we can skip it
                if type == .Video || type == .Audio {
                    // we still record it so we can avoid a potential lookup when we parse streaminf tags later
                    nonStreamMediaGroupInfo.append(NonStreamMediaGroupInfo(groupId: groupId,
                                                                           name: name,
                                                                           language: mediaTag.value(forValueIdentifier: PantosValue.language),
                                                                           type: type))
                }
                continue
            }
            switch type.type {
            case .Audio:
                streams.append(.audioMediaStream(mediaIndex: mediaIndex,
                                                 uri: uri,
                                                 groupId: groupId,
                                                 name: name,
                                                 language: mediaTag.value(forValueIdentifier: PantosValue.language),
                                                 associatedLanguage: mediaTag.value(forValueIdentifier: PantosValue.assocLanguage)))
            case .Video:
                streams.append(.videoMediaStream(mediaIndex: mediaIndex,
                                                 uri: uri,
                                                 groupId: groupId,
                                                 name: name,
                                                 language: mediaTag.value(forValueIdentifier: PantosValue.language),
                                                 associatedLanguage: mediaTag.value(forValueIdentifier: PantosValue.assocLanguage)))
            case .Subtitles:
                streams.append(.subtitlesMediaStream(mediaIndex: mediaIndex,
                                                     uri: uri,
                                                     groupId: groupId))
            default:
                break
            }
        }
        
        // parse the streamInf streams
        let streamInfIndices = tags.indices.filter { tags[$0].tagDescriptor == PantosTag.EXT_X_STREAM_INF }
        for streamInfIndex in streamInfIndices {
            guard let streamInfTag = tags[safe: streamInfIndex] else {
                assertionFailure("It's odd that the index we just calculated for the streaminf tag is no longer valid")
                return .failure(.internalIndexError)
            }
            let locationTagIndex = streamInfIndex + 1
            guard
                let locationTag = tags[safe: locationTagIndex],
                locationTag.tagDescriptor == PantosTag.Location else {
                    return .failure(.invalidMasterPlaylistError(errorText: "Location tags must immediately follow streamInf tags"))
            }
            guard let bandwidth: Int = streamInfTag.value(forValueIdentifier: PantosValue.bandwidthBPS) else {
                return .failure(.invalidMasterPlaylistError(errorText: "Bandwidth is required for streamInf tags"))
            }
            let uri = locationTag.tagData.stringValue()
            
            // make the complicated decision about if we are muxed or not
            let streamInfContainsAudio = containsMediaInfo(forStreamContents: .audio,
                                                           inStreamInfTag: streamInfTag,
                                                           withStreamInfLocationUrl: uri,
                                                           withStreams: streams,
                                                           withNonStreamMediaGroupInfo: nonStreamMediaGroupInfo)
            
            let streamInfContainsVideo = containsMediaInfo(forStreamContents: .video,
                                                           inStreamInfTag: streamInfTag,
                                                           withStreamInfLocationUrl: uri,
                                                           withStreams: streams,
                                                           withNonStreamMediaGroupInfo: nonStreamMediaGroupInfo)
            
            let streamType: StreamType
            switch (streamInfContainsAudio, streamInfContainsVideo) {
            case (true, true):
                streamType = .muxed
                break
            case (true, false):
                streamType = .demuxedAudio
                break
            case (false, true):
                streamType = .demuxedVideo
                break
            case (false, false):
                return .failure(.invalidMasterPlaylistError(errorText: "StreamInf tag was found to have neither audio nor video streams"))
            }
            
            streams.append(.stream(streamInfIndex: streamInfIndex,
                                   locationIndex: locationTagIndex,
                                   uri: uri,
                                   audioGroupId: streamInfTag.value(forValueIdentifier: PantosValue.audioGroup),
                                   videoGroupId: streamInfTag.value(forValueIdentifier: PantosValue.videoGroup),
                                   captionsGroupId: streamInfTag.value(forValueIdentifier: PantosValue.closedCaptionsGroup),
                                   streamType: streamType,
                                   bandwidth: bandwidth,
                                   resolution: streamInfTag.value(forValueIdentifier: PantosValue.resolution)))
        }
        
        return .success(PlaylistStreamSummary(streams: streams))
    }
}

/// An object that summarizes all the independantly addressable streams in a master playlist.
public struct PlaylistStreamSummary {
    
    /// An array of `PlaylistStream` enum values: one for each stream in the playlist.
    public let streams: [PlaylistStream]
    
    // An `OptionSet` summary of the muxed/demuxed status of the entire playlist.
    public let muxedStatus: PlaylistMuxedStatus
    
    fileprivate init(streams: [PlaylistStream]) {
        self.streams = streams
        var status = PlaylistMuxedStatus(rawValue: 0)
        for stream in streams {
            if let streamType = stream.streamType {
                switch streamType {
                case .muxed:
                    status.insert(.containsMuxedAudioVideo)
                case .demuxedVideo:
                    status.insert(.containsDemuxedVideo)
                case .demuxedAudio:
                    status.insert(.containsDemuxedAudio)
                }
            }
        }
        self.muxedStatus = status
    }
}

/**
 A description of all the possible individually addressable streams in a HLS asset.
 
 It's probably worth noting that closed captions is not present. As far as the HLS specification
 is concerned, closed captions are only delivered through the media segments. They cannot be
 seperate streams.
 */
public enum PlaylistStream {
    /**
     A stream found in a #EXT-X-STREAM-INF tag.
     
     # Enum associated values
     
     - `streamInfIndex`: An index into the `MasterPlaylist` tag array for the matching stream inf tag.
     - `locationIndex`: An index into the `MasterPlaylist` tag array for the matching location/uri tag.
     - `uri`: The uri of this stream.
     - `audioGroupId`: The group id reference for any external audio streams, if available.
     - `videoGroupId`: The group id reference for any external video streams, if available.
     - `captionsGroupId`: The group id reference for any external closed captions streams, if available.
     - `streamType`: The calculated `StreamType` for this stream.
     - `bandwidth`: The bandwidth for the stream.
     - `resolution`: The resolution for this stream if available.
     */
    case stream(streamInfIndex: Int, locationIndex: Int, uri: String, audioGroupId: String?, videoGroupId: String?, captionsGroupId: String?, streamType: StreamType, bandwidth: Int, resolution: ResolutionValueType?)
    /**
     An audio stream found in a #EXT-X-MEDIA tag.
     
     # Enum associated values
     
     - `mediaIndex`: An index into the `MasterPlaylist` tag array for the matching media tag.
     - `uri`: The uri of this stream.
     - `groupId`: The group id reference for this stream to match with a streamInf tag.
     - `name`: The name given to this stream.
     - `language`: The language of this stream.
     - `associatedLanguage`: The associated language for this stream (see the HLS/Pantos spec for details)
     */
    case audioMediaStream(mediaIndex: Int, uri: String, groupId: String, name: String, language: String?, associatedLanguage: String?)
    /**
     A video stream found in a #EXT-X-MEDIA tag.
     
     # Enum associated values
     
     - `mediaIndex`: An index into the `MasterPlaylist` tag array for the matching media tag.
     - `uri`: The uri of this stream.
     - `groupId`: The group id reference for this stream to match with a streamInf tag.
     - `name`: The name given to this stream.
     - `language`: The language of this stream.
     - `associatedLanguage`: The associated language for this stream (see the HLS/Pantos spec for details)
     */
    case videoMediaStream(mediaIndex: Int, uri: String, groupId: String, name: String, language: String?, associatedLanguage: String?)
    /**
     A subtitles stream found in a #EXT-X-MEDIA tag.
     
     # Enum associated values
     
     - `mediaIndex`: An index into the `MasterPlaylist` tag array for the matching media tag.
     - `uri`: The uri of this stream.
     - `groupId`: The group id reference for this stream to match with a streamInf tag.
     */
    case subtitlesMediaStream(mediaIndex: Int, uri: String, groupId: String)
    /**
     A stream found in a #EXT-X-I-FRAME-STREAM-INF tag.
     
     # Enum associated values
     
     - `iFrameStreamInfIndex`: An index into the `MasterPlaylist` tag array for the matching iFrameStreamInf tag.
     - `uri`: The uri of this stream.
     */
    case iFrameStream(iFrameStreamInfIndex: Int, uri: String)
}

public extension PlaylistStream {
    /// Returns the uri of the stream
    var uri: String {
        switch self {
        case .audioMediaStream(_, let uri, _, _, _, _):
            return uri
        case .videoMediaStream(_, let uri, _, _, _, _):
            return uri
        case .subtitlesMediaStream(_, let uri, _):
            return uri
        case .iFrameStream(_, let uri):
            return uri
        case .stream(_, _, let uri, _, _, _, _, _, _):
            return uri
        }
    }
    // returns the `StreamType` for this stream if applicable.
    var streamType: StreamType? {
        switch self {
        case .audioMediaStream(_):
            return .demuxedAudio
        case .videoMediaStream(_):
            return .demuxedVideo
        case .subtitlesMediaStream(_):
            return nil
        case .iFrameStream(_):
            return nil
        case .stream(_, _, _, _, _, _, let streamType, _, _):
            return streamType
        }
    }
}

/// A description of the type of stream for audio/video streams
public enum StreamType {
    /// Audio and Video are muxed together into one stream
    case muxed
    /// A standalone video stream
    case demuxedVideo
    /// A standalone audio stream
    case demuxedAudio
}

/// A summary of the muxed/demuxed audio/video content in a HLS asset
public struct PlaylistMuxedStatus: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Flag represents the presence of at least one muxed audio/video stream
    public static let containsMuxedAudioVideo   = PlaylistMuxedStatus(rawValue: 1 << 1)
    /// Flag represents the presence of at least one demuxed audio stream
    public static let containsDemuxedAudio      = PlaylistMuxedStatus(rawValue: 1 << 2)
    /// Flag represents the presence of at least one demuxed video stream
    public static let containsDemuxedVideo      = PlaylistMuxedStatus(rawValue: 1 << 3)
}

/// An `Error` enum describing possible errors in producing a summary of the streams in a playlist
public enum StreamSummaryError: Error {
    /// Unable to process the summary due to a problem with the master HLS. The problem is described in the `errorText`
    case invalidMasterPlaylistError(errorText: String)
    /// An internal indexing error was found. This probably means the master playlist was edited while the summary was being constructed.
    case internalIndexError
}

// MARK: Private objects and code

fileprivate extension PlaylistStream {
    func isAudioMediaStream(withMediaGroupId mediaGroupId: String) -> Bool {
        switch self {
        case .audioMediaStream(_, _, let groupId, _, _, _):
            return groupId == mediaGroupId
        default:
            return false
        }
    }
    func isVideoMediaStream(withMediaGroupId mediaGroupId: String) -> Bool {
        switch self {
        case .videoMediaStream(_, _, let groupId, _, _, _):
            return groupId == mediaGroupId
        default:
            return false
        }
    }
}

fileprivate struct NonStreamMediaGroupInfo {
    let groupId: String
    let name: String
    let language: String?
    let type: MediaType
}

extension Collection where Iterator.Element == NonStreamMediaGroupInfo {
    fileprivate func getNonStreams(matchingStreamContentsQuery streamContentsQuery: StreamContentsQuery,
                                   withMediaGroupId mediaGroupId: String) -> [NonStreamMediaGroupInfo] {
        switch streamContentsQuery {
        case .audio:
            return self.filter { $0.type == .Audio && $0.groupId == mediaGroupId }
        case .video:
            return self.filter { $0.type == .Video && $0.groupId == mediaGroupId }
        }
    }
}

extension Collection where Iterator.Element == PlaylistStream {
    fileprivate func getStreams(matchingStreamContentsQuery streamContentsQuery: StreamContentsQuery,
                                withMediaGroupId mediaGroupId: String) -> [PlaylistStream] {
        switch streamContentsQuery {
        case .audio:
            return self.filter { $0.isAudioMediaStream(withMediaGroupId: mediaGroupId) }
        case .video:
            return self.filter { $0.isVideoMediaStream(withMediaGroupId: mediaGroupId) }
        }
    }
}

fileprivate func containsMediaInfo(forStreamContents streamContentsQuery: StreamContentsQuery,
                                   inStreamInfTag streamInfTag: PlaylistTag,
                                   withStreamInfLocationUrl streamInfUrl: String,
                                   withStreams streams: [PlaylistStream],
                                   withNonStreamMediaGroupInfo nonStreamMediaGroupInfo: [NonStreamMediaGroupInfo]) -> Bool {
    
    let mediaValueIdentifier: PantosValue
    
    switch streamContentsQuery {
    case .audio:
        mediaValueIdentifier = PantosValue.audioGroup
    case .video:
        mediaValueIdentifier = PantosValue.videoGroup
    }
    
    if let mediaGroupId: String = streamInfTag.value(forValueIdentifier: mediaValueIdentifier) {
        let mediaStreamsForGroup = streams.getStreams(matchingStreamContentsQuery: streamContentsQuery,
                                                      withMediaGroupId: mediaGroupId)
        let nonMediaStreamsForGroup = nonStreamMediaGroupInfo.getNonStreams(matchingStreamContentsQuery: streamContentsQuery,
                                                                            withMediaGroupId: mediaGroupId)
        if mediaStreamsForGroup.isEmpty {
            // we have no media streams.
            // let's check the codecs to be certain
            return containsMediaInfoFallbackToCodecs(forStreamContents: streamContentsQuery, inStreamInfTag: streamInfTag)
        }
        else if !nonMediaStreamsForGroup.isEmpty {
            // we have some media streams, but we also have some MEDIA tags with no media streams, so we must contain media
            return true
        }
        else {
            // There is an odd use case to handle here.
            // Let's say we have a fully demuxed audio/video HLS asset, AND we want to deliver a very low bandwidth
            // audio-only rendition. (i.e. the same audio we are using for our higher bandwidth video+audio streams)
            // How do we express this?
            // It turns out that it's playable HLS to have *the same stream* in a #EXT-X-STREAMINF tag and a #EXT-X-MEDIA
            // tag. (playable by AVFoundation at least ... the spec is not clear on this subject).
            // We check for that situation here.
            
            for mediaStream in mediaStreamsForGroup {
                if mediaStream.uri == streamInfUrl {
                    // This EXT-X-STREAMINF tag stream contains media that matches with a media stream. We must contain that media type.
                    return true
                }
            }
            
            // all other cases: our streamInf media stream has no media of the type we are looking for
            return false
        }
    }
    
    // we'd get here if we did not have a media group id
    // let's check the codecs to be certain
    return containsMediaInfoFallbackToCodecs(forStreamContents: streamContentsQuery, inStreamInfTag: streamInfTag)
}

fileprivate func containsMediaInfoFallbackToCodecs(forStreamContents streamContentsQuery: StreamContentsQuery,
                                                   inStreamInfTag streamInfTag: PlaylistTag) -> Bool {
    if let codecs: CodecValueTypeArray = streamInfTag.codecs() {
        switch streamContentsQuery {
        case .audio:
            return codecs.containsAudio()
        case .video:
            return codecs.containsVideo()
        }
    }
    
    // without codecs data, we assume we do contain this media type...
    return true
}

fileprivate enum StreamContentsQuery {
    case video
    case audio
}

