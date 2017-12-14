//
//  HLSTagParserMock.swift
//  mamba
//
//  Created by David Coufal on 8/8/16.
//  Copyright © 2016 Comcast Corporation.
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

@testable import mamba

public enum HLSTagString_ThirdParty1: String {
    
    case EXT_THIRD_PARTY1_1 = "EXT-THIRD-PARTY1-1"
    case EXT_THIRD_PARTY1_2 = "EXT-THIRD-PARTY1-2"
}

extension HLSTagString_ThirdParty1: HLSTagDescriptor {

    
    public static func constructTag(tag: String) -> HLSTagDescriptor? {
        return HLSTagString_ThirdParty1(rawValue: tag)
    }
    
    public func toString() -> String {
        return self.rawValue
    }
    
    public func isEqual(toTagDescriptor tagDescriptor: HLSTagDescriptor) -> Bool {
        guard let third1 = tagDescriptor as? HLSTagString_ThirdParty1 else {
            return false
        }
        return third1.rawValue == self.rawValue
    }
    
    public static func parser(forTag tag: HLSTagDescriptor) -> HLSTagParser? {
        guard let thirdpartytag = HLSTagString_ThirdParty1(rawValue: tag.toString()) else {
            return nil
        }
        switch thirdpartytag {
        case .EXT_THIRD_PARTY1_1:
            return EXT_THIRD_PARTY1_1TagParser(tag: tag)
        case .EXT_THIRD_PARTY1_2:
            return EXT_THIRD_PARTY1_2TagParser(tag: tag)
        }
    }
    
    public static func writer(forTag tag: HLSTagDescriptor) -> HLSTagWriter? {
        return nil
    }
    
    public static func validator(forTag tag: HLSTagDescriptor) -> HLSTagValidator? {
        return nil
    }
    
    public func scope() -> HLSTagDescriptorScope {
        return .unknown
    }
    
    public func type() -> HLSTagDescriptorType {
        return .keyValue
    }
    
    public static func constructDescriptor(fromStringRef string: HLSStringRef) -> HLSTagDescriptor? {
        var tagName = string.stringValue()
        tagName.remove(at: tagName.startIndex)
        return constructTag(tag: tagName)
    }
}

// MARK: HLSTagString_ThirdParty2

public enum HLSTagString_ThirdParty2: String {
    
    case EXT_THIRD_PARTY2_1 = "EXT-THIRD-PARTY2-1"
}

extension HLSTagString_ThirdParty2: HLSTagDescriptor {
    
    public static func constructTag(tag: String) -> HLSTagDescriptor? {
        return HLSTagString_ThirdParty2(rawValue: tag)
    }
    
    public func toString() -> String {
        return self.rawValue
    }
    
    public func isEqual(toTagDescriptor tagDescriptor: HLSTagDescriptor) -> Bool {
        guard let third2 = tagDescriptor as? HLSTagString_ThirdParty2 else {
            return false
        }
        return third2.rawValue == self.rawValue
    }
    
    public static func parser(forTag tag: HLSTagDescriptor) -> HLSTagParser? {
        guard let thirdpartytag = HLSTagString_ThirdParty2(rawValue: tag.toString()) else {
            return nil
        }
        switch thirdpartytag {
        case .EXT_THIRD_PARTY2_1:
            return EXT_THIRD_PARTY2_1TagParser(tag: tag)
        }
    }
    
    public static func writer(forTag tag: HLSTagDescriptor) -> HLSTagWriter? {
        return nil
    }
    
    public static func validator(forTag tag: HLSTagDescriptor) -> HLSTagValidator? {
        return nil
    }
    
    public func scope() -> HLSTagDescriptorScope {
        return .unknown
    }
    
    public func type() -> HLSTagDescriptorType {
        return .keyValue
    }
    
    public static func constructDescriptor(fromStringRef string: HLSStringRef) -> HLSTagDescriptor? {
        var tagName = string.stringValue()
        tagName.remove(at: tagName.startIndex)
        return constructTag(tag: tagName)
    }
}

// MARK: HLSTagValueIdentifier_ThirdParty

public enum HLSTagValueIdentifier_ThirdParty: String {
    
    case Value1 = "VALUE1"
    case Value2 = "VALUE2"
    case Value3 = "VALUE3"
}

extension HLSTagValueIdentifier_ThirdParty: HLSTagValueIdentifier {
    public func toString() -> String {
        return self.rawValue
    }
}

// MARK: EXT_THIRD_PARTY1_1TagParser

class EXT_THIRD_PARTY1_1TagParser: HLSTagParser {
    
    let tag: HLSTagDescriptor
    
    required init(tag: HLSTagDescriptor) {
        self.tag = tag
    }
    
    func parseTag(fromTagString string: String?) throws -> HLSTagDictionary {
        
        do {
            return try GenericDictionaryTagParserHelper.parseTag(fromParsableString: string,
                                                                 tag: tag)
            
        }
        catch {
            throw error
        }
    }
}

// MARK: EXT_THIRD_PARTY1_2TagParser

class EXT_THIRD_PARTY1_2TagParser: HLSTagParser {
    
    let tag: HLSTagDescriptor
    
    required init(tag: HLSTagDescriptor) {
        self.tag = tag
    }
    
    func parseTag(fromTagString string: String?) throws -> HLSTagDictionary {
        
        do {
            return try GenericDictionaryTagParserHelper.parseTag(fromParsableString: string,
                                                                 tag: tag)
            
        }
        catch {
            throw error
        }
    }
}

// MARK: EXT_THIRD_PARTY2_1TagParser

class EXT_THIRD_PARTY2_1TagParser: HLSTagParser {
    
    let tag: HLSTagDescriptor
    
    required init(tag: HLSTagDescriptor) {
        self.tag = tag
    }
    
    func parseTag(fromTagString string: String?) throws -> HLSTagDictionary {
        
        do {
            return try GenericDictionaryTagParserHelper.parseTag(fromParsableString: string,
                                                                 tag: tag)
            
        }
        catch {
            throw error
        }
    }
}
