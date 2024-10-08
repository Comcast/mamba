//
//  PantosValue.swift
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

/// If a media sequence is not defined for a playlist, this is the default media sequence number that is implied.
public let defaultMediaSequence = 0

/// enum describing possible types of values can can be associated with a tag
public enum PantosValue: String {
    
    /// Found in `.Comment`. The text of a comment.
    case Comment_Text = "Comment_Text"
    
    /// Found in `.UnknownTag`. The name of the tag.
    case UnknownTag_Name = "UnknownTag_Name"
    
    /// Found in `.UnknownTag`. The data of the tag.
    case UnknownTag_Value = "UnknownTag_Value"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. A peak bandwidth value in bits per second.
    case bandwidthBPS = "BANDWIDTH"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. An average bandwidth value in bits per second.
    case averageBandwidthBPS = "AVERAGE-BANDWIDTH"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. An abstract, relative measure of the playback quality-of-experience of the variant stream.
    case score = "SCORE"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. The program id of the stream.
    case programId = "PROGRAM-ID"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Match a tag with a corresponding audio stream.
    case audioGroup = "AUDIO"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Match a tag with a corresponding video stream.
    case videoGroup = "VIDEO"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Comma delimited list of formats supported in the media file.
    case codecs = "CODECS"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Comma delimited list of formats supported in the enhancement layer in the media file.
    case supplementalCodecs = "SUPPLEMENTAL-CODECS"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Horizonal by vertical pixel resolution of the media file, i.e. 1280x720
    case resolution = "RESOLUTION"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Advisory information on the minimum HDCP level
    /// required by the output protection level of the license that will be provided to decrypt this media content.
    case hdcpLevel = "HDCP-LEVEL"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Advisory information on the minimum robustness
    /// level required by the output protection level of the license that will be provided to decrypt this media content.
    case allowedCpc = "ALLOWED-CPC"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Reference opto-electronic transfer characteristic function used in the encoding of the media file.
    case videoRange = "VIDEO-RANGE"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Indication of any specialized rendering needed to properly display the video content of the media file.
    case reqVideoLayout = "REQ-VIDEO-LAYOUT"

    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Allows the URI (defined in next Location line or the URI attribute) to change between two reloads of the playlist.
    case stableVariantId = "STABLE-VARIANT-ID"

    /// Found in `.EXT_X_STREAM_INF`. Maximum frame rate for all video in the variant stream (rounded to 3 decimal places).
    case frameRate = "FRAME-RATE"

    /// Found in `.EXT_X_STREAM_INF`. Match a tag with a corresponding subtitles stream.
    case subtitlesGroup = "SUBTITLES"
    
    /// Found in `.EXT_X_STREAM_INF`. Match a tag with a corresponding closed-caption stream.
    case closedCaptionsGroup = "CLOSED-CAPTIONS"

    /// Found in `.EXT_X_SESSION_DATA`. Identifier for a particular data value.
    case dataId = "DATA-ID"

    /// Found in `.EXT_X_SESSION_DATA`. The value of the data identified via DATA-ID.
    case value = "VALUE"

    /// Found in `.EXT_X_SESSION_DATA`. The format of the data provided via VALUE.
    case format = "FORMAT"

    /// Found in `.EXT_X_CONTENT_STEERING`. The URI location for the steering manifest.
    case serverUri = "SERVER-URI"

    /// Found in `.EXT_X_STREAM_INF`, `.EXT_X_I_FRAME_STREAM_INF` and `.EXT_X_CONTENT_STEERING`. When found in
    /// `.EXT_X_CONTENT_STEERING` it represents the initial pathway to choose until the first steering manifest is
    /// obtained. When found in `.EXT_X_STREAM_INF` or `.EXT_X_I_FRAME_STREAM_INF` it represents the Content Steering
    /// Pathway that the variant stream belongs to.
    case pathwayId = "PATHWAY-ID"

    /// Found in `.EXT_X_TARGETDURATION`. A target duration in seconds.
    case targetDurationSeconds = "targetDurationSeconds"
    
    /// Found in `.EXT_X_MEDIA_SEQUENCE`. The sequence id of the first URI in the playlist.
    case sequence = "sequence"
    
