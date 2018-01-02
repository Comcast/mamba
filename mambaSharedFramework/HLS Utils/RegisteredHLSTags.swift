//
//  RegisteredHLSTags.swift
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
 This struct is the mechanism to register and deregister arbitrary HLSTagDescriptor and
 HLSTagValueIdentifier objects to support arbitrary HLS tag types.
 */
public struct RegisteredHLSTags: CustomDebugStringConvertible {
    
    /**
     Register a `HLSTagDescriptor` type to support new tags
     
     - parameter tagDescriptorType: The type of the HLSTagDescriptor (i.e. `PantosTag.self`)
     */
    public mutating func register(tagDescriptorType: HLSTagDescriptor.Type) {
        registeredTagDescriptors.append(tagDescriptorType)
    }
    
    /**
     Unregister all registered `HLSTagDescriptor`s (the base level Pantos spec will still be supported)
     */
    public mutating func unRegisterAllHLSTagDescriptors() {
        registeredTagDescriptors = registeredTagDescriptors.filter { $0 == PantosTag.self }
    }
    
    /**
     Get a HLSTagDescriptor based on the tag name (could return nil if no match is made)
     
     - parameter fromStringRef: The name of the tag (i.e. "EXT-X-VERSION")
     */
    public func tagDescriptor(fromStringRef tagName: HLSStringRef) -> HLSTagDescriptor? {
        for tagType in registeredTagDescriptors {
            if let tag = tagType.constructDescriptor(fromStringRef: tagName) {
                return tag
            }
        }
        return nil
    }
    
    /**
     Get a HLSTagParser based on a HLSTagDescriptor
     
     - parameter forTag: The HLSTagDescriptor to be parsed
     */
    public func parser(forTag tag: HLSTagDescriptor) -> HLSTagParser {
        for tagType in registeredTagDescriptors {
            if let parser = tagType.parser(forTag: tag) {
                return parser
            }
        }
        assertionFailure("Could not find a parser for tag \(tag.toString())")
        return NoOpTagParser()
    }
    
    /**
     Get a HLSTagWriter based on a HLSTagDescriptor
     
     - parameter forTag: The HLSTagDescriptor to be parsed
     */
    public func writer(forTag tag: HLSTagDescriptor) -> HLSTagWriter? {
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
     Get a HLSTagValidator based on a HLSTagDescriptor
     
     - parameter forTag: The HLSTagDescriptor to be parsed
     */
    public func validator(forTag tag: HLSTagDescriptor) -> HLSTagValidator? {
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
    
    internal fileprivate(set) var registeredTagDescriptors = [HLSTagDescriptor.Type]()
    
    public var debugDescription: String {
        return "RegisteredHLSTags registeredTagDescriptors:\(registeredTagDescriptors)\n"
    }
}

public protocol RegisteredHLSTagsProvider {
    var registeredTags: RegisteredHLSTags { get }
}
