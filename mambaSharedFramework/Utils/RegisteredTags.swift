//
//  RegisteredTags.swift
//  mamba
//
//  Created by David Coufal on 7/12/16.
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
 This struct is the mechanism to register and deregister arbitrary PlaylistTagDescriptor and
 PlaylistTagValueIdentifier objects to support arbitrary playlist tag types.
 */
public struct RegisteredTags: CustomDebugStringConvertible {
    
    /**
     Register a `PlaylistTagDescriptor` type to support new tags
     
     - parameter tagDescriptorType: The type of the PlaylistTagDescriptor (i.e. `PantosTag.self`)
     */
    public mutating func register(tagDescriptorType: PlaylistTagDescriptor.Type) {
        registeredTagDescriptors.append(tagDescriptorType)
    }
    
    /**
     Unregister all registered `PlaylistTagDescriptor`s (the base level Pantos spec will still be supported)
     */
    public mutating func unRegisterAllTagDescriptors() {
        registeredTagDescriptors = registeredTagDescriptors.filter { $0 == PantosTag.self }
    }
    
    /**
     Get a PlaylistTagDescriptor based on the tag name (could return nil if no match is made)
     
     - parameter fromStringRef: The name of the tag (i.e. "EXT-X-VERSION")
     */
    public func tagDescriptor(fromStringRef tagName: MambaStringRef) -> PlaylistTagDescriptor? {
        for tagType in registeredTagDescriptors {
            if let tag = tagType.constructDescriptor(fromStringRef: tagName) {
                return tag
            }
        }
        return nil
    }
    
    /**
     Get a PlaylistTagParser based on a PlaylistTagDescriptor
     
     - parameter forTag: The PlaylistTagDescriptor to be parsed
     */
    public func parser(forTag tag: PlaylistTagDescriptor) -> PlaylistTagParser {
        for tagType in registeredTagDescriptors {
            if let parser = tagType.parser(forTag: tag) {
                return parser
            }
        }
        assertionFailure("Could not find a parser for tag \(tag.toString())")
        return NoOpTagParser()
    }
    
    /**
     Get a PlaylistTagWriter based on a PlaylistTagDescriptor
     
     - parameter forTag: The PlaylistTagDescriptor to be parsed
     */
    public func writer(forTag tag: PlaylistTagDescriptor) -> PlaylistTagWriter? {
        for tagType in registeredTagDescriptors {
            if let writer = tagType.writer(forTag: tag) {
                return writer
            }
        }
        // It's a programming error to have a dirty tag that does not have a registered writer.
        // It means that a different registeredTags was used to write than was used to parse, or
        // that semantics have changed and a previously un-editable tag can be edited.
        // In either case, it should fail to write rather than writing an incorrect playlist.
        assertionFailure("Could not find a writer for tag \(tag.toString())")
        return nil
    }
    
    /**
     Get a PlaylistTagValidator based on a PlaylistTagDescriptor
     
     - parameter forTag: The PlaylistTagDescriptor to be parsed
     */
    public func validator(forTag tag: PlaylistTagDescriptor) -> PlaylistTagValidator? {
        for tagType in registeredTagDescriptors {
            if let validator = tagType.validator(forTag: tag) {
                return validator
            }
        }
        return nil
    }
    
    public init() {
        registeredTagDescriptors.append(PantosTag.self)
    }
    
    internal fileprivate(set) var registeredTagDescriptors = [PlaylistTagDescriptor.Type]()
    
    public var debugDescription: String {
        return "RegisteredTags registeredTagDescriptors:\(registeredTagDescriptors)\n"
    }
}

public protocol RegisteredTagsProvider {
    var registeredTags: RegisteredTags { get }
}
