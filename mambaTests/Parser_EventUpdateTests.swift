//
//  Parser_EventUpdateTests.swift
//  mamba
//
//  Created by David Coufal on 3/13/19.
//  Copyright © 2019 Comcast Corporation.
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
//  limitations under the License. All rights reserved.
//

import Foundation

import XCTest
@testable import mamba

class Parser_EventUpdateTests: XCTestCase {
    
    let testURL1 = URL(string: "https://Parser_EventUpdateTests.nowhere/event_variant1.m3u8")!
    let testURL2 = URL(string: "https://Parser_EventUpdateTests.nowhere/event_variant2.m3u8")!
    
    func testEventVariantUpdateHappyPath() {
        
        // get an initial playlist
        var event1 = parseVariantPlaylist(inString: eventHLS1)
        event1.url = testURL1
        
        XCTAssertEqual(event1.tags.count, 15)
        
        // create a special parser that will always do an update on event style variants
        let parser = Parser(updateEventPlaylistParams: UpdateEventPlaylistParams(minimalBytesToTriggerUpdate: 0,
                                                                                    maximumAmountOfTimeBetweenUpdatesToTrigger: 60 * 60))
        let event2 = try! parser.update(eventVariantPlaylist: event1,
                                        withPlaylistData: eventHLS2.data(using: .utf8)!,
                                        atUrl: testURL1)
        
        XCTAssertEqual(event1.playlistMemoryStorage, event2.playlistMemoryStorage)
        XCTAssertEqual(event2.tags.count, 19)
        
        let event3 = try! parser.update(eventVariantPlaylist: event2,
                                        withPlaylistData: eventHLS3.data(using: .utf8)!,
                                        atUrl: testURL1)
        
        XCTAssertEqual(event1.playlistMemoryStorage, event3.playlistMemoryStorage)
        XCTAssertEqual(event3.tags.count, 27)
    }
    
    func testEventVariantUpdateHappyPath_NoChangeToPlaylist() {
        
        // get an initial playlist
        var event1 = parseVariantPlaylist(inString: eventHLS1)
        event1.url = testURL1
        
        XCTAssertEqual(event1.tags.count, 15)
        
        // create a special parser that will always do an update on event style variants
        let parser = Parser(updateEventPlaylistParams: UpdateEventPlaylistParams(minimalBytesToTriggerUpdate: 0,
                                                                                    maximumAmountOfTimeBetweenUpdatesToTrigger: 60 * 60))
        let event2 = try! parser.update(eventVariantPlaylist: event1,
                                        withPlaylistData: eventHLS1.data(using: .utf8)!,
                                        atUrl: testURL1)
        
        XCTAssertEqual(event1.playlistMemoryStorage, event2.playlistMemoryStorage)
        XCTAssertEqual(event2.tags.count, 15)
    }
    
    func testEventVariantUpdateFailDueToSizeDifference() {
        
        // get an initial playlist
        var event1 = parseVariantPlaylist(inString: eventHLS1)
        event1.url = testURL1
        
        XCTAssertEqual(event1.tags.count, 15)
        
        // create a special parser that will have a large playlist size required to trigger and update. this will fail the update on our small playlists
        let parser = Parser(updateEventPlaylistParams: UpdateEventPlaylistParams(minimalBytesToTriggerUpdate: 100000,
                                                                                    maximumAmountOfTimeBetweenUpdatesToTrigger: 60 * 60))
        let event2 = try! parser.update(eventVariantPlaylist: event1,
                                        withPlaylistData: eventHLS2.data(using: .utf8)!,
                                        atUrl: testURL1)
        
        XCTAssertNotEqual(event1.playlistMemoryStorage, event2.playlistMemoryStorage)
        XCTAssertEqual(event2.tags.count, 19)
    }
    
    func testEventVariantUpdateFailDueToTooMuchTimePassingBetweenUpdates() {
        
        // get an initial playlist
        var event1 = parseVariantPlaylist(inString: eventHLS1)
        event1.url = testURL1
        
        XCTAssertEqual(event1.tags.count, 15)
        
        // create a special parser that will have a very small 10 millisecond max time between updates before it will fail and just do a normal parse
        let parser = Parser(updateEventPlaylistParams: UpdateEventPlaylistParams(minimalBytesToTriggerUpdate: 0,
                                                                                    maximumAmountOfTimeBetweenUpdatesToTrigger: 0.010))
        
        usleep(20 * 1000) // sleep for 20 millseconds to trigger the failure
        
        let event2 = try! parser.update(eventVariantPlaylist: event1,
                                        withPlaylistData: eventHLS2.data(using: .utf8)!,
                                        atUrl: testURL1)
        
        XCTAssertNotEqual(event1.playlistMemoryStorage, event2.playlistMemoryStorage)
        XCTAssertEqual(event2.tags.count, 19)
    }
    
    func testEventVariantUpdateFailDueToNonEventStylePlaylist() {
        
        // get an initial playlist
        var vod1 = parseVariantPlaylist(inString: vodHLS1)
        vod1.url = testURL1
        
        XCTAssertEqual(vod1.tags.count, 11)
        
        // create a special parser that will always do an update on event style variants
        let parser = Parser(updateEventPlaylistParams: UpdateEventPlaylistParams(minimalBytesToTriggerUpdate: 0,
                                                                                    maximumAmountOfTimeBetweenUpdatesToTrigger: 60 * 60))
        
        let vod2 = try! parser.update(eventVariantPlaylist: vod1,
                                      withPlaylistData: vodHLS2.data(using: .utf8)!,
                                      atUrl: testURL1)
        
        XCTAssertNotEqual(vod1.playlistMemoryStorage, vod2.playlistMemoryStorage)
        XCTAssertEqual(vod2.tags.count, 15)
    }
    
