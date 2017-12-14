//
//  ParseArrayTests.m
//  mamba
//
//  Created by David Coufal on 2/1/17.
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

#import <XCTest/XCTest.h>
#import "RapidParserState.h"
#import "RapidParserLineState.h"
#import "RapidParserMasterParseArray.h"
#import "HLSRapidParser.h"

static const NSInteger noHit = 0;
static const NSInteger newTag = 1;
static const NSInteger newNoDataTag = 2;
static const NSInteger newEXTINFTag = 3;
static const NSInteger newComment = 4;
static const NSInteger newURL = 5;
static const NSInteger completed = 6;
static const NSInteger foundError = 7;

@interface MockHLSRapidParser: HLSRapidParser

@property (nonatomic, assign) UInt64 startName;
@property (nonatomic, assign) UInt64 endName;
@property (nonatomic, assign) UInt64 startData;
@property (nonatomic, assign) UInt64 endData;
@property (nonatomic, assign) UInt64 startDuration;
@property (nonatomic, assign) UInt64 endDuration;
@property (nonatomic, assign) NSInteger hit;

@end

@implementation MockHLSRapidParser

- (void)clear {
    self.hit = noHit;
    self.startName = 0;
    self.endName = 0;
    self.startData = 0;
    self.endData = 0;
    self.startDuration = 0;
    self.endDuration = 0;
}

- (BOOL)isClear {
    return (self.hit == noHit &&
            self.startName == 0 &&
            self.endName == 0 &&
            self.startData == 0 &&
            self.endData == 0 &&
            self.startDuration == 0 &&
            self.endDuration == 0);
}

- (void)newTagWithStartTagName:(UInt64)startTagName endTagName:(UInt64)endTagName startTagData:(UInt64)startTagData endTagData:(UInt64)endTagData {
    self.hit = newTag;
    self.startName = startTagName;
    self.endName = endTagName;
    self.startData = startTagData;
    self.endData = endTagData;
}

- (void)newNoDataTagWithStartTagName:(UInt64)startTagName endTagName:(UInt64)endTagName {
    self.hit = newNoDataTag;
    self.startName = startTagName;
    self.endName = endTagName;
}

- (void)newEXTINFTagWithStartTagName:(UInt64)startTagName
                          endTagName:(UInt64)endTagName
                       startDuration:(UInt64)startDuration
                         endDuration:(UInt64)endDuration
                        startTagData:(UInt64)startTagData
                          endTagData:(UInt64)endTagData {
    self.hit = newEXTINFTag;
    self.startName = startTagName;
    self.endName = endTagName;
    self.startData = startTagData;
    self.endData = endTagData;
    self.startDuration = startDuration;
    self.endDuration = endDuration;
}

- (void)newCommentWithStart:(UInt64)startComment end:(UInt64)endComment {
    self.hit = newComment;
    self.startData = startComment;
    self.endData = endComment;
}

- (void)newURLWithStart:(UInt64)startURL end:(UInt64)endURL {
    self.hit = newURL;
    self.startData = startURL;
    self.endData = endURL;
}

- (void)parseComplete {
    self.hit = completed;
}

- (void)parseError:(NSString *)errorString errorNumber:(UInt32)errorNumber {
    self.hit = foundError;
}

@end

static const int64_t end = 100;
static const int64_t position = 80;
static const int64_t colonposition = 90;

@interface ParseArrayTests : XCTestCase

@end

@implementation ParseArrayTests

- (void)testArrays {
    
    struct LineState lineState;
    uint8_t newState = 0;
    MockHLSRapidParser *mockParser = [MockHLSRapidParser new];
    
    for(uint8_t state = Scanning; state < ErrorEarlyExit; state++) {
        for(unsigned char c = 0; c < 255; c++) {
            
            initializeLineState(&lineState);
            lineState.end = end;
            
            // to properly mock EXTINF, we have to set colon position
            if (state == LookingForNewlineForEXTINF && (c == '\n' || c == '\r')) {
                lineState.colonPosition = colonposition;
            }
            
            [mockParser clear];
            
            newState = (*masterParseArray[state][c]) ((__bridge const void *)(mockParser), c, position, state, &lineState);
            
            [self evaluateNewState:newState
                      andLineState:lineState
                     andMockParser:mockParser
                   forCurrentState:state
                      forCharacter:c];
        }
    }
}

