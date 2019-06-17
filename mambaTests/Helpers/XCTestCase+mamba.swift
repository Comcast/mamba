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
    
    public func parseMasterPlaylist(inData data: Data,
                                    tagTypes: [PlaylistTagDescriptor.Type]? = nil,
                                    url: URL = fakePlaylistURL()) -> MasterPlaylist {
        let result = _parsePlaylist(inData: data, tagTypes: tagTypes, url: url)
        switch result {
        case .parseError(let error):
            assertionFailure("HLS Parse failed: \(error.localizedDescription)")
            break
        case .parsedMaster(let master):
            return master
        case .parsedVariant(_):
            assertionFailure("HLS Parse failed: Got variant instead of master)")
            break
        }
        // we've already stopped the test at this point
        return nil!
    }
    
    public func parseMasterPlaylist(inString playlistString: String,
                                    tagTypes: [PlaylistTagDescriptor.Type]? = nil,
                                    url: URL? = fakePlaylistURL()) -> MasterPlaylist {
        
        let data = playlistString.data(using: .utf8)
        
        return parseMasterPlaylist(inData: data!, tagTypes: tagTypes, url: url!)
    }
    
    public func parseMasterPlaylist(inFixtureName fixtureName: String,
                                    tagTypes: [PlaylistTagDescriptor.Type]? = nil,
                                    url: URL? = fakePlaylistURL()) -> MasterPlaylist {
        
        let data = FixtureLoader.load(fixtureName: fixtureName as NSString)
        
        return parseMasterPlaylist(inData: data! as Data, tagTypes: tagTypes, url: url!)
    }
    
    public func parseVariantPlaylist(inData data: Data,
                                     tagTypes: [PlaylistTagDescriptor.Type]? = nil,
                                     url: URL = fakePlaylistURL()) -> VariantPlaylist {
        let result = _parsePlaylist(inData: data, tagTypes: tagTypes, url: url)
        switch result {
        case .parseError(let error):
            assertionFailure("HLS Parse failed: \(error.localizedDescription)")
            break
        case .parsedVariant(let variant):
            return variant
        case .parsedMaster(_):
            assertionFailure("HLS Parse failed: Got master instead of variant)")
            break
        }
        // we've already stopped the test at this point
        return nil!
    }
    
    public func parseVariantPlaylist(inString playlistString: String,
                                     tagTypes: [PlaylistTagDescriptor.Type]? = nil,
                                     url: URL? = fakePlaylistURL()) -> VariantPlaylist {
        
        let data = playlistString.data(using: .utf8)
        
        return parseVariantPlaylist(inData: data!, tagTypes: tagTypes, url: url!)
    }
    
    public func parseVariantPlaylist(inFixtureName fixtureName: String,
                                     tagTypes: [PlaylistTagDescriptor.Type]? = nil,
                                     url: URL? = fakePlaylistURL()) -> VariantPlaylist {
        
        let data = FixtureLoader.load(fixtureName: fixtureName as NSString)
        
        return parseVariantPlaylist(inData: data! as Data, tagTypes: tagTypes, url: url!)
    }
    
    private func _parsePlaylist(inData data: Data,
                                tagTypes: [PlaylistTagDescriptor.Type]? = nil,
                                url: URL = fakePlaylistURL()) -> ParserResult {
        
        let parser = PlaylistParser(tagTypes: tagTypes)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: ParserResult? = nil
        
        parser.parse(playlistData: data,
                     url: url,
                     callback: { r in
                        result = r
                        semaphore.signal()
        })
        
        if semaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(2)) == .timedOut {
            print("Parse timeout in parseAndTestPlaylist in the \"\(String(describing: type(of: self)))\" unit test")
            assertionFailure()
        }
        
        return result!
    }
    
    public func writeToString(withTag tag: PlaylistTag, withWriter writer: PlaylistTagWriter) throws -> String {
        let stream = OutputStream.toMemory()
        stream.open()
        try writer.write(tag: tag, toStream: stream)
        guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            print("No data written in writeToString from PlaylistWriter \"\(String(describing: type(of: writer)))\" in unit test \"\(String(describing: type(of: self)))\" with tag \"\(tag)\"")
            XCTFail()
            return "FAILED_TO_WRITE_DATA"
        }
        stream.close()
        return String(data: data, encoding: .utf8)!
    }
}

public func createTag(tagDescriptor descriptor: PlaylistTagDescriptor, tagData: String, registeredPlaylistTags: RegisteredPlaylistTags? = nil) -> PlaylistTag {
    
    if descriptor == PantosTag.Location || descriptor == PantosTag.Comment {
        return PlaylistTag(tagDescriptor: descriptor, tagData: MambaStringRef(string: tagData))
    }
    if descriptor == PantosTag.EXTINF {
        let duration = MambaStringRef(string: tagData).extinfSegmentDuration()
        return PlaylistTag(tagDescriptor: descriptor,
                           tagData: MambaStringRef(string: tagData),
                           tagName: MambaStringRef(descriptor: descriptor),
                           parsedValues: nil,
                           duration: duration)
    }
    
    var parsedValues: PlaylistTagDictionary? = nil
    
    if descriptor.type() == .keyValue || descriptor.type() == .singleValue {
        let regTags: RegisteredPlaylistTags = (registeredPlaylistTags != nil) ? registeredPlaylistTags! : RegisteredPlaylistTags()
        
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
    
    return PlaylistTag(tagDescriptor: descriptor, stringTagData: tagData, parsedValues: parsedValues)
}

