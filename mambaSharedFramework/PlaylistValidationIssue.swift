//
//  PlaylistValidationIssues.swift
//  mamba
//
//  Created by Mohan on 8/7/16.
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

/// Describes an issue found in validating a HLS playlist.
public struct PlaylistValidationIssue: Error {
    /// A description of the validation error
    public let description: String
    /// The severity of the validation error
    public let severity: IssueSeverity

    public init(description: String, severity: IssueSeverity) {
        self.description = description
        self.severity = severity
    }
    
    public init(description: IssueDescription, severity: IssueSeverity) {
        self.description = description.rawValue
        self.severity = severity
    }
}

extension PlaylistValidationIssue: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "\(severity.loggingPrefix) \(description)"
    }
}

public enum IssueSeverity: Error {
    /// low severity
    case warning
    /// high severity
    case error
}

public extension IssueSeverity {
    var loggingPrefix: String {
        switch self {
        case .warning:
            return "Playlist Validation Warning:"
        case .error:
            return "Playlist Validation Error:"
        }
    }
}

public enum IssueDescription: String {
    
    case PlaylistRenditionGroupMatchingNAMELANGUAGEValidator = "A Playlist MAY contain multiple groups of the same TYPE in order to provide multiple encodings of each rendition. If it does so, each group of the same TYPE SHOULD contain corresponding members with the same NAME attribute, LANGUAGE attribute, and rendition."
    case EXT_X_KEYValidator = "EXT-X-KEY If the encryption method is NONE, the URI, IV, KEYFORMAT and KEYFORMATVERSIONS attributes MUST NOT be present. If the encryption method is AES-128 or SAMPLE-AES, the URI attribute MUST be present."
    case PlaylistRenditionGroupMatchingPROGRAM_IDValidator = "Variant Playlists MUST contain an EXT-X-STREAM-INF tag or EXT-X-I-FRAME-STREAM-INF tag for each variant stream. Each tag identifying an encoding of the same presentation MUST have the same PROGRAM-ID attribute value."
    case EXT_X_STREAM_INFRenditionGroupAUDIOValidator = "EXT-X-STREAM-INF - AUDIO The value is a quoted-string. It MUST match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist whose TYPE attribute is AUDIO."
    case EXT_X_STREAM_INFRenditionGroupVIDEOValidator = "EXT-X-STREAM-INF - VIDEO The value is a quoted-string. It MUST match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist whose TYPE attribute is VIDEO."
    case EXT_X_STREAM_INFRenditionGroupSUBTITLESValidator = "EXT-X-STREAM-INF - SUBTITLES The value is a quoted-string. It MUST match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist whose TYPE attribute is SUBTITLES."
    case EXT_X_STREAM_INFRenditionGroupCLOSEDCAPTIONSValidator = "EXT-X-STREAM-INF - CLOSED-CAPTIONS The value is a quoted-string or an enumerated-string NONE. If the value is a quoted-string, it MUST match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Playlist whose TYPE attribute is CLOSED-CAPTIONS. If it is NONE, all EXT-X-STREAM-INF tags must have this attribute with a value of NONE."
    case EXT_X_TARGETDURATIONLengthValidator = "The EXT-X-TARGETDURATION tag specifies the maximum media segment duration. The EXTINF duration of each media segment in the Playlist file MUST be less than or equal to the target duration."
    case EXT_X_STARTTimeOffsetValidator = "TIME-OFFSET absolute value should never be longer than the playlist or If the variant does not contain EXT-X-ENDLIST, TIME-OFFSET should not be within 3 target durations from the end."
    case PlaylistRenditionGroupAUDIOValidator = "All members of a group with TYPE=AUDIO MUST use the same audio sample format."
    case PlaylistRenditionGroupVIDEOValidator = "All members of a group with TYPE=VIDEO MUST use the same video sample format."
    case EXT_X_MEDIARenditionGroupNAMEValidator = "All EXT-X-MEDIA tags in the same group MUST have different NAME attributes."
    case EXT_X_MEDIARenditionGroupTYPEValidator = "All EXT-X-MEDIA tags in the same group MUST have the same TYPE attribute."
    case EXT_X_MEDIA_InstreamIdValidation = "INSTREAM-ID attribute is required if the TYPE attribute is CLOSED-CAPTIONS"
    case EXT_X_VERSIONValidation = "A Playlist file MUST NOT contain more than one EXT-X-VERSION tag. A Playlist file that does not contain an EXT-X-VERSION tag MUST comply with version 1 of this protocol."
    case EXT_X_TARGETDURATIONValidation = "EXT-X-TARGETDURATION - This tag MUST appear once in the Playlist file."
    case EXT_X_ENDLISTValidation = "EXT-X-ENDLIST It MAY occur anywhere in the Playlist file; it MUST NOT occur more than once."
    case EXT_X_MEDIA_SEQUENCEValidation = "A Playlist file MUST NOT contain more than one EXT-X-MEDIA-SEQUENCE tag."
    case EXT_X_DISCONTINUITY_SEQUENCEValidator = "A Playlist file MUST NOT contain more than one EXT-X-DISCONTINUITY-SEQUENCE tag."
    case EXT_X_MEDIARenditionGroupDEFAULTValidator = "A group MUST NOT have more than one member with a DEFAULT attribute of YES."
    case EXTINFTagsRequireADurationValidator = "EXTINF tags require a positive duration."
    case EXT_X_DATERANGEEND_ON_NEXTValueMustBeYES = "Value of END-ON-NEXT attribute within EXT-X-DATERANGE MUST be YES."
    case EXT_X_DATERANGETagWithEND_ON_NEXTMustHaveCLASSAttribute = "An EXT-X-DATERANGE tag with an END-ON-NEXT=YES attribute MUST have a CLASS attribute."
    case EXT_X_DATERANGETagWithEND_ON_NEXTMustNotContainDURATION = "An EXT-X-DATERANGE tag with an END-ON-NEXT=YES attribute MUST NOT contain DURATION attribute."
    case EXT_X_DATERANGETagWithEND_ON_NEXTMustNotContainEND_DATE = "An EXT-X-DATERANGE tag with an END-ON-NEXT=YES attribute MUST NOT contain END-DATE attribute."
    case EXT_X_DATERANGEValidatorDURATIONAndEND_DATEMustMatchWithSTART_DATE = "If a Date Range contains both a DURATION attribute and an END-DATE attribute, the value of the END-DATE attribute MUST be equal to the value of the START-DATE attribute plus the value of the DURATION attribute."
    case EXT_X_DATERANGETagEND_DATEMustBeAfterSTART_DATE = "END-DATE MUST be equal to or later than the value of the START-DATE attribute."
    case EXT_X_DATERANGETagDURATIONMustNotBeNegative = "DURATION MUST NOT be negative."
    case EXT_X_DATERANGETagPLANNED_DURATIONMustNotBeNegative = "PLANNED-DURATION MUST NOT be negative."
    case EXT_X_DATERANGEExistsWithNoEXT_X_PROGRAM_DATE_TIME = "If a Playlist contains an EXT-X-DATERANGE tag, it MUST also contain at least one EXT-X-PROGRAM-DATE-TIME tag."
    case EXT_X_DATERANGEAttributeMismatchForTagsWithSameID = "If a Playlist contains two EXT-X-DATERANGE tags with the same ID attribute value, then any AttributeName that appears in both tags MUST have the same AttributeValue."
}

