//
//  PlaylistTag.swift
//  mamba
//
//  Created by David Coufal on 8/2/16.
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
 A struct representing a single tag line from a HLS playlist.
 
 *Important memory safety note:* This struct contains `MambaStringRef`s. Those objects
 may contain unsafe pointers to a external `Data` object (typically this Data object
 is the one parsed by `Parser` to create a playlist containing many
 `Tag`s). If this Data is deallocted before this `Tag` is deallocated,
 accessing any `MambaStringRef`s may result in undefined behavior.
 
 The rule for safety is, as long as a paricular `Tag` is accessed while its
 parent `PlaylistInterface` is still allocated, that is safe. If you need to access
 any `Tag` data after its parent `PlaylistInterface` is deallocated, you'll need to
 make a copy of any relevant `MambaStringRef`s via it's `stringValue` function.
 
 This un-swift-like memory safety issue was done for performance reasons. Allocating
 hundreds of thousands of `String`s when parsing a HLS playlist that is multiple
 hours in length is very slow. Creating pointers to already existing memory is fast.
 */
public struct PlaylistTag: CustomDebugStringConvertible {
    
    /**
     The `PlaylistTagDescriptor` describing this tag.
     
     Will be `PantosTag.UnknownTag` if we did not recognize the tag name.
     */
    public let tagDescriptor: PlaylistTagDescriptor
    
    /**
     The actual string name of the tag as found in the original HLS playlist.
     
     Is usually the same value as the `tagDescriptor`.
     
     Cases when it will be different:
     
     * When `tagDescriptor` is `PantosTag.UnknownTag`: This value will be set
     the value found in the HLS playlist.
     
     * When `tagDescriptor` is `PantosTag.Comment` or `PantosTag.Location`,
     this value will be nil.
     */
    public let tagName: MambaStringRef?
    
    /**
     The data associated with this tag as found in the original HLS Playlist.
     
     * If this tag is a `PantosTag.UnknownTag`, this value will be the data
     after the colon (or a zero-length string if there was no data after the colon).
     
     * If this tag is a `PantosTag.Comment` or `PantosTag.Location`, this value
     will be the entire comment or location.
     
     * For all other tags (including #EXTINF), this value will be the data after
     the colon (or a zero-length string if there was no data after the colon).
     
     Note that for `TagDescriptor`s of type .singleValue and .keyValue, the
     `tagData` will be further processed into our local `parsedValues` dictionary,
     and available for reading via the `value` functions and for writing to via
     the `set` function.
     */
    public let tagData: MambaStringRef
    
    /**
     Represents the duration of a segment in a EXTINF tag.
     
     Only valid for EXTINF tags, but used so frequently we have a special member variable for it. Will be kCMTimeInvalid if not EXTINF.
     */
    public let duration: CMTime
    
    /**
     Initializer for creating `Tags` while parsing HLS.
     
     - parameter tagDescriptor: An PlaylistTagDescriptor.
     
     - parameter tagData: The tag data as a `MambaStringRef`.
     
     - parameter tagName: The tag name as a `MambaStringRef`.
     
     - parameter parsedValues: If the tag has parsedValues, enter those here. Optional.
     
     - parameter duration: Duration in seconds for #EXTINF tags. Optional.
     */
    public init(tagDescriptor: PlaylistTagDescriptor,
                tagData: MambaStringRef,
                tagName: MambaStringRef,
                parsedValues: PlaylistTagDictionary? = nil,
                duration: CMTime = CMTime.invalid) {
        
        self.tagDescriptor = tagDescriptor
        self.tagData = tagData
        self.parsedValues = parsedValues
        self.tagName = tagName
        self.duration = duration
    }
    
    /**
     Initializer for creating `Tags` while parsing HLS. Specialized for tags that do not have tag
     names (i.e. PantosTag.Comment and PantosTag.Location)
     
     - parameter tagDescriptor: An PlaylistTagDescriptor.
     
     - parameter tagData: The tag data as a `MambaStringRef`.
     */
    public init(tagDescriptor: PlaylistTagDescriptor,
                tagData: MambaStringRef) {
        
        self.tagDescriptor = tagDescriptor
        self.tagData = tagData
        self.tagName = nil
        self.duration = CMTime.invalid
    }
    