    func testEventVariantUpdateFailDueToNonMatchingUrls() {
        
        // get an initial playlist
        var event1 = parseVariantPlaylist(inString: eventHLS1)
        event1.url = testURL1
        
        XCTAssertEqual(event1.tags.count, 15)
        XCTAssertEqual(event1.url, testURL1)
        
        // create a special parser that will always do an update on event style variants
        let parser = Parser(updateEventPlaylistParams: UpdateEventPlaylistParams(minimalBytesToTriggerUpdate: 0,
                                                                                    maximumAmountOfTimeBetweenUpdatesToTrigger: 60 * 60))
        
        let event2 = try! parser.update(eventVariantPlaylist: event1,
                                        withPlaylistData: eventHLS2.data(using: .utf8)!,
                                        atUrl: testURL2)
        
        XCTAssertNotEqual(event1.playlistMemoryStorage, event2.playlistMemoryStorage)
        XCTAssertEqual(event2.tags.count, 19)
        XCTAssertEqual(event2.url, testURL2)
        XCTAssertNotEqual(event2.url, testURL1)
    }
    
    func testEventVariantUpdateFailDueToMissingFragmentInfo() {
        
        // this test is just to exercise the "cannot find any fragments" error condition handling
        // in the real world we'd never expect a playlist like this
        
        // get an initial playlist
        var event1 = parseVariantPlaylist(inString: """
#EXTM3U
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXTINF:2.0,
missing.ts
""")
        event1.url = testURL1
        
        XCTAssertEqual(event1.tags.count, 5)

        // remove the last media group to simulate having no fragment
        event1.delete(atRange: event1.mediaSegmentGroups.first!.range)
        
        XCTAssertEqual(event1.tags.count, 3)
        
        // create a special parser that will always do an update on event style variants
        let parser = Parser(updateEventPlaylistParams: UpdateEventPlaylistParams(minimalBytesToTriggerUpdate: 0,
                                                                                    maximumAmountOfTimeBetweenUpdatesToTrigger: 60 * 60))
        
        let event2 = try! parser.update(eventVariantPlaylist: event1,
                                        withPlaylistData: eventHLS2.data(using: .utf8)!,
                                        atUrl: testURL1)
        
        XCTAssertNotEqual(event1.playlistMemoryStorage, event2.playlistMemoryStorage)
        XCTAssertEqual(event2.tags.count, 19)
    }
}

private let eventHLS1 = """
#EXTM3U
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXTINF:2.96130,
fileSequence0.ts
#EXTINF:2.96130,
fileSequence1.ts
#EXTINF:2.96129,
fileSequence2.ts
#EXTINF:2.96129,
fileSequence3.ts
#EXTINF:2.96130,
fileSequence4.ts
#EXTINF:2.96130,
fileSequence5.ts
"""

private let eventHLS2 = """
#EXTM3U
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXTINF:2.96130,
fileSequence0.ts
#EXTINF:2.96130,
fileSequence1.ts
#EXTINF:2.96129,
fileSequence2.ts
#EXTINF:2.96129,
fileSequence3.ts
#EXTINF:2.96130,
fileSequence4.ts
#EXTINF:2.96130,
fileSequence5.ts
#EXTINF:2.96129,
fileSequence6.ts
#EXTINF:2.96129,
fileSequence7.ts
"""

private let eventHLS3 = """
#EXTM3U
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXTINF:2.96130,
fileSequence0.ts
#EXTINF:2.96130,
fileSequence1.ts
#EXTINF:2.96129,
fileSequence2.ts
#EXTINF:2.96129,
fileSequence3.ts
#EXTINF:2.96130,
fileSequence4.ts
#EXTINF:2.96130,
fileSequence5.ts
#EXTINF:2.96129,
fileSequence6.ts
#EXTINF:2.96129,
fileSequence7.ts
#EXT-X-KEY:METHOD=AES-128,URI=\"https://not.a.server.nowhere/key.php?r=52\",IV=0x9c7db8778570d05c3177c349fd9236aa/
#EXTINF:2.96130,
fileSequence8.ts
#EXT-X-DISCONTINUITY
#EXTINF:2.96130,
fileSequence9.ts
#EXTINF:2.96129,
fileSequence10.ts
"""

private let vodHLS1 = """
#EXTM3U
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXTINF:2.96130,
fileSequence0.ts
#EXTINF:2.96130,
fileSequence1.ts
#EXTINF:2.96129,
fileSequence2.ts
#EXTINF:2.96129,
fileSequence3.ts
"""

private let vodHLS2 = """
#EXTM3U
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-TARGETDURATION:3
#EXT-X-VERSION:3
#EXTINF:2.96130,
fileSequence0.ts
#EXTINF:2.96130,
fileSequence1.ts
#EXTINF:2.96129,
fileSequence2.ts
#EXTINF:2.96129,
fileSequence3.ts
#EXTINF:2.96130,
fileSequence4.ts
#EXTINF:2.96130,
fileSequence5.ts
"""