- (void)evaluateNewState:(uint8_t)newState
            andLineState:(struct LineState)lineState
           andMockParser:(MockHLSRapidParser *)mockParser
         forCurrentState:(uint8_t)state
            forCharacter:(unsigned char)c {
    
    // state specific scanning rules:
    if (state == LookingForXForEXT && c == 'X') {
        XCTAssert(newState == LookingForEForEXT);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForEForEXT && c == 'E') {
        XCTAssert(newState == LookingForHashForEXT);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForHashForEXT && c == '#') {
        XCTAssert(newState == LookingForNewLineForEXT);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForNewLineForEXT && (c == '\n' || c == '\r')) {
        XCTAssert(newState == Scanning);
        XCTAssert(mockParser.hit == newNoDataTag);
        XCTAssert(mockParser.startName == position + 1);
        XCTAssert(mockParser.endName == end);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == position - 1);
        return;
    }
    if (state == LookingForNewLineForComment && (c == '\n' || c == '\r')) {
        XCTAssert(newState == Scanning);
        XCTAssert(mockParser.hit == newComment);
        XCTAssert(mockParser.startData == position + 1);
        XCTAssert(mockParser.endData == end);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == position - 1);
        return;
    }
    if (state == LookingForNForEXTINF && c == 'N') {
        XCTAssert(newState == LookingForIForEXTINF);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForIForEXTINF && c == 'I') {
        XCTAssert(newState == LookingForTForEXTINF);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForTForEXTINF && c == 'T') {
        XCTAssert(newState == LookingForXForEXTINF);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForXForEXTINF && c == 'X') {
        XCTAssert(newState == LookingForEForEXTINF);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForEForEXTINF && c == 'E') {
        XCTAssert(newState == LookingForHashForEXTINF);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForHashForEXTINF && c == '#') {
        XCTAssert(newState == LookingForNewlineForEXTINF);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (state == LookingForNewlineForEXTINF && (c == '\n' || c == '\r')) {
        XCTAssert(newState == Scanning);
        XCTAssert(mockParser.hit == newEXTINFTag);
        XCTAssert(mockParser.startData == colonposition + 1);
        XCTAssert(mockParser.endData == end);
        XCTAssert(mockParser.startDuration == colonposition + 1);
        XCTAssert(mockParser.endDuration == end);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == position - 1);
        return;
    }

    // normal scanning rules:
    if (c == '\n' || c == '\r') {
        XCTAssert(newState == Scanning);
        XCTAssert(mockParser.hit == newURL);
        XCTAssert(mockParser.startData == position + 1);
        XCTAssert(mockParser.endData == end);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == position - 1);
        return;
    }
    if (c == 'T') {
        XCTAssert(newState == LookingForXForEXT);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (c == 'F') {
        XCTAssert(newState == LookingForNForEXTINF);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (c == '#') {
        XCTAssert(newState == LookingForNewLineForComment);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (c == ':') {
        XCTAssert(newState == Scanning);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == position);
        XCTAssert(lineState.commaPosition == lineStateInvalidValue);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    if (c == ',') {
        XCTAssert(newState == Scanning);
        XCTAssert([mockParser isClear]);
        XCTAssert(lineState.colonPosition == lineStateInvalidValue);
        XCTAssert(lineState.commaPosition == position);
        XCTAssert(lineState.start == lineStateInvalidValue);
        XCTAssert(lineState.end == end);
        return;
    }
    XCTAssert(newState == Scanning, @"Failed for character %c and state %i", c, state);
    XCTAssert([mockParser isClear], @"Failed for character %c and state %i", c, state);
    XCTAssert(lineState.colonPosition == lineStateInvalidValue, @"Failed for character %c and state %i", c, state);
    XCTAssert(lineState.commaPosition == lineStateInvalidValue, @"Failed for character %c and state %i", c, state);
    XCTAssert(lineState.start == lineStateInvalidValue, @"Failed for character %c and state %i", c, state);
    XCTAssert(lineState.end == end, @"Failed for character %c and state %i", c, state);
}

- (void)testArrayForNewTag {
    
    [self runNewTagTestForNewlineChar:'\n'];
    [self runNewTagTestForNewlineChar:'\r'];
}

- (void)runNewTagTestForNewlineChar:(unsigned char)c {
    
    struct LineState lineState;
    uint8_t newState = 0;
    MockHLSRapidParser *mockParser = [MockHLSRapidParser new];
    uint8_t state = LookingForNewLineForEXT;
    
    initializeLineState(&lineState);
    lineState.end = end;
    lineState.colonPosition = colonposition;
    
    [mockParser clear];
    
    newState = (*masterParseArray[state][c]) ((__bridge const void *)(mockParser), c, position, state, &lineState);
    
    XCTAssert(newState == Scanning);
    XCTAssert(mockParser.hit == newTag);
    XCTAssert(mockParser.startName == position + 1);
    XCTAssert(mockParser.endName == colonposition - 1);
    XCTAssert(mockParser.startData == colonposition + 1);
    XCTAssert(mockParser.endData == end);
    XCTAssert(lineState.colonPosition == lineStateInvalidValue);
    XCTAssert(lineState.commaPosition == lineStateInvalidValue);
    XCTAssert(lineState.start == lineStateInvalidValue);
    XCTAssert(lineState.end == position - 1);
}

@end