    /**
     Convenience initializer for creating one-off tags on the fly (for inserting into parsed HLS playlists).
     
     - parameter tagDescriptor: An PlaylistTagDescriptor (we will not be expecting any "special" descriptors, such
     as PantosTag.Comment, PantosTag.Location, PantosTag.UnknownTag). We'll use the `toString()` function
     to make our local `tagName`.
     
     - parameter stringTagData: The tag data as a `String`. Optional.
     
     - parameter parsedValues: If your new tag needs parsedValues, enter those here.
     */
    public init(tagDescriptor: PlaylistTagDescriptor,
                stringTagData: String? = nil,
                parsedValues: PlaylistTagDictionary? = nil) {
        
        self.tagDescriptor = tagDescriptor
        self.tagName = MambaStringRef(descriptor: tagDescriptor)
        if let tagData = stringTagData {
            self.tagData = MambaStringRef(string: tagData)
        }
        else {
            self.tagData = MambaStringRef()
        }
        self.parsedValues = parsedValues
        self.isDirty = parsedValues != nil
        self.duration = CMTime.invalid
    }
    
    /**
     Get the scope of the tag descriptor for this tag.
     
     - returns: A PlaylistTagDescriptorScope.
     */
    public func scope() -> PlaylistTagDescriptorScope {
        return tagDescriptor.scope()
    }
    
    public func numberOfParsedValues() -> Int {
        return (parsedValues != nil) ? parsedValues!.count : 0
    }
    
    // MARK: Value getters
    
    /// An ordered collection of keys in the tag.
    /// This will be empty for tags with no values: locations, comments, EXTINF, and unknown tags.
    public var keys: ContiguousArray<String> {
        get {
            return parsedValues?.keys ?? ContiguousArray<String>()
        }
    }
    
    /**
     Get the PlaylistTagValueData of a possible data item in this tag if it exists.
     
     - parameter forKey: The key to use for the specified value, as a String. Note that there
     is a `TagValueIdentifier` version of this function that should be used if you know
     your `TagValueIdentifier`, for type safety.
     
     - returns: An optional PlaylistTagValueData.
     */
    public func valueData(forKey key: String) -> PlaylistTagValueData? {
        return parsedValues?[key]
    }
    
    /**
     Get the PlaylistTagValueData of a possible data item in this tag if it exists.
     
     - parameter forValueIdentifier: The key to use for the specified value, as a PlaylistTagValueIdentifier.
     
     - returns: An optional PlaylistTagValueData.
     */
    public func valueData(forValueIdentifier valueIdentifier: PlaylistTagValueIdentifier) -> PlaylistTagValueData? {
        return self.valueData(forKey: valueIdentifier.toString())
    }
    
    /**
     Get the String value of a possible data item in this tag if it exists.
     
     - parameter forKey: The key to use for the specified value, as a String. Note that there
     is a `TagValueIdentifier` version of this function that should be used if you know
     your `TagValueIdentifier`, for type safety.
     
     - returns: An optional String.
     */
    public func value(forKey key: String) -> String? {
        guard let parsedValues = parsedValues else {
            return nil
        }
        return parsedValues[key]?.value
    }
    
    /**
     Get the String value of a possible data item in this tag if it exists.
     
     - parameter forValueIdentifier: The key to use for the specified value, as a PlaylistTagValueIdentifier.
     
     - returns: An optional String.
     */
    public func value(forValueIdentifier valueIdentifier: PlaylistTagValueIdentifier) -> String? {
        return self.value(forKey: valueIdentifier.toString())
    }
    
    /**
     Get the typed value (where the type is a FailableStringLiteralConvertible) of a possible data item in this tag if it exists.
     
     - parameter forValueIdentifier: The key to use for the specified value, as a PlaylistTagValueIdentifier.
     
     - returns: An optional FailableStringLiteralConvertible.
     */
    public func value<T:FailableStringLiteralConvertible>(forValueIdentifier valueIdentifier: PlaylistTagValueIdentifier) -> T? {
        let val: T? = self.value(forKey: valueIdentifier.toString())
        return val
    }
    
    /**
     Get the typed value (where the type is a FailableStringLiteralConvertible) of a possible data item in this tag if it exists.
     
     - parameter forKey: The key to use for the specified value, as a String. Note that there
     is a `TagValueIdentifier` version of this function that should be used if you know
     your `TagValueIdentifier`, for type safety.
     
     - returns: An optional FailableStringLiteralConvertible.
     */
    public func value<T: FailableStringLiteralConvertible>(forKey valueKey: String) -> T? {
        guard let stringValue: String = self.value(forKey: valueKey) else {
            return nil
        }
        
        return T(string: stringValue)
    }
    
