//
//  GenericDictionaryTagValidatorTests.swift
//  mamba
//
//  Created by Philip McMahon on 9/12/16.
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

import XCTest

@testable import mamba

class GenericDictionaryTagValidatorTests: XCTestCase {

    struct Bad {
        static let Value = "BAD"
    }
    
    func validInput(tag: PantosTag, tagData: String) {

        let (validator, tag) = constructDictionaryValidator(tag, data: tagData)
        guard let errors = validator.validate(tag: tag) else {
            return
        }
        
        XCTAssert(false, "Did not expect validation errors \(errors)")
    }

    func missingOrBadKey(tag: PantosTag, tagData: String, key: String) {
        
        let (validator, tag) = constructDictionaryValidator(tag, data: tagData)
        guard let errors = validator.validate(tag: tag) else {
            XCTAssert(false, "Expected error for key \(key)")
            return
        }
        
        XCTAssertEqual(errors.count, 1)
    }

    func emptyInput(tag: PantosTag, numberOfErrors: Int) {

        let tagData = ""
        let (validator, tagImpl) = constructDictionaryValidator(tag, data: tagData)
        let count = validator.validate(tag: tagImpl)?.count ?? 0
        XCTAssertEqual(count, numberOfErrors, "Incorrect number of errors")
    }

    func parse(tagData: String, tag: PantosTag) -> PlaylistTagDictionary {
        
        return try! PantosTag.parser(forTag:tag)!.parseTag(fromTagString: tagData)
    }
    
