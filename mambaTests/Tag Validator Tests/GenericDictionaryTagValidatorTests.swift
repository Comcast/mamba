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

    func parse(tagData: String, tag: PantosTag) -> HLSTagDictionary {
        
        return try! PantosTag.parser(forTag:tag)!.parseTag(fromTagString: tagData)
    }
    
    func write(dictionary: HLSTagDictionary, tag: PantosTag) -> String {
        let tagImpl = HLSTag(tagDescriptor: tag, stringTagData: "", parsedValues: dictionary)
                
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
        dictionary[key] = HLSValueData(value: value)
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
    
    func constructDictionaryValidator(_ tag: HLSTagDescriptor, data: String) -> (HLSTagValidator, HLSTag) {
        
        let tagImpl = createHLSTag(tagDescriptor: tag, tagData: data)
         
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
     
     URI
     
     The value is a quoted-string containing a URI that identifies the
     Playlist file.  This attribute is optional; see Section 3.4.10.1.
     
     TYPE
     
     The value is enumerated-string; valid strings are AUDIO, VIDEO and
     SUBTITLES.  If the value is AUDIO, the Playlist described by the tag
     MUST contain audio media.  If the value is VIDEO, the Playlist MUST
     contain video media.  If the value is SUBTITLES, the Playlist MUST
     contain subtitle media.
     
     GROUP-ID
     
     The value is a quoted-string identifying a mutually-exclusive group
     of renditions.  The presence of this attribute signals membership in
     the group.  See Section 3.4.9.1.
     
     LANGUAGE
     
     The value is a quoted-string containing an RFC 5646 [RFC5646]
     language tag that identifies the primary language used in the
     rendition.  This attribute is optional.
     
     ASSOC-LANGUAGE
     
     The value is a quoted-string containing an RFC 5646 [RFC5646]
     language tag that identifies a language that is associated with the
     rendition.  An associated language is often used in a different role
     than the language specified by the LANGUAGE attribute (e.g.  written
     vs.  spoken, or as a fallback dialect). This attribute is OPTIONAL.
     
     NAME
     
     The value is a quoted-string containing a human-readable description
     of the rendition.  If the LANGUAGE attribute is present then this
     description SHOULD be in that language.
     
     DEFAULT
     
     The value is an enumerated-string; valid strings are YES and NO.  If
     the value is YES, then the client SHOULD play this rendition of the
     content in the absence of information from the user indicating a
     different choice.  This attribute is optional.  Its absence indicates
     an implicit value of NO.
     
     AUTOSELECT
     
     The value is an enumerated-string; valid strings are YES and NO.
     This attribute is optional.  If it is present, its value MUST be YES
     if the value of the DEFAULT attribute is YES.  If the value is YES,
     then the client MAY choose to play this rendition in the absence of
     explicit user preference because it matches the current playback
     environment, such as chosen system language.
     
     FORCED
     
     The value is an enumerated-string; valid strings are YES and NO.
     This attribute is optional.  Its absence indicates an implicit value
     of NO.  The FORCED attribute MUST NOT be present unless the TYPE is
     SUBTITLES.
     
     A value of YES indicates that the rendition contains content which is
     considered essential to play.  When selecting a FORCED rendition, a
     client should choose the one that best matches the current playback
     environment (e.g. language).
     
     A value of NO indicates that the rendition contains content which is
     intended to be played in response to explicit user request.
     
     INSTREAM-ID
     
     The value is a quoted-string that specifies a rendition within the
     segments in the Media Playlist.  This attribute is REQUIRED if the
     TYPE attribute is CLOSED-CAPTIONS, in which case it MUST have one of
     the values: "CC1", "CC2", "CC3", "CC4".  For all other TYPE values,
     the INSTREAM-ID SHOULD NOT be specified.
     
     CHARACTERISTICS
     
     The value is a quoted-string containing one or more Uniform Type
     Identifiers [UTI] separated by comma (,) characters.  This attribute
     is optional.  Each UTI indicates an individual characteristic of the
     rendition.
     */
    
     func test_EXT_X_MEDIA() {
     
        var tagData = "TYPE=AUDIO,GROUP-ID=\"g104000\",NAME=\"English\",LANGUAGE=\"en\",URI=\"IP_720p60_51_SAP_TS/4242/format-hls-track-audio-bandwidth-104000-repid-104000.m3u8\",DEFAULT=YES,AUTOSELECT=YES"
        let optional: [PantosValue] = [.audioGroup,
                                       .type,
                                       .groupId,
                                       .name,
                                       .language,
                                       .assocLanguage,
                                       .uri,
                                       .defaultMedia,
                                       .autoselect,
                                       .forced,
                                       .instreamId,
                                       .characteristics
        ]
        let mandatory: [PantosValue] = []
        let badValues: [PantosValue] = [.type,
                                        .defaultMedia,
                                        .autoselect,
                                        .forced,
                                        .instreamId]
        
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
     
     The value is a decimal-integer of bits per second.  It MUST be an
     upper bound of the overall bitrate of each media segment (calculated
     to include container overhead) that appears or will appear in the
     Playlist.
     
     Every EXT-X-STREAM-INF tag MUST include the BANDWIDTH attribute.
     
     PROGRAM-ID
     
     The value is a decimal-integer that uniquely identifies a particular
     presentation within the scope of the Playlist file.
     
     A Playlist file MAY contain multiple EXT-X-STREAM-INF tags with the
     same PROGRAM-ID to identify different encodings of the same
     presentation.  These variant playlists MAY contain additional EXT-X-
     STREAM-INF tags.
     
     CODECS
     
     The value is a quoted-string containing a comma-separated list of
     formats, where each format specifies a media sample type that is
     present in a media segment in the Playlist file.  Valid format
     identifiers are those in the ISO File Format Name Space defined by
     RFC 6381 [RFC6381].
     
     Every EXT-X-STREAM-INF tag SHOULD include a CODECS attribute.
     
     RESOLUTION
     
     The value is a decimal-resolution describing the approximate encoded
     horizontal and vertical resolution of video within the presentation.
     
     AUDIO
     
     The value is a quoted-string.  It MUST match the value of the
     GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist
     whose TYPE attribute is AUDIO.  It indicates the set of audio
     renditions that MAY be used when playing the presentation.  See
     Section 3.3.10.1.
     
     VIDEO
     
     The value is a quoted-string.  It MUST match the value of the
     GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist
     whose TYPE attribute is VIDEO.  It indicates the set of video
     renditions that MAY be used when playing the presentation.  See
     Section 3.3.10.1.
     
     SUBTITLES
     
     The value is a quoted-string.  It MUST match the value of the GROUP-
     ID attribute of an EXT-X-MEDIA tag elsewhere in the Master Playlist
     whose TYPE attribute is SUBTITLES. It indicates the set of subtitle
     renditions that MAY be used when playing the presentation. See Section 3.4.10.1.
     
     CLOSED-CAPTIONS
     
     The value can be either a quoted-string or an enumerated-string with
     the value NONE.  If the value is a quoted-string, it MUST match the
     value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in
     the Playlist whose TYPE attribute is CLOSED-CAPTIONS, and indicates
     the set of closed-caption renditions that may be used when playlist
     the presentation.
     
     If the value is the enumerated-string value NONE, all EXT-X-STREAM-
     INF tags MUST have this attribute with a value of NONE.  This
     indicates that there are no closed captions in any variant stream in
     the Master Playlist
     */
    
    func test_EXT_X_STREAM_INF() {
    
        let tagData = "PROGRAM-ID=1,BANDWIDTH=2855600,CODECS=\"avc1.4d001f,mp4a.40.2\",RESOLUTION=960x540"
        let optional: [PantosValue] = [.audioGroup,
                                       .programId,
                                       .resolution,
                                       .videoGroup,
                                       .subtitlesGroup,
                                       .closedCaptionsGroup,
                                       .codecs]
        let mandatory: [PantosValue] = [.bandwidthBPS]
        let badValues: [PantosValue] = [.bandwidthBPS,
                                        .programId,
                                        .resolution]
        
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
     The EXT-X-I-FRAME-STREAM-INF tag identifies a Playlist file
     containing the I-frames of a multimedia presentation.  It stands
     alone, in that it does not apply to a particular URI in the Playlist.
     Its format is:
     
     #EXT-X-I-FRAME-STREAM-INF:<attribute-list>
     
     All attributes defined for the EXT-X-STREAM-INF tag (Section 3.3.10)
     are also defined for the EXT-X-I-FRAME-STREAM-INF tag, except for the
     AUDIO attribute.  In addition, the following attribute is defined:
     
     URI
     
     The value is a quoted-string containing a URI that identifies the
     I-frame Playlist file.
     
     Every EXT-X-I-FRAME-STREAM-INF tag MUST include a BANDWIDTH attribute
     and a URI attribute.
     
     The provisions in Section 3.3.10.1 also apply to EXT-X-I-FRAME-
     STREAM-INF tags with a VIDEO attribute.
     
     A Playlist that specifies alternative VIDEO renditions and I-frame
     Playlists SHOULD include an alternative I-frame VIDEO rendition for
     each regular VIDEO rendition, with the same NAME and LANGUAGE
     attributes.
     
     The EXT-X-I-FRAME-STREAM-INF tag appeared in version 4 of the
     protocol.  Clients supporting earlier protocol versions MUST ignore
     it.
     */
    func test_EXT_I_FRAME_STREAM_INF() {
        
        let tagData = "BANDWIDTH=328400,PROGRAM-ID=1,CODECS=\"avc1.4d401f\",RESOLUTION=320x180,URI=\"Simpsons_505_HD_VOD_STUNT_movie_LVLH05/format-hls-track-iframe-bandwidth-328400-repid-328400.m3u8\""
        let optional: [PantosValue] = [.programId,
                                       .codecs,
                                       .resolution,
                                       .videoGroup]
        let mandatory: [PantosValue] = [.bandwidthBPS,
                                        .uri]
        let badValues: [PantosValue] = [.bandwidthBPS,
                                        .programId,
                                        .resolution]
        
        validate(tag: PantosTag.EXT_X_I_FRAME_STREAM_INF,
                 tagData: tagData,
                 optional: optional,
                 mandatory: mandatory,
                 badValues: badValues)
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
}