    // MARK: Value setters
    
    /**
     Set the String value of a data item for this tag, overwriting it if it exists
     
     - parameter value: The value to set to the key for this tag
     
     - parameter forKey: The key to use for the specified value, as a String. Note that there
     is a `TagValueIdentifier` version of this function that should be used if you know
     your `TagValueIdentifier`, for type safety.
     
     - parameter shouldBeQuoteEscaped: The default behavior for this value (should it be quote
     escaped or not). (Optional - if not specified, will take the quote escaping behaviour of
     the previous value or `false` if this is a new value)
     */
    public mutating func set(value: String,
                             forKey key: String,
                             shouldBeQuoteEscaped quoteEscaped: Bool? = nil) {
        guard let _ = parsedValues else {
            assertionFailure("Attempted to set a value \"\(value)\" for key \"\(key)\" on a tag that does not have parsed values - descriptor:\(tagDescriptor.toString()) tagBody:\(tagData)")
            return
        }
        let valueData = PlaylistTagValueData(value: value,
                                             quoteEscaped: quoteEscaped ?? parsedValues![key]?.quoteEscaped ?? false )
        parsedValues![key] = valueData
    }
    
    /**
     Set the String value of a data item for this tag, overwriting it if it exists
     
     - parameter value: The value to set to the key for this tag
     
     - parameter forValueIdentifier: The key to use for the specified value, as a PlaylistTagValueIdentifier.
     
     - parameter shouldBeQuoteEscaped: The default behavior for this value (should it be quote
     escaped or not). (Optional - if not specified, will take the quote escaping behaviour of
     the previous value or `false` if this is a new value)
     */
    public mutating func set(value: String,
                             forValueIdentifier valueIdentifier: PlaylistTagValueIdentifier,
                             shouldBeQuoteEscaped quoteEscaped: Bool? = nil) {
        self.set(value: value,
                 forKey: valueIdentifier.toString(),
                 shouldBeQuoteEscaped: quoteEscaped)
    }
    
    /**
     Remove a value for a key in this tag.
     
     - parameter forKey: The key to use for the specified value, as a String. Note that there
     is a `TagValueIdentifier` version of this function that should be used if you know
     your `TagValueIdentifier`, for type safety.
     */
    public mutating func removeValue(forKey key: String) {
        guard let _ = parsedValues else {
            assertionFailure("Attempted to remove the value for key \"\(key)\" on a tag that does not have parsed values - descriptor:\(tagDescriptor.toString()) tagBody:\(tagData)")
            return
        }
        parsedValues!.removeValue(forKey: key)
    }
    
    /**
     Remove a value for a key in this tag.
     
     - parameter forValueIdentifier: The key to use for the specified value, as a PlaylistTagValueIdentifier.
     */
    public mutating func removeValue(forValueIdentifier valueIdentifier: PlaylistTagValueIdentifier) {
        self.removeValue(forKey: valueIdentifier.toString())
    }
    
    private var parsedValues: PlaylistTagDictionary? = nil {
        didSet {
            isDirty = true
        }
    }
    /// true if our parsedValues has been modified since initial set, false otherwise
    internal private(set) var isDirty: Bool = false
    
    public var debugDescription: String {
        return "Tag tagDescriptor:\(tagDescriptor.toString()) tagData:\(tagData.stringValue())\n tagName:\((tagName == nil) ? "nil tagName" : tagName!.stringValue())\n       parsedValues:\(String(describing: parsedValues)) isDirty:\(isDirty)"
    }
}

extension PlaylistTag: Equatable {}

private let emptyStringRef = MambaStringRef()

public func ==(lhs: PlaylistTag, rhs: PlaylistTag) -> Bool {
    
    let lhsTagName: MambaStringRef = lhs.tagName ?? emptyStringRef
    let rhsTagName: MambaStringRef = rhs.tagName ?? emptyStringRef
    
    return lhs.tagDescriptor == rhs.tagDescriptor &&
        lhsTagName == rhsTagName &&
        lhs.tagData == rhs.tagData
}

extension PlaylistTag: Hashable {
    public var hashValue: Int {
        if let tagName = tagName {
            return tagData.hashValue ^ tagName.hashValue ^ tagDescriptor.hashValue
        }
        else {
            return tagData.hashValue ^ tagDescriptor.hashValue
        }
    }
}
