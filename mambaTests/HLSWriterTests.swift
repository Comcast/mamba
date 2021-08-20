//
//  HLSWriterTests.swift
//  mamba
//
//  Created by David Coufal on 7/13/16.
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

class HLSWriterTests: XCTestCase {
    
    let roundTripTestFixture = "hls_writer_parser_roundtrip_tester.txt"
    let positionOfSEQUENCETag = 66 // the position of a #EXT-X-MEDIA-SEQUENCE tag in the playlist
    
    // MARK: Test Success Paths
    
    func testWriterParserRoundTrip_String() {
        guard let hlsString = FixtureLoader.loadAsString(fixtureName: roundTripTestFixture as NSString) else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        do {
            let writer = HLSWriter(suppressMambaIdentityString: true)
            let playlist = parsePlaylist(inString: hlsString)
            
            let stream = OutputStream.toMemory()
            stream.open()
            try writer.write(hlsPlaylist: playlist, toStream: stream)
            guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
                XCTFail("No data written in write from HLSWriter")
                return
            }
            let hlsOut = String(data: data, encoding: .utf8)!
            stream.close()

            XCTAssert(hlsOut == hlsString, "Incoming HLS not identical to Output HLS")
        }
        catch {
            XCTAssert(false, "Exception was thrown while parsing: \(error)")
        }
    }
    
    
    // MARK: Test Failure Paths

    func testWriterParserRoundTrip_StringFailure() {
        guard let hlsString = FixtureLoader.loadAsString(fixtureName: roundTripTestFixture as NSString) else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let stream = OutputStream.toMemory()
        stream.open()
        do {
            let writer = HLSWriter()
            var playlist = parsePlaylist(inString: hlsString)
            
            // remove a required value to force a failure of the writer
            XCTAssert(playlist.tags[positionOfSEQUENCETag].tagDescriptor == PantosTag.EXT_X_MEDIA_SEQUENCE, "If this fails, the \"\(roundTripTestFixture)\" fixture has been edited so that a EXT_X_MEDIA_SEQUENCE tag is no longer in the \(positionOfSEQUENCETag)st spot. Adjust the number so that we grab the correct tag.")
            
            var tag = playlist.tags[positionOfSEQUENCETag]
            
            tag.removeValue(forValueIdentifier: PantosValue.sequence)
            // we have to have a single value for a single-value tag, so replace the removed sequence number with this dummy value
            tag.set(value: "dummy_value", forKey: "dummy_key")
            
            playlist.delete(atIndex: positionOfSEQUENCETag)
            playlist.insert(tag: tag, atIndex: positionOfSEQUENCETag)

            try writer.write(hlsPlaylist: playlist, toStream: stream)

            XCTAssert(false, "Expecting an exception")
        }
        catch OutputStreamError.invalidData(_) {
            // expected
        }
        catch {
            XCTAssert(false, "Exception was thrown while parsing: \(error)")
        }
        stream.close()
    }
    
    func testCustomIdentityString() {
        guard let hlsString = FixtureLoader.loadAsString(fixtureName: "hls_singleMediaFile.txt" as NSString) else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        do {
            let sampleIdentityString = " Sample Ident String"
            let writer = HLSWriter(identityString: sampleIdentityString)
            let playlist = parsePlaylist(inString: hlsString)
            
            let stream = OutputStream.toMemory()
            stream.open()
            try writer.write(hlsPlaylist: playlist, toStream: stream)
            guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
                XCTFail("No data written in write from HLSWriter")
                return
            }
            let hlsOut = String(data: data, encoding: .utf8)!
            stream.close()
            
            XCTAssert(hlsOut.hasPrefix("#EXTM3U\n#\(sampleIdentityString)\n\(standardMambaString)"))
        }
        catch {
            XCTAssert(false, "Exception was thrown while parsing: \(error)")
        }
    }
    
    func testMambaStandardString() {
        guard let hlsString = FixtureLoader.loadAsString(fixtureName: "hls_singleMediaFile.txt" as NSString) else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        do {
            let writer = HLSWriter()
            let playlist = parsePlaylist(inString: hlsString)
            
            let stream = OutputStream.toMemory()
            stream.open()
            try writer.write(hlsPlaylist: playlist, toStream: stream)
            guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
                XCTFail("No data written in write from HLSWriter")
                return
            }
            let hlsOut = String(data: data, encoding: .utf8)!
            stream.close()
            
            XCTAssert(hlsOut.hasPrefix("#EXTM3U\n\(standardMambaString)"))
        }
        catch {
            XCTAssert(false, "Exception was thrown while parsing: \(error)")
        }
    }
    
    let standardMambaString = "# Generated by Mamba(\(FrameworkInfo.version)) Copyright (c) 2017 Comcast Corporation\n"
}
