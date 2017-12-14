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

/// If a media sequence is not defined for a manifest, this is the default media sequence number that is implied.
public let defaultMediaSequence = 0

/// enum describing possible types of values can can be associated with a tag
public enum PantosValue: String {
    
    /// Found in `.Comment`. The text of a comment.
    case Comment_Text = "Comment_Text"
    
    /// Found in `.UnknownTag`. The name of the tag.
    case UnknownTag_Name = "UnknownTag_Name"
    
    /// Found in `.UnknownTag`. The data of the tag.
    case UnknownTag_Value = "UnknownTag_Value"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. A bandwidth value in bits per second.
    case bandwidthBPS = "BANDWIDTH"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. The program id of the stream.
    case programId = "PROGRAM-ID"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Match a tag with a corresponding audio stream.
    case audioGroup = "AUDIO"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Match a tag with a corresponding video stream.
    case videoGroup = "VIDEO"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Comma delimited list of formats supported in the media file.
    case codecs = "CODECS"
    
    /// Found in `.EXT_X_STREAM_INF` and `.EXT_X_I_FRAME_STREAM_INF`. Horizonal by vertical pixel resolution of the media file, i.e. 1280x720
    case resolution = "RESOLUTION"
    
    /// Found in `.EXT_X_STREAM_INF`. Match a tag with a corresponding subtitles stream.
    case subtitlesGroup = "SUBTITLES"
    
    /// Found in `.EXT_X_STREAM_INF`. Match a tag with a corresponding closed-caption stream.
    case closedCaptionsGroup = "CLOSED-CAPTIONS"
    
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
    
    /// Found in `.EXT_X_MEDIA`. The primary language of the media
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
    
    /// Found in `.EXT_X_MEDIA`, `.EXT_X_KEY`, `.EXT_X_MAP` and `.EXT_X_I_FRAME_STREAM_INF`. The URI location of the media
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
    
}

extension PantosValue: HLSTagValueIdentifier {
    public func toString() -> String {
        return self.rawValue
    }
}

