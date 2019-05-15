//
//  HLSTagDescriptor.swift
//  mamba
//
//  Created by David Coufal on 6/27/16.
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

/// Protocol that describes the behavior of a HLS tag descriptor.
///
/// Every line in a HLS playlist gets a `HLSTagDescriptor` as a shorthand for the kind of data that is represented.
///
/// There is a default `HLSTagDescriptor` provider, `PantosTag`
public protocol HLSTagDescriptor {
    
    /// Get a string represention of the tag descriptor that is the same as how it appears in the HLS playlist (i.e. "`EXTINF`")
    func toString() -> String
    
    /// Equality Implementation to work around Equatable issues with protocols
    func isEqual(toTagDescriptor: HLSTagDescriptor) -> Bool
    
    /// Return the HLSTagDescriptorScope that describes the scope of the tag
    func scope() -> HLSTagDescriptorScope
    
    /// Return the HLSTagDescriptorType that describes the type of the tag
    func type() -> HLSTagDescriptorType
    
    /**
     Factory method to construct a HLSTagParser for the given HLSTagDescriptor.
     
     - parameter forTag: We want a parser for this HLSTagDescriptor
     
     - returns: A optional HLSTagParser. Some `HLSTagDescriptor`s (particularly `PantosTag`s) will not
     get a parser as they are parsed during the initial pass through the playlist.
     (This is specifically true for .Comment, .Location, .UnknownTag and .EXTINF tags, as well
     as tags with type of HLSTagDescriptorType.noValue)
     */
    static func parser(forTag: HLSTagDescriptor) -> HLSTagParser?
    
    /**
     Factory method to construct a HLSTagWriter for this HLSTagDescriptor
     
     - parameter forTag: We want a writer for this HLSTagDescriptor
     
     - returns: A optional HLSTagWriter. It's expected that `HLSTag`s that are not "dirty" will not require
     a writer, as we can reconstruct any tag from `HLSTag` parsed data if not edited. Therefore, for tags
     that are not editable, a HLSTagWriter is not required, and a nil can be returned for those tags.
     */
    static func writer(forTag: HLSTagDescriptor) -> HLSTagWriter?
    
    /**
     Factory method to construct a HLSTagValidator for this HLSTagDescriptor
     
     - parameter forTag: We want a validator for this HLSTagDescriptor
     
     - returns: A optional HLSTagValidator. Some tags do not require validation. It's OK to return nil for
     those kinds of tags.
     */
    static func validator(forTag: HLSTagDescriptor) -> HLSTagValidator?
    
    /// Method to get a HLSTagDescriptor from a HLSStringRef
    static func constructDescriptor(fromStringRef: HLSStringRef) -> HLSTagDescriptor?
}

public func ==(lhs: HLSTagDescriptor, rhs: HLSTagDescriptor) -> Bool {
    return lhs.isEqual(toTagDescriptor:rhs)
}

public func !=(lhs: HLSTagDescriptor, rhs: HLSTagDescriptor) -> Bool {
    return !(lhs == rhs)
}

public enum HLSTagDescriptorScope {
    /// a tag that describes the entire playlist
    case wholePlaylist
    /// a tag that describes a media segment
    case mediaSegment
    /// a tag that describes multiple media segments
    case mediaSpanner
    /// unknown tag type
    case unknown
}

public enum HLSTagDescriptorType {
    /// a tag that has no value associated with it (i.e. `#EXT_X_ENDLIST`).
    case noValue
    /// a tag that has one value associated with it (i.e. `#EXT_X_MEDIA_SEQUENCE:30`).
    case singleValue
    /// a tag that has a comma separated array associated with it (i.e. `#EXTINF:2.002,30`). EXTINF is the only example of this type.
    case array
    /// a tag that has a comma separated set of key value pairs (separated by =) associated with it. (i.e. `#EXT-X-KEY:METHOD=SAMPLE-AES,URI="https://priv.example.com/key.php?r=52",IV=0x9c7db8778570d05c3177c349fd9236aa,KEYFORMAT="com.apple.streamingkeydelivery",KEYFORMATVERSIONS="1"`).
    case keyValue
    /// This tag does not fit into any of the above categories.
    case special
}

extension HLSTagDescriptor {
    
    /// Hashable Implementation to work around Hashable issues with protocols
    public var hashValue: Int {
        return self.toString().hash
    }
    
    // Hasher shunt to work around Hashable issues with protocols
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.toString())
    }
}