    /// Found in `.EXT-X-ALLOW-CACHE`. Indicates whether the client MAY or MUST NOT cache downloaded media segments (YES or NO)
    case allowCache = "allowCache"
    
    /// Found in `.EXT_X_PROGRAM_DATE_TIME`. The date/time representation is ISO_8601 and SHOULD indicate a time zone
    case programDateTime = "programDateTIme"
    
    /// Found in `.EXT_X_MEDIA`. The type of the media (AUDIO, VIDEO, SUBTITLES and CLOSED-CAPTIONS are the choices)
    case type = "TYPE"
    
    /// Found in `.EXT_X_MEDIA`. Group id of this media stream
    case groupId = "GROUP-ID"
    
    /// Found in `.EXT_X_MEDIA`. Name of this media (typically a human-readable version of the language)
    case name = "NAME"
    
    /// Found in `.EXT_X_MEDIA` and `.EXT_X_SESSION_DATA`. The primary language of the media
    case language = "LANGUAGE"
    
    /// Found in `.EXT_X_MEDIA`. The associated language of the media
    case assocLanguage = "ASSOC-LANGUAGE"
    
    /// Found in `.EXT_X_MEDIA`. Is this media the default track? (YES or NO)
    case defaultMedia = "DEFAULT"
    
    /// Found in `.EXT_X_MEDIA`. Should we autoselect this track (YES or NO)
    case autoselect = "AUTOSELECT"
    
    /// Found in `.EXT_X_MEDIA`. Subtitle forced rendition condition (YES or NO)
    case forced = "FORCED"
    
    /// Found in `.EXT_X_MEDIA`. Indicates an individual characteristic of the subtitles rendition
    case characteristics = "CHARACTERISTICS"
    
    /// Found in `.EXT_X_MEDIA`. This attribute is REQUIRED if the TYPE attribute is CLOSED-CAPTIONS ("CC1", "CC2", "CC3", "CC4")
    case instreamId = "INSTREAM-ID"

    /// Found in `.EXT_X_MEDIA`. Allows the URI to change between two reloads of the playlist.
    case stableRenditionId = "STABLE-RENDITION-ID"

    /// Found in `.EXT_X_MEDIA`. Specifies the audio bit depth of the rendition.
    case bitDepth = "BIT-DEPTH"

    /// Found in `.EXT_X_MEDIA`. Specifies the audio sample rate of the rendition.
    case sampleRate = "SAMPLE-RATE"

    /// Found in `.EXT_X_MEDIA`. Provides information about audio channels, such as count, spatial audio coding, and other special channel usage instructions.
    case channels = "CHANNELS"

    /// Found in `.EXT_X_MEDIA`, `.EXT_X_KEY`, `.EXT_X_MAP`, `.EXT_X_I_FRAME_STREAM_INF` and `.EXT_X_SESSION_DATA`. The URI location of the media
    case uri = "URI"
    
    /// Found in `.EXT_X_KEY`. The encryption method
    case method = "METHOD"
    
    /// Found in `.EXT_X_KEY`. Initialization Vector to be used with the key
    case ivector = "IV"
    
    /// Found in `.EXT_X_KEY`. Specifies how the key is represented in the resource identified by the URI
    case keyformat = "KEYFORMAT"
    
    /// Found in `.EXT_X_KEY`. Indicate which version(s) this instance complies with
    case keyformatVersions = "KEYFORMATVERSIONS"
    
    /// Found in `.EXT_X_VERSION`. The compatibility version of the Playlist file
    case version = "VERSION"
    
    /// Found in `.EXT_X_PLAYLIST_TYPE`. Mutability information about the Media Playlist file (EVENT or VOD)
    case playlistType = "PLAYLIST-TYPE"
    
    /// Found in `.EXT_X_BYTERANGE` and `.EXT_X_MAP`. Indicates that a Media Segment is a sub-range of the resource identified by its URI
    case byterange = "BYTERANGE"
    
    /// Found in `.EXT_X_DISCONTINUITY_SEQUENCE`. The discontinuity sequence number
    case discontinuitySequence = "DISCONTINUITYSEQUENCE"
    
