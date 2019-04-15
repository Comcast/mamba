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
    
    public func parsePlaylist(inFixtureName fixtureName: String,
                              tagTypes:[HLSTagDescriptor.Type]? = nil,
                              url: URL? = fakePlaylistURL()) -> HLSPlaylist {
        
        let data = FixtureLoader.load(fixtureName: fixtureName as NSString)
        
        return parsePlaylist(inData: data! as Data, tagTypes: tagTypes, url: url!)
    }
    
    public func parsePlaylist(inString playlistString: String,
                              tagTypes:[HLSTagDescriptor.Type]? = nil,
                              url: URL? = fakePlaylistURL()) -> HLSPlaylist {
        
        let data = playlistString.data(using: .utf8)
        
        return parsePlaylist(inData: data!, tagTypes: tagTypes, url: url!)
    }
    
    public func parsePlaylist(inData data: Data,
                              tagTypes:[HLSTagDescriptor.Type]? = nil,
                              url: URL = fakePlaylistURL()) -> HLSPlaylist {
        
        let parser = HLSParser(tagTypes: tagTypes)
        
        var registeredTags = RegisteredHLSTags()
        if let tagTypes = tagTypes {
            for tagType in tagTypes {
                registeredTags.register(tagDescriptorType: tagType)
            }
        }
        
        let expectation = self.expectation(description: "parseAndTestPlaylist completion")
        
        var playlist: HLSPlaylist? = nil
        
        parser.parse(playlistData: data,
                     url: url,
                     success: { (m) in
                        playlist = m
                        expectation.fulfill()
        },
                     failure: { (error) in
                        print("Failure in parseAndTestPlaylist in the \"\(String(describing: type(of: self)))\" unit test. Error \(error.localizedDescription)")
                        XCTFail()
                        expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in parseAndTestPlaylist in the \"\(String(describing: type(of: self)))\" unit test: \(error!)")
                XCTFail()
            }
        })
        
        return playlist!
    }
    
    public func parsePlaylists(inFirstString playlistString1: String,
                               inSecondString playlistString2: String) -> (playlist1: HLSPlaylist, playlist2: HLSPlaylist) {
        
        let data1 = playlistString1.data(using: .utf8)
        let data2 = playlistString2.data(using: .utf8)
        
        let expectation1 = self.expectation(description: "parseAndTestPlaylist1 completion")
        
        let parser = HLSParser()
        
        var playlist1: HLSPlaylist? = nil
        var playlist2: HLSPlaylist? = nil
        
        let url1 = fakePlaylistURL()
        let url2 = fakePlaylistURL()
        
        parser.parse(playlistData: data1!,
                     url: url1,
                     success: { (m) in
                        playlist1 = m
                        expectation1.fulfill()
        },
                     failure: { _ in
                        print("Failure in parseAndTestPlaylist 1 in the \"\(String(describing: type(of: self)))\" unit test")
                        XCTFail()
                        expectation1.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in parseAndTestPlaylist 1 in the \"\(String(describing: type(of: self)))\" unit test: \(error!)")
                XCTFail()
            }
        })
        
        let expectation2 = self.expectation(description: "parseAndTestPlaylist2 completion")
        
        parser.parse(playlistData: data2!,
                     url: url2,
                     success: { (m) in
                        playlist2 = m
                        expectation2.fulfill()
        },
                     failure: { _ in
                        print("Failure in parseAndTestPlaylist 1 in the \"\(String(describing: type(of: self)))\" unit test")
                        XCTFail()
                        expectation2.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {
            error in
            if (error != nil) {
                print("Parse timeout in parseAndTestPlaylist 2 in the \"\(String(describing: type(of: self)))\" unit test: \(error!)")
                XCTFail()
            }
        })
        
        return (playlist1!, playlist2!)
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
    
    public func createPlaylist(fromTags tags: [HLSTag]) -> HLSPlaylist {
        return HLSPlaylist(url: fakePlaylistURL(), tags: tags, registeredTags: RegisteredHLSTags(), hlsBuffer: MambaStaticMemoryBuffer())
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