    func write(dictionary: PlaylistTagDictionary, tag: PantosTag) -> String {
        let tagImpl = PlaylistTag(tagDescriptor: tag, stringTagData: "", parsedValues: dictionary)
                
        let stream = OutputStream.toMemory()
        stream.open()
        do {
            try GenericDictionaryTagWriter().write(tag: tagImpl, toStream: stream)
        }
        catch {
            XCTFail("Failed to write dictionary \(error)")
            return "FAILED_TO_WRITE_DATA"
        }
        guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            XCTFail("No data written in write in unit test \"\(String(describing: type(of: self)))\" with tag \"\(tagImpl)\"")
            return "FAILED_TO_WRITE_DATA"
        }
        let string = String(data: data, encoding: .utf8)!
        stream.close()
        return string.replacingOccurrences(of: "#\(tag.rawValue):", with: "")
    }
    
    func removeKey(tagData: String, key: String, tag: PantosTag) -> String {
    
        var dictionary = parse(tagData: tagData, tag: tag)
        dictionary.removeValue(forKey: key)
        return write(dictionary: dictionary, tag: tag)
    }
    
    func replaceKey(tagData: String, key: String, value: String, tag: PantosTag) -> String {
        
        var dictionary = parse(tagData: tagData, tag: tag)
        dictionary[key] = PlaylistTagValueData(value: value)
        return write(dictionary: dictionary, tag: tag)
    }
    
    func missingOptionalKeys(tag: PantosTag, tagData: String, removed: [PantosValue]) {
        
        for key in removed {
            
            let data = removeKey(tagData: tagData, key: key.rawValue, tag: tag)
            validInput(tag: tag, tagData: data)
        }
    }
    
    func missingMandatoryKeys(tag: PantosTag, tagData: String, removed: [PantosValue]) {
        
        for key in removed {
            
            let data = removeKey(tagData: tagData, key: key.rawValue, tag: tag)
            missingOrBadKey(tag: tag, tagData: data, key: key.rawValue)
        }
    }
    
    func wrongType(tag: PantosTag, tagData: String, badValues: [PantosValue]) {
        
        for key in badValues {
            
            let data = replaceKey(tagData: tagData, key: key.rawValue, value: Bad.Value, tag: tag)
            missingOrBadKey(tag: tag, tagData: data, key: key.rawValue)
        }
    }
    
    func constructDictionaryValidator(_ tag: PlaylistTagDescriptor, data: String) -> (PlaylistTagValidator, PlaylistTag) {
        
        let tagImpl = createTag(tagDescriptor: tag, tagData: data)
         
        return (PantosTag.validator(forTag:tag)!, tagImpl)
    }
    
    func validate(tag: PantosTag, tagData: String, optional: [PantosValue], mandatory: [PantosValue], badValues: [PantosValue]) {
        validInput(tag: tag, tagData: tagData)
        emptyInput(tag: tag, numberOfErrors: mandatory.count)
        missingOptionalKeys(tag: tag, tagData: tagData, removed: optional)
        missingMandatoryKeys(tag: tag, tagData: tagData, removed: mandatory)
        wrongType(tag: tag, tagData: tagData, badValues: badValues)
    }
    
    /*
     #EXT-X-MEDIA:<attribute-list>
     
     The following attributes are defined:
     
     TYPE

     The value is an enumerated-string; valid strings are AUDIO, VIDEO,
     SUBTITLES, and CLOSED-CAPTIONS.  This attribute is REQUIRED.

     Typically, closed-caption [CEA608] media is carried in the video
     stream.  Therefore, an EXT-X-MEDIA tag with TYPE of CLOSED-
     CAPTIONS does not specify a Rendition; the closed-caption media is
     present in the Media Segments of every video Rendition.

     URI

     The value is a quoted-string containing a URI that identifies the
     Media Playlist file.  This attribute is OPTIONAL; see
     Section 4.4.6.2.1.  If the TYPE is CLOSED-CAPTIONS, the URI
     attribute MUST NOT be present.

     GROUP-ID

     The value is a quoted-string that specifies the group to which the
     Rendition belongs.  See Section 4.4.6.1.1.  This attribute is
     REQUIRED.

     LANGUAGE

     The value is a quoted-string containing one of the standard Tags
     for Identifying Languages [RFC5646], which identifies the primary
     language used in the Rendition.  This attribute is OPTIONAL.

     ASSOC-LANGUAGE

     The value is a quoted-string containing a language tag [RFC5646]
     that identifies a language that is associated with the Rendition.
     An associated language is often used in a different role than the
     language specified by the LANGUAGE attribute (e.g., written versus
     spoken, or a fallback dialect).  This attribute is OPTIONAL.

     NAME

     The value is a quoted-string containing a human-readable
     description of the Rendition.  If the LANGUAGE attribute is
     present, then this description SHOULD be in that language.  See
     Appendix E for more information.  This attribute is REQUIRED.

     STABLE-RENDITION-ID

     The value is a quoted-string which is a stable identifier for the
     URI within the Multivariant Playlist.  All characters in the
     quoted-string MUST be from the following set: [a..z], [A..Z],
     [0..9], '+', '/', '=', '.', '-', and '_'.  This attribute is
     OPTIONAL.

     The STABLE-RENDITION-ID allows the URI of a Rendition to change
     between two distinct downloads of the Multivariant Playlist.  IDs
     are matched using a byte-for-byte comparison.

     All EXT-X-MEDIA tags in a Multivariant Playlist with the same URI
     value SHOULD use the same STABLE-RENDITION-ID.

     DEFAULT

     The value is an enumerated-string; valid strings are YES and NO.
     If the value is YES, then the client SHOULD play this Rendition of
     the content in the absence of information from the user indicating
     a different choice.  This attribute is OPTIONAL.  Its absence
     indicates an implicit value of NO.

     AUTOSELECT

     The value is an enumerated-string; valid strings are YES and NO.
     This attribute is OPTIONAL.  Its absence indicates an implicit
     value of NO.  If the value is YES, then the client MAY choose to
     play this Rendition in the absence of explicit user preference
     because it matches the current playback environment, such as
     chosen system language.

     If the AUTOSELECT attribute is present, its value MUST be YES if
     the value of the DEFAULT attribute is YES.

     FORCED

     The value is an enumerated-string; valid strings are YES and NO.
     This attribute is OPTIONAL.  Its absence indicates an implicit
     value of NO.  The FORCED attribute MUST NOT be present unless the
     TYPE is SUBTITLES.

     A value of YES indicates that the Rendition contains content that
     is considered essential to play.  When selecting a FORCED
     Rendition, a client SHOULD choose the one that best matches the
     current playback environment (e.g., language).

     A value of NO indicates that the Rendition contains content that
     is intended to be played in response to explicit user request.

     INSTREAM-ID

     The value is a quoted-string that specifies a Rendition within the
     segments in the Media Playlist.  This attribute is REQUIRED if the
     TYPE attribute is CLOSED-CAPTIONS, in which case it MUST have one
     of the values: "CC1", "CC2", "CC3", "CC4", or "SERVICEn" where n
     MUST be an integer between 1 and 63 (e.g., "SERVICE9" or
     "SERVICE42").

     The values "CC1", "CC2", "CC3", and "CC4" identify a Line 21 Data
     Services channel [CEA608].  The "SERVICE" values identify a
     Digital Television Closed Captioning [CEA708] service block
     number.

     For all other TYPE values, the INSTREAM-ID MUST NOT be specified.

     BIT-DEPTH

     The value is a non-negative decimal-integer specifying the audio
     bit depth of the Rendition.  This attribute is OPTIONAL.  The
     attribute allows players to identify Renditions that have a bit
     depth appropriate to the available hardware.  The BIT-DEPTH
     attribute MUST NOT be present unless the TYPE is AUDIO.

     SAMPLE-RATE

     The value is a non-negative decimal-integer specifying the audio
     sample rate of the Rendition.  This attribute is OPTIONAL.  The
     attribute allows players to identify Renditions that may be played
     without sample rate conversion.  This is useful for lossless
     encodings.  The SAMPLE-RATE attribute MUST NOT be present unless
     the TYPE is AUDIO.

     CHARACTERISTICS

     The value is a quoted-string containing one or more Media
     Characteristic Tags (MCTs) separated by comma (,) characters.  A
     Media Characteristic Tag has the same format as the payload of a
     media characteristic tag atom [MCT].  This attribute is OPTIONAL.
     Each MCT indicates an individual characteristic of the Rendition.

     A SUBTITLES Rendition MAY include the following characteristics:
     "public.accessibility.transcribes-spoken-dialog",
     "public.accessibility.describes-music-and-sound", and
     "public.easy-to-read" (which indicates that the subtitles have
     been edited for ease of reading).

     An AUDIO Rendition MAY include the following characteristic:
     "public.accessibility.describes-video".

     The CHARACTERISTICS attribute MAY include private MCTs.

     CHANNELS

     The value is a quoted-string that specifies an ordered, slash-
     separated ("/") list of parameters.

     The CHANNELS attribute MUST NOT be present unless the TYPE is
     AUDIO.  The first parameter is a decimal-integer.  Each succeeding
     parameter is a comma-separated list of Identifiers.  An Identifier
     is a string containing characters from the set [A..Z], [0..9], and
     '-'.

     The first parameter is a count of audio channels expressed as a
     decimal-integer, indicating the maximum number of independent,
     simultaneous audio channels present in any Media Segment in the
     Rendition.  For example, an AC-3 5.1 Rendition would have a
     CHANNELS="6" attribute.

     The second parameter identifies the presence of spatial audio of
     some kind, for example, object-based audio, in the Rendition.
     This parameter is a comma-separated list of Audio Coding
     Identifiers.  This parameter is optional.  The Audio Coding
     Identifiers are codec-specific.  A parameter value of consisting
     solely of the dash character (0x2D) indicates that the audio is
     only channel-based.

     The third parameter contains supplementary indications of special
     channel usage that are necessary for informed selection and
     processing.  This parameter is a comma-separated list of Special
     Usage Identifiers.  This parameter is optional, however if it is
     present the second parameter must be non-empty.  The following
     Special Usage Identifiers can be present in the third parameter:

     BINAURAL  The audio is binaural (either recorded or synthesized).
        It SHOULD NOT be dynamically spatialized.  It is best suited
        for delivery to headphones.

     IMMERSIVE  The audio is pre-processed content that SHOULD NOT be
        dynamically spatialized.  It is suitable to deliver to either
        headphones or speakers.

     DOWNMIX  The audio is a downmix derivative of some other audio.
        If desired, the downmix may be used as a subtitute for
        alternative Renditions in the same group with compatible
        attributes and a greater channel count.  It MAY be dynamically
        spatialized.

     Audio without a Special Usage Identifier MAY be dynamically
     spatialized.

     No other CHANNELS parameters are currently defined.

     All audio EXT-X-MEDIA tags SHOULD have a CHANNELS attribute.  If a
     Multivariant Playlist contains two Renditions with the same NAME
     encoded with the same codec but a different number of channels,
     then the CHANNELS attribute is REQUIRED; otherwise, it is
     OPTIONAL.
     */
    
     func test_EXT_X_MEDIA() {
     
        var tagData = "TYPE=AUDIO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-audio-bandwidth-104000-repid-104000.m3u8\",DEFAULT=YES,AUTOSELECT=YES"
        let optional: [PantosValue] = [.audioGroup,
                                       .type,
                                       .groupId,
                                       .name,
                                       .stableRenditionId,
                                       .language,
                                       .assocLanguage,
                                       .uri,
                                       .defaultMedia,
                                       .autoselect,
                                       .forced,
                                       .instreamId,
                                       .bitDepth,
                                       .sampleRate,
                                       .characteristics,
                                       .channels]
        let mandatory: [PantosValue] = []
        let badValues: [PantosValue] = [.type,
                                        .defaultMedia,
                                        .autoselect,
                                        .forced,
                                        .instreamId,
                                        .bitDepth,
                                        .sampleRate,
                                        .channels]

        validate(tag: PantosTag.EXT_X_MEDIA,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
        
        // validate type = 'subtitles'
        tagData = "#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"subs\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE=\"en\",CHARACTERISTICS=\"public.accessibility.transcribes-spoken-dialog, public.accessibility.describes-music-and-sound\",URI=\"subtitles/eng/prog_index.m3u8\""
        validate(tag: PantosTag.EXT_X_MEDIA,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
        
        // validate type = 'closed-captions'
        tagData = "#EXT-X-MEDIA:TYPE=CLOSED-CAPTIONS,GROUP-ID=\"cc1\",LANGUAGE=\"en\",NAME=\"English\",AUTOSELECT=YES,DEFAULT=YES,INSTREAM-ID=\"CC1\""
        validate(tag: PantosTag.EXT_X_MEDIA,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
    }

    /*
     #EXT-X-STREAM-INF:<attribute-list>
     <URI>

     The following attributes are defined:

     BANDWIDTH

     The value is a decimal-integer of bits per second.  It represents
     the peak segment bit rate of the Variant Stream.

     If all the Media Segments in a Variant Stream have already been
     created, the BANDWIDTH value MUST be the largest sum of peak
     segment bit rates that is produced by any playable combination of
     Renditions.  (For a Variant Stream with a single Media Playlist,
     this is just the peak segment bit rate of that Media Playlist.)
     An inaccurate value can cause playback stalls or prevent clients
     from playing the variant.

     If the Multivariant Playlist is to be made available before all
     Media Segments in the presentation have been encoded, the
     BANDWIDTH value SHOULD be the BANDWIDTH value of a representative
     period of similar content, encoded using the same settings.

     Every EXT-X-STREAM-INF tag MUST include the BANDWIDTH attribute.

     AVERAGE-BANDWIDTH

     The value is a decimal-integer of bits per second.  It represents
     the average segment bit rate of the Variant Stream.

     If all the Media Segments in a Variant Stream have already been
     created, the AVERAGE-BANDWIDTH value MUST be the largest sum of
     average segment bit rates that is produced by any playable
     combination of Renditions.  (For a Variant Stream with a single
     Media Playlist, this is just the average segment bit rate of that
     Media Playlist.)  An inaccurate value can cause playback stalls or
     prevent clients from playing the variant.

     If the Multivariant Playlist is to be made available before all
     Media Segments in the presentation have been encoded, the AVERAGE-
     BANDWIDTH value SHOULD be the AVERAGE-BANDWIDTH value of a
     representative period of similar content, encoded using the same
     settings.

     The AVERAGE-BANDWIDTH attribute is OPTIONAL.

     SCORE

     The value is a positive decimal-floating-point number.  It is an
     abstract, relative measure of the playback quality-of-experience
     of the Variant Stream.

     The value can be based on any metric or combination of metrics
     that can be consistently applied to all Variant Streams.  The
     value SHOULD consider all media in the Variant Stream, including
     video, audio and subtitles.  A Variant Stream with a SCORE
     attribute MUST be considered by the Playlist author to be more
     desirable than any Variant Stream with a lower SCORE attribute in
     the same Multivariant Playlist.

     The SCORE attribute is OPTIONAL, but if any Variant Stream
     contains the SCORE attribute, then all Variant Streams in the
     Multivariant Playlist SHOULD have a SCORE attribute.  See
     Section 6.3.1 for more information.

     CODECS

     The value is a quoted-string containing a comma-separated list of
     formats, where each format specifies a media sample type that is
     present in one or more Renditions specified by the Variant Stream.
     Valid format identifiers are those in the ISO Base Media File
     Format Name Space defined by "The 'Codecs' and 'Profiles'
     Parameters for "Bucket" Media Types" [RFC6381].

     For example, a stream containing AAC low complexity (AAC-LC) audio
     and H.264 Main Profile Level 3.0 video would have a CODECS value
     of "mp4a.40.2,avc1.4d401e".

     Note that if a Variant Stream specifies one or more Renditions
     that include IMSC subtitles, the CODECS attribute MUST indicate
     this with a format identifier such as "stpp.ttml.im1t".

     Every EXT-X-STREAM-INF tag SHOULD include a CODECS attribute.

     SUPPLEMENTAL-CODECS

     The SUPPLEMENTAL-CODECS attribute describes media samples with
     both a backward-compatible base layer and a newer enhancement
     layer.  The base layers are specified in the CODECS attribute and
     the enhancement layers are specified by the SUPPLEMENTAL-CODECS
     attribute.

     The value is a quoted-string containing a comma-separated list of
     elements, where each element specifies an enhancement layer media
     sample type that is present in one or more Renditions specified by
     the Variant Stream.

     Each element is a slash-separated list of fields.  The first field
     must be a valid CODECS format.  If more than one field is present,
     the remaining fields must be compatibility brands [MP4RA] that
     pertain to that codec's bitstream.

     Each member of SUPPLEMENTAL-CODECS must have its base layer codec
     declared in the CODECS attribute.

     For example, a stream containing Dolby Vision 8.4 content might
     have a CODECS attribute including "hvc1.2.4.L153.b0", and a
     SUPPLEMENTAL-CODECS attribute including "dvh1.08.07/db4h".

     The SUPPLEMENTAL-CODECS attribute is OPTIONAL.

     RESOLUTION

     The value is a decimal-resolution describing the optimal pixel
     resolution at which to display all the video in the Variant
     Stream.

     The RESOLUTION attribute is OPTIONAL but is recommended if the
     Variant Stream includes video.

     FRAME-RATE

     The value is a decimal-floating-point describing the maximum frame
     rate for all the video in the Variant Stream, rounded to three
     decimal places.

     The FRAME-RATE attribute is OPTIONAL but is recommended if the
     Variant Stream includes video.  The FRAME-RATE attribute SHOULD be
     included if any video in a Variant Stream exceeds 30 frames per
     second.

     HDCP-LEVEL

     The value is an enumerated-string; valid strings are TYPE-0, TYPE-
     1, and NONE.  This attribute is advisory.  A value of TYPE-0
     indicates that the Variant Stream could fail to play unless the
     output is protected by High-bandwidth Digital Content Protection
     (HDCP) Type 0 [HDCP] or equivalent.  A value of TYPE-1 indicates
     that the Variant Stream could fail to play unless the output is
     protected by HDCP Type 1 or equivalent.  A value of NONE indicates
     that the content does not require output copy protection.

     Encrypted Variant Streams with different HDCP levels SHOULD use
     different media encryption keys.

     The HDCP-LEVEL attribute is OPTIONAL.  It SHOULD be present if any
     content in the Variant Stream will fail to play without HDCP.
     Clients without output copy protection SHOULD NOT load a Variant
     Stream with an HDCP-LEVEL attribute unless its value is NONE.

     ALLOWED-CPC

     The ALLOWED-CPC attribute allows a server to indicate that the
     playback of a Variant Stream containing encrypted Media Segments
     is to be restricted to devices that guarantee a certain level of
     content protection robustness.  Its value is a quoted-string
     containing a comma-separated list of entries.  Each entry consists
     of a KEYFORMAT attribute value followed by a colon character (:)
     followed by a sequence of Content Protection Configuration (CPC)
     Labels separated by slash (/) characters.  Each CPC Label is a
     string containing characters from the set [A..Z], [0..9], and '-'.

     For example: ALLOWED-CPC="com.example.drm1:SMART-TV/PC,
     com.example.drm2:HW"

     A CPC Label identifies a class of playback device that implements
     the KEYFORMAT with a certain level of content protection
     robustness.  Each KEYFORMAT can define its own set of CPC Labels.
     The "identity" KEYFORMAT does not define any labels.  A KEYFORMAT
     that defines CPC Labels SHOULD also specify its robustness
     requirements in a secure manner in each key response.

     A client MAY play the Variant Stream if it implements one of the
     listed KEYFORMAT schemes with content protection robustness that
     matches one or more of the CPC Labels in the list.  If it does not
     match any of the CPC Labels then it SHOULD NOT attempt to play the
     Variant Stream.

     The ALLOWED-CPC attribute is OPTIONAL.  If it is not present or
     does not contain a particular KEYFORMAT then all clients that
     support that KEYFORMAT MAY play the Variant Stream.

     VIDEO-RANGE

     The value is an enumerated-string; valid strings are SDR, HLG and
     PQ.

     The value MUST be SDR if the video in the Variant Stream is
     encoded using one of the following reference opto-electronic
     transfer characteristic functions specified by the
     TransferCharacteristics code point: [CICP] 1, 6, 13, 14, 15.  Note
     that different TransferCharacteristics code points can use the
     same transfer function.

     The value MUST be HLG if the video in the Variant Stream is
     encoded using a reference opto-electronic transfer characteristic
     function specified by the TransferCharacteristics code point 18,
     or consists of such video mixed with video qualifying as SDR (see
     above).

     The value MUST be PQ if the video in the Variant Stream is encoded
     using a reference opto-electronic transfer characteristic function
     specified by the TransferCharacteristics code point 16, or
     consists of such video mixed with video qualifying as SDR or HLG
     (see above).

     This attribute is OPTIONAL.  Its absence implies a value of SDR.
     Clients that do not recognize the attribute value SHOULD NOT
     select the Variant Stream.

     REQ-VIDEO-LAYOUT

     The REQ-VIDEO-LAYOUT attribute indicates whether the video content
     in the Variant Stream requires specialized rendering to be
     properly displayed.  Its value is a quoted-string containing a
     comma-separated list of View Presentation Entries, where each
     entry specifies the rendering for some portion of the Variant
     Stream.

     Each View Presentation Entry consists of an unordered, slash-
     separated list of specifiers.  Each specifier controls one aspect
     of the entry.  That is, the specifiers are disjoint and the values
     for a specifier are mutually exclusive.  Each specifier can occur
     at most once in an entry.  The possible specifiers are given
     below.

     All specifier values are enumerated-strings.  The enumerated-
     strings for a specifier will share a common-prefix.  If the
     specifier list contains an unrecognized enumerated-string then the
     client MUST ignore the tag and the following URI line.

     The Video Channel Specifier is an enumerated-string that defines
     the video channels; valid strings are CH-STEREO, and CH-MONO.  A
     value of CH-STEREO (stereoscopic) indicates that both left and
     right eye images are present.  A value of CH-MONO (monoscopic)
     indicates that a single image is present.

     The REQ-VIDEO-LAYOUT attribute is optional.  A REQ-VIDEO-LAYOUT
     attribute MUST NOT be empty, and each View Presentation Entry MUST
     NOT be empty.  The attribute SHOULD be present if any content in
     the Variant Stream will fail to display properly without
     specialized rendering, otherwise playback errors can occur on some
     clients.

     The client SHOULD assume that the order of entries reflects the
     most common presentation in the content.  For example, if the
     content is predominantly stereoscopic, with some brief sections
     that are monoscopic then the Multivariant Playlist SHOULD specify
     REQ-VIDEO-LAYOUT="CH-STEREO,CH-MONO".  On the other hand, if the
     content is predominantly monoscopic then the Multivariant Playlist
     SHOULD specify REQ-VIDEO-LAYOUT="CH-MONO,CH-STEREO"".

     By default a video variant is monoscopic, so an attribute
     consisting entirely of REQ-VIDEO-LAYOUT="CH-MONO" is unnecessary
     and SHOULD NOT be present.  Eliminating it allows Multivariant
     Playlists with a mix of monoscopic and stereoscopic variants to be
     played by clients that do not handle the REQ-VIDEO-LAYOUT
     attribute.

     STABLE-VARIANT-ID

     The value is a quoted-string which is a stable identifier for the
     URI within the Multivariant Playlist.  All characters in the
     quoted-string MUST be from the following set: [a..z], [A..Z],
     [0..9], '+', '/', '=', '.', '-', and '_'.  This attribute is
     OPTIONAL.

     The STABLE-VARIANT-ID allows the URI of the Variant Stream to
     change between two distinct downloads of the Multivariant
     Playlist.  IDs are matched using a byte-for-byte comparison.

     All EXT-X-STREAM-INF tags in a Multivariant Playlist with the same
     URI value SHOULD use the same STABLE-VARIANT-ID.

     AUDIO

     The value is a quoted-string.  It MUST match the value of the
     GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the
     Multivariant Playlist whose TYPE attribute is AUDIO.  It indicates
     the set of audio Renditions that SHOULD be used when playing the
     presentation.  See Section 4.4.6.2.1.

     The AUDIO attribute is OPTIONAL.

     VIDEO

     The value is a quoted-string.  It MUST match the value of the
     GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the
     Multivariant Playlist whose TYPE attribute is VIDEO.  It indicates
     the set of video Renditions that SHOULD be used when playing the
     presentation.  See Section 4.4.6.2.1.

     The VIDEO attribute is OPTIONAL.

     SUBTITLES

     The value is a quoted-string.  It MUST match the value of the
     GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the
     Multivariant Playlist whose TYPE attribute is SUBTITLES.  It
     indicates the set of subtitle Renditions that can be used when
     playing the presentation.  See Section 4.4.6.2.1.

     The SUBTITLES attribute is OPTIONAL.

     CLOSED-CAPTIONS

     The value can be either a quoted-string or an enumerated-string
     with the value NONE.  If the value is a quoted-string, it MUST
     match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag
     elsewhere in the Playlist whose TYPE attribute is CLOSED-CAPTIONS,
     and it indicates the set of closed-caption Renditions that can be
     used when playing the presentation.  See Section 4.4.6.2.1.

     If the value is the enumerated-string value NONE, all EXT-X-
     STREAM-INF tags MUST have this attribute with a value of NONE,
     indicating that there are no closed captions in any Variant Stream
     in the Multivariant Playlist.  Having closed captions in one
     Variant Stream but not another can trigger playback
     inconsistencies.

     The CLOSED-CAPTIONS attribute is OPTIONAL.

     PATHWAY-ID

     The value is a quoted-string.  It indicates that the Variant
     Stream belongs to the identified Content Steering (Section 7)
     Pathway.  This attribute is OPTIONAL.  Its absence indicates that
     the Variant Stream belongs to the default Pathway ".", so every
     Variant Stream can be associated with a named Pathway.

     A Content Producer SHOULD provide all Rendition Groups on all
     Pathways.  A Variant Stream belonging to a particular Pathway
     SHOULD use Rendition Group(s) on that Pathway.
     */
    
    func test_EXT_X_STREAM_INF() {
    
        let tagData = "PROGRAM-ID=1,BANDWIDTH=2855600,CODECS=\"avc1.4d001f,mp4a.40.2\",RESOLUTION=960x540"
        let optional: [PantosValue] = [.averageBandwidthBPS,
                                       .score,
                                       .audioGroup,
                                       .programId,
                                       .resolution,
                                       .videoGroup,
                                       .subtitlesGroup,
                                       .closedCaptionsGroup,
                                       .codecs,
                                       .supplementalCodecs,
                                       .hdcpLevel,
                                       .allowedCpc,
                                       .videoRange,
                                       .reqVideoLayout,
                                       .stableVariantId,
                                       .frameRate]
        let mandatory: [PantosValue] = [.bandwidthBPS]
        let badValues: [PantosValue] = [.bandwidthBPS,
                                        .averageBandwidthBPS,
                                        .score,
                                        .programId,
                                        .resolution,
                                        .frameRate,
                                        .hdcpLevel]

        validate(tag: PantosTag.EXT_X_STREAM_INF,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
    }
    
    /*
     An EXT-X-KEY tag with a URI attribute identifies a Key file.  A Key
     file contains the cipher key that MUST be used to decrypt subsequent
     media segments in the Playlist.
     
     [AES_128] encryption uses 16-octet keys.  If the KEYFORMAT of an EXT-
     X-KEY tag is "identity", the Key file is a single packed array of 16
     octets in binary format.
     
     IV for AES-128
     
     [AES_128] requires the same 16-octet Initialization Vector (IV) to be
     supplied when encrypting and decrypting.  Varying this IV increases
     the strength of the cipher.
     
     If an EXT-X-KEY tag has a KEYFORMAT of "identity" and an IV attribute
     is present, implementations MUST use the attribute value as the IV
     when encrypting or decrypting with that key.  The value MUST be
     interpreted as a 128-bit number.
     
     If an EXT-X-KEY tag with a KEYFORMAT of "identity" does not have the
     IV attribute, implementations MUST use the sequence number of the
     media segment as the IV when encrypting or decrypting that media
     segment.  The big-endian binary representation of the sequence number
     SHALL be placed in a 16-octet buffer and padded (on the left) with
     zeros.
     */
    func test_EXT_X_KEY() {
        
        let tagData = "METHOD=SAMPLE-AES,URI=\"https://priv.example.com/key.php?r=52\", IV=0x9c7db8778570d05c3177c349fd9236aa, KEYFORMAT=\"com.apple.streamingkeydelivery\", KEYFORMATVERSIONS=\"1\""
        let mandatory: [PantosValue] = []
        let badValues: [PantosValue] = [.method]
        
        validInput(tag: PantosTag.EXT_X_KEY, tagData: tagData)
        emptyInput(tag: PantosTag.EXT_X_KEY, numberOfErrors: mandatory.count)
        wrongType(tag: PantosTag.EXT_X_KEY, tagData: tagData, badValues: badValues)

        // AES-128, URI is mandatory, IV is optional
        var data = removeKey(tagData: tagData, key: PantosValue.ivector.rawValue, tag: PantosTag.EXT_X_KEY)
        validInput(tag: PantosTag.EXT_X_KEY, tagData: data)

        data = removeKey(tagData: tagData, key: PantosValue.uri.rawValue, tag: PantosTag.EXT_X_KEY)
        missingOrBadKey(tag: PantosTag.EXT_X_KEY, tagData: data, key: PantosValue.uri.rawValue)

        // NONE, the following attributes MUST NOT be present: URI, IV, KEYFORMAT, KEYFORMATVERSIONS.
        data = "METHOD=NONE,URI=\"https://priv.example.com/key.php?r=52\", IV=0x9c7db8778570d05c3177c349fd9236aa, KEYFORMAT=\"com.apple.streamingkeydelivery\", KEYFORMATVERSIONS=\"1\""
        missingOrBadKey(tag: PantosTag.EXT_X_KEY, tagData: data, key: PantosValue.method.rawValue)
        
        data = "METHOD=NONE,URI=\"https://priv.example.com/key.php?r=52\", IV=0x9c7db8778570d05c3177c349fd9236aa"
        missingOrBadKey(tag: PantosTag.EXT_X_KEY, tagData: data, key: PantosValue.method.rawValue)

        data = "METHOD=NONE,URI=\"https://priv.example.com/key.php?r=52\""
        missingOrBadKey(tag: PantosTag.EXT_X_KEY, tagData: data, key: PantosValue.method.rawValue)

        data = "METHOD=NONE, IV=0x9c7db8778570d05c3177c349fd9236aa"
        missingOrBadKey(tag: PantosTag.EXT_X_KEY, tagData: data, key: PantosValue.method.rawValue)
        
        data = "METHOD=NONE,KEYFORMAT=\"com.apple.streamingkeydelivery\", KEYFORMATVERSIONS=\"1\""
        missingOrBadKey(tag: PantosTag.EXT_X_KEY, tagData: data, key: PantosValue.method.rawValue)
        
        data = "METHOD=NONE,KEYFORMAT=\"com.apple.streamingkeydelivery\""
        missingOrBadKey(tag: PantosTag.EXT_X_KEY, tagData: data, key: PantosValue.method.rawValue)
        
        data = "METHOD=NONE, KEYFORMATVERSIONS=\"1\""
        missingOrBadKey(tag: PantosTag.EXT_X_KEY, tagData: data, key: PantosValue.method.rawValue)

        data = "METHOD=NONE"
        validInput(tag: PantosTag.EXT_X_KEY, tagData: data)
    }
    /*
     The EXT-X-MAP tag specifies how to obtain the Transport Stream PAT/
     PMT for the applicable media segment.  It applies to every media
     segment that appears after it in the Playlist until the next EXT-X-
     DISCONTINUITY tag, or until the end of the playlist.
     */
    func test_EXT_MAP() {
        
        let tagData = "URI=\"main.mp4\",BYTERANGE=\"560@0\""
        let optional: [PantosValue] = [.byterange]
        let mandatory: [PantosValue] = [.uri]
        let badValues: [PantosValue] = []
        
        validate(tag: PantosTag.EXT_X_MAP,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
    }
    /*
     The EXT-X-I-FRAME-STREAM-INF tag identifies a Media Playlist file
     containing the I-frames of a multimedia presentation.  It stands
     alone, in that it does not apply to a particular URI in the
     Multivariant Playlist.  Its format is:

     #EXT-X-I-FRAME-STREAM-INF:<attribute-list>

     All attributes defined for the EXT-X-STREAM-INF tag (Section 4.4.6.2)
     are also defined for the EXT-X-I-FRAME-STREAM-INF tag, except for the
     FRAME-RATE, AUDIO, SUBTITLES, and CLOSED-CAPTIONS attributes.  In
     addition, the following attribute is defined:

        URI

        The value is a quoted-string containing a URI that identifies the
        I-frame Media Playlist file.  That Playlist file MUST contain an
        EXT-X-I-FRAMES-ONLY tag.

     Every EXT-X-I-FRAME-STREAM-INF tag MUST include a BANDWIDTH attribute
     and a URI attribute.

     The provisions in Section 4.4.6.2.1 also apply to EXT-X-I-FRAME-
     STREAM-INF tags with a VIDEO attribute.

     A Multivariant Playlist that specifies alternative VIDEO Renditions
     and I-frame Playlists SHOULD include an alternative I-frame VIDEO
     Rendition for each regular VIDEO Rendition, with the same NAME and
     LANGUAGE attributes.
     */
    func test_EXT_I_FRAME_STREAM_INF() {
        
        let tagData = "BANDWIDTH=328400,PROGRAM-ID=1,CODECS=\"avc1.4d401f\",RESOLUTION=320x180,URI=\"Simpsons_505_HD_VOD_STUNT_movie_LVLH05/format-hls-track-iframe-bandwidth-328400-repid-328400.m3u8\""
        let optional: [PantosValue] = [.averageBandwidthBPS,
                                       .score,
                                       .programId,
                                       .resolution,
                                       .videoGroup,
                                       .codecs,
                                       .supplementalCodecs,
                                       .hdcpLevel,
                                       .allowedCpc,
                                       .videoRange,
                                       .reqVideoLayout,
                                       .stableVariantId]
        let mandatory: [PantosValue] = [.bandwidthBPS,
                                        .uri]
        let badValues: [PantosValue] = [.bandwidthBPS,
                                        .averageBandwidthBPS,
                                        .score,
                                        .programId,
                                        .resolution,
                                        .hdcpLevel]

        validate(tag: PantosTag.EXT_X_I_FRAME_STREAM_INF,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
    }

    /*
     The EXT-X-SESSION-DATA tag allows arbitrary session data to be
     carried in a Multivariant Playlist.

     Its format is:

     #EXT-X-SESSION-DATA:<attribute-list>

     The following attributes are defined:

        DATA-ID

        The value of DATA-ID is a quoted-string that identifies a
        particular data value.  The DATA-ID SHOULD conform to a reverse
        DNS naming convention, such as "com.example.movie.title"; however,
        there is no central registration authority, so Playlist authors
        SHOULD take care to choose a value that is unlikely to collide
        with others.  This attribute is REQUIRED.

        VALUE

        VALUE is a quoted-string.  It contains the data identified by
        DATA-ID.  If the LANGUAGE is specified, VALUE SHOULD contain a
        human-readable string written in the specified language.

        URI

        The value is a quoted-string containing a URI.  The resource
        identified by the URI MUST be formatted as indicated by the FORMAT
        attribute; otherwise, clients may fail to interpret the resource.

        FORMAT

        The value is an enumerated-string; valid strings are JSON and RAW.
        The FORMAT attribute MUST be ignored when URI attribute is
        missing.

        If the value is JSON, the URI MUST reference a JSON [RFC8259]
        format file.  If the value is RAW, the URI SHALL be treated as a
        binary file.

        This attribute is OPTIONAL.  Its absence implies a value of JSON.

        LANGUAGE

        The value is a quoted-string containing a language tag [RFC5646]
        that identifies the language of the VALUE.  This attribute is
        OPTIONAL.

     Each EXT-X-SESSION-DATA tag MUST contain either a VALUE or URI
     attribute, but not both.

     A Playlist MAY contain multiple EXT-X-SESSION-DATA tags with the same
     DATA-ID attribute.  A Playlist MUST NOT contain more than one EXT-X-
     SESSION-DATA tag with the same DATA-ID attribute and the same
     LANGUAGE attribute.
     */
    func test_EXT_X_SESSION_DATA() {
        let withURI = "DATA-ID=\"com.example.data\",URI=\"http://not.a.server/data.txt\",FORMAT=RAW,LANGUAGE=\"en\""
        validate(tag: PantosTag.EXT_X_SESSION_DATA,
                 tagData: withURI,
                 optional: [.value, .format, .language],
                 mandatory: [.dataId, .uri],
                 badValues: [])
        
        let withValue = "DATA-ID=\"com.example.data\",VALUE=\"Hello, World!\",LANGUAGE=\"en\""
        validate(tag: PantosTag.EXT_X_SESSION_DATA,
                 tagData: withValue,
                 optional: [.uri, .format, .language],
                 mandatory: [.dataId, .value],
                 badValues: [])

        // Using a closure to avoid naming clashes in the rest of the test.
        let EXT_X_SESSION_DATA_withNoValueOrURI = {
            let tagData = "DATA-ID=\"com.example.data\""
            let tag = createTag(tagDescriptor: PantosTag.EXT_X_SESSION_DATA, tagData: tagData)
            guard let validator = PantosTag.validator(forTag: PantosTag.EXT_X_SESSION_DATA) else {
                return XCTFail("No validator for EXT-X-SESSION-DATA")
            }
            guard let issues = validator.validate(tag: tag) else {
                return XCTFail("Should have issues when validating EXT-X-SESSION-DATA with no VALUE nor URI.")
            }
            XCTAssertEqual(1, issues.count, "Should have one issue")
            guard let issue = issues.first else { return XCTFail("Should have at least one issue") }
            XCTAssertEqual(issue.description, IssueDescription.EXT_X_SESSION_DATATagValidator.rawValue)
            XCTAssertEqual(issue.severity, .error)
        }
        EXT_X_SESSION_DATA_withNoValueOrURI()

        let EXT_X_SESSION_DATA_withValueAndURI = {
            let tagData = "DATA-ID=\"com.example.data\",VALUE=\"example\",URI=\"http://not.a.server/example\""
            let tag = createTag(tagDescriptor: PantosTag.EXT_X_SESSION_DATA, tagData: tagData)
            guard let validator = PantosTag.validator(forTag: PantosTag.EXT_X_SESSION_DATA) else {
                return XCTFail("No validator for EXT-X-SESSION-DATA")
            }
            guard let issues = validator.validate(tag: tag) else {
                return XCTFail("Should have issues when validating EXT-X-SESSION-DATA with both VALUE and URI.")
            }
            XCTAssertEqual(1, issues.count, "Should have one issue")
            guard let issue = issues.first else { return XCTFail("Should have at least one issue") }
            XCTAssertEqual(issue.description, IssueDescription.EXT_X_SESSION_DATATagValidator.rawValue)
            XCTAssertEqual(issue.severity, .error)
        }
        EXT_X_SESSION_DATA_withValueAndURI()
    }

    /*
     The EXT-X-SESSION-KEY tag allows encryption keys from Media Playlists
     to be specified in a Multivariant Playlist.  This allows the client
     to preload these keys without having to read the Media Playlist(s)
     first.

     Its format is:

     #EXT-X-SESSION-KEY:<attribute-list>

     All attributes defined for the EXT-X-KEY tag (Section 4.4.4.4) are
     also defined for the EXT-X-SESSION-KEY, except that the value of the
     METHOD attribute MUST NOT be NONE.  If an EXT-X-SESSION-KEY is used,
     the values of the METHOD, KEYFORMAT, and KEYFORMATVERSIONS attributes
     MUST match any EXT-X-KEY with the same URI value.

     EXT-X-SESSION-KEY tags SHOULD be added if multiple Variant Streams or
     Renditions use the same encryption keys and formats.  An EXT-X-
     SESSION-KEY tag is not associated with any particular Media Playlist.

     A Multivariant Playlist MUST NOT contain more than one EXT-X-SESSION-
     KEY tag with the same METHOD, URI, IV, KEYFORMAT, and
     KEYFORMATVERSIONS attribute values.

     The EXT-X-SESSION-KEY tag is optional.
     */
    func test_EXT_X_SESSION_KEY() {
        let tagData = "METHOD=SAMPLE-AES,URI=\"skd://key65\",KEYFORMAT=\"com.apple.streamingkeydelivery\""
        let tag = PantosTag.EXT_X_SESSION_KEY
        // Splitting out the `validate` into constituent parts because when URI is empty it triggers more than one
        // failure which trips up the `missingMandatoryKeys` method that expects just one failure.
        validInput(tag: tag, tagData: tagData)
        emptyInput(tag: tag, numberOfErrors: 2)
        missingOptionalKeys(tag: tag, tagData: tagData, removed: [.ivector, .keyformat, .keyformatVersions])
        missingMandatoryKeys(tag: tag, tagData: tagData, removed: [.method])
        wrongType(tag: tag, tagData: tagData, badValues: [.method])

        let EXT_X_SESSION_KEY_withNoURIAndMETHODEqualToNONE = {
            let tagData = "METHOD=NONE"
            let tag = createTag(tagDescriptor: PantosTag.EXT_X_SESSION_KEY, tagData: tagData)
            guard let validator = PantosTag.validator(forTag: PantosTag.EXT_X_SESSION_KEY) else {
                return XCTFail("No validator for EXT-X-SESSION-KEY")
            }
            guard let issues = validator.validate(tag: tag) else {
                return XCTFail("Should have issues when validating EXT-X-SESSION-KEY when METHOD=NONE.")
            }
            XCTAssertEqual(2, issues.count, "Should have two issues")
            for issue in issues {
                if issue.description == IssueDescription.EXT_X_SESSION_KEYValidator.rawValue {
                    XCTAssertEqual(issue.severity, .error, "Should have error severity for EXT-X-SESSION-KEY issue.")
                } else if issue.description == "EXT-X-SESSION-KEY mandatory value uri is missing." {
                    XCTAssertEqual(issue.severity, .error, "Should have error severity if URI is missing.")
                } else {
                    XCTFail("Not expecting to have issue with description: \(issue.description)")
                }
            }
        }
        EXT_X_SESSION_KEY_withNoURIAndMETHODEqualToNONE()
    }

    /*
     The EXT-X-CONTENT-STEERING tag allows a server to provide a Content
     Steering (Section 7) Manifest.  It is OPTIONAL.  It MUST NOT appear
     more than once in a Multivariant Playlist.  Its format is:

     #EXT-X-CONTENT-STEERING:<attribute-list>

     The following attributes are defined:

        SERVER-URI

        The value is a quoted-string containing a URI to a Steering
        Manifest (Section 7.1).  It MAY contain an asset identifier if the
        Steering Server requires it to produce the Steering Manifest.  It
        MAY use the "data" URI scheme to provide the manifest in-line in
        the Multivariant Playlist; in that case, subsequent manifest
        reloads MAY be redirected to a remote Steering Server using the
        RELOAD-URI parameter (see Section 7.1).  This attribute is
        REQUIRED.

        PATHWAY-ID

        The value is a quoted-string that identifies the Pathway that MUST
        be applied by any client that supports Content Steering (see
        Section 7.4) until the initial Steering Manifest has been
        obtained.  Its value MUST be a legal Pathway ID according to
        Section 7.1 that is specified by the PATHWAY-ID attribute of one
        or more Variant Streams in the Multivariant Playlist.  This
        attribute is OPTIONAL.
     */
    func test_EXT_X_CONTENT_STEERING() {
        let tagData = "SERVER-URI=\"https://not.a.server/content-steering.json\",PATHWAY-ID=\"A\""
        validate(tag: PantosTag.EXT_X_CONTENT_STEERING,
                 tagData: tagData,
                 optional: [.pathwayId],
                 mandatory: [.serverUri],
                 badValues: [])
    }

    /*
     The EXT-X-BYTERANGE tag indicates that a media segment is a sub-range
     of the resource identified by its media URI.  It applies only to the
     next media URI that follows it in the Playlist.  Its format is:
     
     #EXT-X-BYTERANGE:<n>[@o]
     
     where n is a decimal-integer indicating the length of the sub-range
     in bytes.  If present, o is a decimal-integer indicating the start of
     the sub-range, as a byte offset from the beginning of the resource.
     If o is not present, the sub-range begins at the next byte following
     the sub-range of the previous media segment.
     
     If o is not present, a previous media segment MUST appear in the
     Playlist file and MUST be a sub-range of the same media resource.
     
     A media URI with no EXT-X-BYTERANGE tag applied to it specifies a
     media segment that consists of the entire resource.
     
     The EXT-X-BYTERANGE tag appeared in version 4 of the protocol.
 */
    func test_EXT_X_BYTERANGE() {
        
        let tagData = "82112@752321"
        let optional: [PantosValue] = [.byterange]
        let mandatory: [PantosValue] = []
        let badValues: [PantosValue] = []
        
        validate(tag: PantosTag.EXT_X_BYTERANGE,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
    }
    
    /*
     The EXT-X-START tag indicates a preferred point at which to start
     playing a Playlist.  By default, clients SHOULD start playback at
     this point when beginning a playback session.  It MUST NOT appear
     more than once in a Playlist.  This tag is OPTIONAL.
     Its format is:
     
     #EXT-X-START:<attribute list>
     
     The following attributes are defined:
     
     TIME-OFFSET
     
     The value of TIME-OFFSET is a decimal-floating-point number of
     seconds.  A positive number indicates a time offset from the
     beginning of the Playlist.  A negative number indicates a negative
     time offset from the end of the last segment in the Playlist.  This
     attribute is REQUIRED.
     
     The absolute value of TIME-OFFSET MUST NOT be larger than the
     Playlist duration.
     
     If the Playlist does not contain the EXT-X-ENDLIST tag, the TIME-
     OFFSET SHOULD NOT be within three target durations of the end of the
     Playlist file.
     
     PRECISE
     
     The value is an enumerated-string; valid strings are YES and NO.  If
     the value is YES, clients SHOULD start playback at the segment
     containing the TIME-OFFSET, but SHOULD NOT render media samples in
     that segment whose presentation times are prior to the TIME-OFFSET.
     If the value is NO, clients SHOULD attempt to render every media
     sample in that segment.  This attribute is OPTIONAL. If it is
     missing, its value should be treated as NO.
     */
    
    func test_EXT_X_START() {
        
        let tagData = "TIME-OFFSET=30,PRECISE=YES"
        let optional: [PantosValue] = [.precise]
        let mandatory: [PantosValue] = [.startTimeOffset]
        let badValues: [PantosValue] = [.precise]
        
        validate(tag: PantosTag.EXT_X_START,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
    }
    
    /*
     The EXT-X-DATERANGE tag associates a Date Range (i.e., a range of
     time defined by a starting and ending date) with a set of attribute/
     value pairs.  Its format is:

     #EXT-X-DATERANGE:<attribute-list>

     where the defined attributes are:

        ID

        A quoted-string that uniquely identifies a Date Range in the
        Playlist.  This attribute is REQUIRED.

        CLASS

        A client-defined quoted-string that specifies some set of
        attributes and their associated value semantics.  All Date Ranges
        with the same CLASS attribute value MUST adhere to these
        semantics.  This attribute is OPTIONAL.

        START-DATE

        A quoted-string containing the [ISO_8601] date/time at which the
        Date Range begins.  This attribute is REQUIRED.

        END-DATE

        A quoted-string containing the [ISO_8601] date/time at which the
        Date Range ends.  It MUST be equal to or later than the value of
        the START-DATE attribute.  This attribute is OPTIONAL.

        DURATION

        The duration of the Date Range expressed as a decimal-floating-
        point number of seconds.  It MUST NOT be negative.  A single
        instant in time (e.g., crossing a finish line) SHOULD be
        represented with a duration of 0.  This attribute is OPTIONAL.

        PLANNED-DURATION
        The expected duration of the Date Range expressed as a decimal-
        floating-point number of seconds.  It MUST NOT be negative.  This
        attribute SHOULD be used to indicate the expected duration of a
        Date Range whose actual duration is not yet known.  It is
        OPTIONAL.

        X-<client-attribute>

        The "X-" prefix defines a namespace reserved for client-defined
        attributes.  The client-attribute MUST be a legal AttributeName.
        Clients SHOULD use a reverse-DNS syntax when defining their own
        attribute names to avoid collisions.  The attribute value MUST be
        a quoted-string, a hexadecimal-sequence, or a decimal-floating-
        point.  An example of a client-defined attribute is X-COM-EXAMPLE-
        AD-ID="XYZ123".  These attributes are OPTIONAL.

        SCTE35-CMD, SCTE35-OUT, SCTE35-IN

        Used to carry SCTE-35 data; see Section 4.4.5.1.1 for more
        information.  These attributes are OPTIONAL.

        END-ON-NEXT

        An enumerated-string whose value MUST be YES.  This attribute
        indicates that the end of the range containing it is equal to the
        START-DATE of its Following Range.  The Following Range is the
        Date Range of the same CLASS that has the earliest START-DATE
        after the START-DATE of the range in question.  This attribute is
        OPTIONAL.

     An EXT-X-DATERANGE tag with an END-ON-NEXT=YES attribute MUST have a
     CLASS attribute.  Other EXT-X-DATERANGE tags with the same CLASS
     attribute MUST NOT specify Date Ranges that overlap.

     An EXT-X-DATERANGE tag with an END-ON-NEXT=YES attribute MUST NOT
     contain DURATION or END-DATE attributes.

     A Date Range with neither a DURATION, an END-DATE, nor an END-ON-
     NEXT=YES attribute has an unknown duration, even if it has a PLANNED-
     DURATION.

     If a Playlist contains an EXT-X-DATERANGE tag, it MUST also contain
     at least one EXT-X-PROGRAM-DATE-TIME tag.

     If a Playlist contains two EXT-X-DATERANGE tags with the same ID
     attribute value, then any AttributeName that appears in both tags
     MUST have the same AttributeValue.
     
     If a Date Range contains both a DURATION attribute and an END-DATE
     attribute, the value of the END-DATE attribute MUST be equal to the
     value of the START-DATE attribute plus the value of the DURATION
     attribute.

     Clients SHOULD ignore EXT-X-DATERANGE tags with illegal syntax.
     */
    func test_EXT_X_DATERANGE() {
        let tagData = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",PLANNED-DURATION=2713.000,SCTE35-OUT=0xFC303E0000000000000000000506807B4C487A00280226435545490000000200E0000E8DBD100E1270636B5F45503030363739343031303331381001018E5BFFD0"
        let optional: [PantosValue] = [.classAttribute,
                                       .endDate,
                                       .duration,
                                       .plannedDuration,
                                       .scte35Cmd,
                                       .scte35Out,
                                       .scte35In,
                                       .endOnNext]
        let mandatory: [PantosValue] = [.id,
                                        .startDate]
        let badValues: [PantosValue] = [.startDate,
                                        .endDate,
                                        .duration,
                                        .plannedDuration,
                                        .endOnNext]
        
        validate(tag: PantosTag.EXT_X_DATERANGE,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
        
        // END-ON-NEXT = An enumerated-string whose value MUST be YES.
        var data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",END-ON-NEXT=NO,CLASS=\"my:scheme\""
        var validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGEEND_ON_NEXTValueMustBeYES, severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        
        // An EXT-X-DATERANGE tag with an END-ON-NEXT=YES attribute MUST have a CLASS attribute.
        data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",END-ON-NEXT=YES"
        validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGETagWithEND_ON_NEXTMustHaveCLASSAttribute, severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        
        // An EXT-X-DATERANGE tag with an END-ON-NEXT=YES attribute MUST NOT contain DURATION or END-DATE attributes.
        data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",END-ON-NEXT=YES,CLASS=\"my:scheme\",DURATION=30.000"
        validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGETagWithEND_ON_NEXTMustNotContainDURATION, severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",END-ON-NEXT=YES,CLASS=\"my:scheme\",END-DATE=\"2020-03-28T14:43:16.249Z\""
        validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGETagWithEND_ON_NEXTMustNotContainEND_DATE, severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        
        // If a Date Range contains both a DURATION attribute and an END-DATE attribute, the value of the END-DATE attribute MUST be equal to the
        // value of the START-DATE attribute plus the value of the DURATION attribute.
        data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",DURATION=30.000,END-DATE=\"2020-03-26T10:46:20.000Z\""
        validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGEValidatorDURATIONAndEND_DATEMustMatchWithSTART_DATE, severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",DURATION=30.000,END-DATE=\"2020-03-26T10:45:50.894Z\""
        validationIssues = []
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        
        // END-DATE MUST be equal to or later than the value of the START-DATE attribute.
        data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",END-DATE=\"2020-03-26T10:45:20.000Z\""
        validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGETagEND_DATEMustBeAfterSTART_DATE, severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        
        // DURATION MUST NOT be negative.
        data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",DURATION=-10.000"
        validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGETagDURATIONMustNotBeNegative, severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        
        // PLANNED-DURATION MUST NOT be negative.
        data = "ID=\"2-0x10-1585219520\",START-DATE=\"2020-03-26T10:45:20.894Z\",PLANNED-DURATION=-10.000"
        validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGETagPLANNED_DURATIONMustNotBeNegative, severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
        
        // Testing a combination of issues are also possible
        data = "START-DATE=\"2020-03-26T10:45:20.894Z\",END-ON-NEXT=NO,DURATION=30.000,END-DATE=\"2020-03-26T10:46:20.000Z\""
        validationIssues = [PlaylistValidationIssue(description: .EXT_X_DATERANGEEND_ON_NEXTValueMustBeYES, severity: .warning),
                            PlaylistValidationIssue(description: .EXT_X_DATERANGETagWithEND_ON_NEXTMustHaveCLASSAttribute, severity: .warning),
                            PlaylistValidationIssue(description: .EXT_X_DATERANGETagWithEND_ON_NEXTMustNotContainDURATION, severity: .warning),
                            PlaylistValidationIssue(description: .EXT_X_DATERANGETagWithEND_ON_NEXTMustNotContainEND_DATE, severity: .warning),
                            PlaylistValidationIssue(description: .EXT_X_DATERANGEValidatorDURATIONAndEND_DATEMustMatchWithSTART_DATE, severity: .warning),
                            PlaylistValidationIssue(description: "EXT-X-DATERANGE mandatory value id is missing.", severity: .warning)]
        validateEXT_X_DATERANGE(tagData: data, expectedValidationIssues: validationIssues)
    }
    
    private func validateEXT_X_DATERANGE(tagData: String, expectedValidationIssues: [PlaylistValidationIssue]) {
        let expectedIssuesDescriptions = expectedValidationIssues.map { $0.description }.joined(separator: "\n")
        let (validator, tag) = constructDictionaryValidator(PantosTag.EXT_X_DATERANGE, data: tagData)
        guard let errors = validator.validate(tag: tag) else {
            if expectedValidationIssues.isEmpty {
                return // no issues as expected
            }
            return XCTFail("Expected EXT-X-DATERANGE validation issue\nTag data: \(tagData)\nExpected issues:\n\(expectedIssuesDescriptions)")
        }
        let actualIssuesDescriptions = errors.map { $0.description }.joined(separator: "\n")
        XCTAssertEqual(errors.count,
                       expectedValidationIssues.count,
                       "Mismatch in expected issues and actual issues in EXT_X_DATERANGE validation.\nExpected issues:\n\(expectedIssuesDescriptions)\nActual issues:\n\(actualIssuesDescriptions)")
        expectedValidationIssues.forEach { expectedValidationIssue in
            guard let matchingIssue = errors.first(where: { $0.description == expectedValidationIssue.description }) else {
                return XCTFail("Expected issue \"\(expectedValidationIssue.description)\" not found for EXT-X-DATERANGE tag: \(tagData)\nIssues found:\n\(actualIssuesDescriptions)")
            }
            XCTAssertEqual(expectedValidationIssue.description, matchingIssue.description)
            XCTAssertEqual(expectedValidationIssue.severity,
                           matchingIssue.severity,
                           "Expected EXT-X-DATERANGE validation issue (\(expectedValidationIssue.description)) had unexpected severity (\(matchingIssue.severity))")
        }
    }
}