    /// Found in `.EXT_X_START`. Indicates a time offset from the beginning or from the end of the last segment in the Playlist
    case startTimeOffset = "TIME-OFFSET"
    
    /// Found in `.EXT_X_START`. Indicates client SHOULD NOT render media samples in that segment whose presentation times are prior to the TIME-OFFSET (YES or NO)
    case precise = "PRECISE"
    
    /// Found in `.EXT_X_DATERANGE`.
    /// A quoted-string that uniquely identifies a Date Range in the
    /// Playlist.  This attribute is REQUIRED
    case id = "ID"
    
    /// Found in `.EXT_X_DATERANGE`.
    /// A client-defined quoted-string that specifies some set of
    /// attributes and their associated value semantics.  All Date Ranges
    /// with the same CLASS attribute value MUST adhere to these
    /// semantics.  This attribute is OPTIONAL.
    case classAttribute = "CLASS"

    /// Found in `.EXT_X_DATERANGE`.
    /// A quoted-string containing the [ISO_8601] date/time at which the
    /// Date Range begins.  This attribute is REQUIRED.
    case startDate = "START-DATE"

    /// Found in `.EXT_X_DATERANGE`.
    /// A quoted-string containing the [ISO_8601] date/time at which the
    /// Date Range ends.  It MUST be equal to or later than the value of
    /// the START-DATE attribute.  This attribute is OPTIONAL.
    case endDate = "END-DATE"

    /// Found in `.EXT_X_DATERANGE`.
    /// The duration of the Date Range expressed as a decimal-floating-
    /// point number of seconds.  It MUST NOT be negative.  A single
    /// instant in time (e.g., crossing a finish line) SHOULD be
    /// represented with a duration of 0.  This attribute is OPTIONAL.
    case duration = "DURATION"

    /// Found in `.EXT_X_DATERANGE`.
    /// The expected duration of the Date Range expressed as a decimal-
    /// floating-point number of seconds.  It MUST NOT be negative.  This
    /// attribute SHOULD be used to indicate the expected duration of a
    /// Date Range whose actual duration is not yet known.  It is
    /// OPTIONAL.
    case plannedDuration = "PLANNED-DURATION"

    /// Found in `.EXT_X_DATERANGE`.
    /// Used to carry SCTE-35 data.  These attributes are OPTIONAL.
    case scte35Cmd = "SCTE35-CMD"
    /// Found in `.EXT_X_DATERANGE`.
    /// Used to carry SCTE-35 data.  These attributes are OPTIONAL.
    case scte35Out = "SCTE35-OUT"
    /// Found in `.EXT_X_DATERANGE`.
    /// Used to carry SCTE-35 data.  These attributes are OPTIONAL.
    case scte35In = "SCTE35-IN"

    /// Found in `.EXT_X_DATERANGE`.
    /// An enumerated-string whose value MUST be YES.  This attribute
    /// indicates that the end of the range containing it is equal to the
    /// START-DATE of its Following Range.  The Following Range is the
    /// Date Range of the same CLASS that has the earliest START-DATE
    /// after the START-DATE of the range in question.  This attribute is
    /// OPTIONAL.
    case endOnNext = "END-ON-NEXT"

    /// Found in `.EXT_X_SKIP`.
    ///
    /// The value is a decimal-integer specifying the number of Media
    /// Segments replaced by the EXT-X-SKIP tag.  This attribute is
    /// REQUIRED.
    case skippedSegments = "SKIPPED-SEGMENTS"

    /// Found in `.EXT_X_SKIP`.
    ///
    /// The value is a quoted-string consisting of a tab (0x9) delimited
    /// list of EXT-X-DATERANGE IDs that have been removed from the
    /// Playlist recently.  See Section 6.2.5.1 for more information.
    /// This attribute is REQUIRED if the Client requested an update that
    /// skips EXT-X-DATERANGE tags.  The quoted-string MAY be empty.
    case recentlyRemovedDateranges = "RECENTLY-REMOVED-DATERANGES"
}

extension PantosValue: PlaylistTagValueIdentifier {
    public func toString() -> String {
        return self.rawValue
    }
}

