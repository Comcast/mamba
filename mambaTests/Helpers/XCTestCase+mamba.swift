//
//  XCTestCase+mamba.swift
//  mamba
//
//  Created by David Coufal on 2/16/17.
//  Copyright © 2017 Comcast Cable Communications Management, LLC
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

extension XCTestCase {
    
    public func parseManifest(inFixtureName fixtureName: String,
                              tagTypes:[HLSTagDescriptor.Type]? = nil,
                              url: URL? = fakeManifestURL()) -> HLSManifest {
        
        let data = FixtureLoader.load(fixtureName: fixtureName as NSString)
        
        return parseManifest(inData: data! as Data, tagTypes: tagTypes, url: url!)
    }
    
    public func parseManifest(inString manifestString: String,
                              tagTypes:[HLSTagDescriptor.Type]? = nil,
                              url: URL? = fakeManifestURL()) -> HLSManifest {
        
        let data = manifestString.data(using: .utf8)
        
        return parseManifest(inData: data!, tagTypes: tagTypes, url: url!)
    }
    
    public func parseManifest(inData data: Data,
                              tagTypes:[HLSTagDescriptor.Type]? = nil,
                              url: URL = fakeManifestURL()) -> HLSManifest {
        
        let parser = HLSParser(tagTypes: tagTypes)
        
        var registeredTags = RegisteredHLSTags()
        if let tagTypes = tagTypes {
            for tagType in tagTypes {
                registeredTags.register(tagDescriptorType: tagType)
            }
        }
        
        let expectation = self.expectation(description: "parseAndTestManifest completion")
        
        var manifest: HLSManifest? = nil
        
        parser.parse(manifestData: data,
                     url: url,
                     success: { (m) in
                        manifest = m
                        expectation.fulfill()
        },
                     failure: { (error) in
                        print("Failure in parseAndTestManifest in the \"\(String(describing: type(of: self)))\" unit test. Error \(error.localizedDescription)")
                        XCTFail()
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in parseAndTestManifest in the \"\(String(describing: type(of: self)))\" unit test: \(error!)")
                XCTFail()
            }
        })
        
        return manifest!
    }
    
    public func parseManifests(inFirstString manifestString1: String,
                               inSecondString manifestString2: String) -> (manifest1: HLSManifest, manifest2: HLSManifest) {
        
        let data1 = manifestString1.data(using: .utf8)
        let data2 = manifestString2.data(using: .utf8)
        
        let expectation1 = self.expectation(description: "parseAndTestManifest1 completion")
        
        let parser = HLSParser()
        
        var manifest1: HLSManifest? = nil
        var manifest2: HLSManifest? = nil
        
        let url1 = fakeManifestURL()
        let url2 = fakeManifestURL()
        
        parser.parse(manifestData: data1!,
                     url: url1,
                     success: { (m) in
                        manifest1 = m
                        expectation1.fulfill()
        },
                     failure: { _ in
                        print("Failure in parseAndTestManifest 1 in the \"\(String(describing: type(of: self)))\" unit test")
                        XCTFail()
                        expectation1.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in parseAndTestManifest 1 in the \"\(String(describing: type(of: self)))\" unit test: \(error!)")
                XCTFail()
            }
        })
        
        let expectation2 = self.expectation(description: "parseAndTestManifest2 completion")
        
        parser.parse(manifestData: data2!,
                     url: url2,
                     success: { (m) in
                        manifest2 = m
                        expectation2.fulfill()
        },
                     failure: { _ in
                        print("Failure in parseAndTestManifest 1 in the \"\(String(describing: type(of: self)))\" unit test")
                        XCTFail()
                        expectation2.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in parseAndTestManifest 2 in the \"\(String(describing: type(of: self)))\" unit test: \(error!)")
                XCTFail()
            }
        })
        
        return (manifest1!, manifest2!)
    }
    
    public func writeToString(withTag tag: HLSTag, withWriter writer: HLSTagWriter) throws -> String {
        let stream = OutputStream.toMemory()
        stream.open()
        try writer.write(tag: tag, toStream: stream)
        guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            print("No data written in writeToString from HLSWriter \"\(String(describing: type(of: writer)))\" in unit test \"\(String(describing: type(of: self)))\" with tag \"\(tag)\"")
            XCTFail()
            return "FAILED_TO_WRITE_DATA"
        }
        stream.close()
        return String(data: data, encoding: .utf8)!
    }
    
    public func createManifest(fromTags tags: [HLSTag]) -> HLSManifest {
        return HLSManifest(url: fakeManifestURL(), tags: tags, registeredTags: RegisteredHLSTags(), hlsData: Data())
    }
}

public func createHLSTag(tagDescriptor descriptor: HLSTagDescriptor, tagData: String, registeredTags: RegisteredHLSTags? = nil) -> HLSTag {
    
    if descriptor == PantosTag.Location || descriptor == PantosTag.Comment {
        return HLSTag(tagDescriptor: descriptor, tagData: HLSStringRef(string: tagData))
    }
    if descriptor == PantosTag.EXTINF {
        let duration = HLSStringRef(string: tagData).extinfSegmentDuration()
        return HLSTag(tagDescriptor: descriptor,
                      tagData: HLSStringRef(string: tagData),
                      tagName: HLSStringRef(descriptor: descriptor),
                      parsedValues: nil,
                      duration: duration)
    }
    
    var parsedValues: HLSTagDictionary? = nil

    if descriptor.type() == .keyValue || descriptor.type() == .singleValue {
        let regTags: RegisteredHLSTags = (registeredTags != nil) ? registeredTags! : RegisteredHLSTags()
        
        let tagParser = regTags.parser(forTag: descriptor)
        if type(of: tagParser) != NoOpTagParser.self {
            do {
                parsedValues = try tagParser.parseTag(fromTagString: tagData)
            }
            catch {
                // we let these exceptions go.
                // some unit tests delibrately make unparsable tags to test validators
            }
        }
    }
    
    return HLSTag(tagDescriptor: descriptor, stringTagData: tagData, parsedValues: parsedValues)
}

