//
//  HLSRapidParser.m
//  mamba
//
//  Created by David Coufal on 1/19/17.
//  Copyright © 2017 Comcast Corporation.
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

#import "HLSRapidParser.h"
#import "HLSRapidParserCallback.h"
#import "RapidParserNewTagCallbacks.h"
#import "HLSStringRef.h"
#import "HLSRapidParserCallback.h"
#import "RapidParser.h"

#pragma mark HLSRapidParser Interface required for RapidParserNewTagCallbacks Implementations

@interface HLSRapidParser ()

- (void)newTagWithStartTagName:(UInt64)startTagName
                    endTagName:(UInt64)endTagName
                  startTagData:(UInt64)startTagData
                    endTagData:(UInt64)endTagData;
- (void)newNoDataTagWithStartTagName:(UInt64)startTagName
                          endTagName:(UInt64)endTagName;
- (void)newEXTINFTagWithStartTagName:(UInt64)startTagName
                          endTagName:(UInt64)endTagName
                       startDuration:(UInt64)startDuration
                         endDuration:(UInt64)endDuration
                        startTagData:(UInt64)startRemainingTagData
                          endTagData:(UInt64)endRemainingTagData;
- (void)newCommentWithStart:(UInt64)startComment
                        end:(UInt64)endComment;
- (void)newURLWithStart:(UInt64)startURL
                    end:(UInt64)endURL;
- (void)parseComplete;
- (void)parseError:(NSString *)errorString
       errorNumber:(UInt32)errorNumber;

@end

#pragma mark RapidParserNewTagCallbacks Implementations

/*
 These C functions are defined here to have access to some of HLSRapidParser's private data and methods
 */
void NewTagCallback(const void *parentparser, const uint64_t startTagName, const uint64_t endTagName, const uint64_t startTagData, const uint64_t endTagData) {
    HLSRapidParser *parser = (__bridge HLSRapidParser *)(parentparser);
    [parser newTagWithStartTagName:startTagName
                        endTagName:endTagName
                      startTagData:startTagData
                        endTagData:endTagData];
}

void NewTagNoDataCallback(const void *parentparser, const uint64_t startTagName, const uint64_t endTagName) {
    HLSRapidParser *parser = (__bridge HLSRapidParser *)(parentparser);
    [parser newNoDataTagWithStartTagName:startTagName endTagName:endTagName];
}

void NewEXTINFTagNoDataCallback(const void *parentparser, const uint64_t startTagName, const uint64_t endTagName, const uint64_t startDuration, const uint64_t endDuration, const uint64_t startTagData, const uint64_t endTagData) {
    HLSRapidParser *parser = (__bridge HLSRapidParser *)(parentparser);
    [parser newEXTINFTagWithStartTagName:startTagName
                              endTagName:endTagName
                           startDuration:startDuration
                             endDuration:endDuration
                            startTagData:startTagData
                              endTagData:endTagData];
}

void NewCommentCallback(const void *parentparser, const uint64_t startComment, const uint64_t endComment) {
    HLSRapidParser *parser = (__bridge HLSRapidParser *)(parentparser);
    [parser newCommentWithStart:startComment end:endComment];
}

void NewURLCallback(const void *parentparser, const uint64_t startURL, const uint64_t endURL) {
    HLSRapidParser *parser = (__bridge HLSRapidParser *)(parentparser);
    [parser newURLWithStart:startURL end:endURL];
}

void ParseComplete(const void *parentparser) {
    HLSRapidParser *parser = (__bridge HLSRapidParser *)(parentparser);
    [parser parseComplete];
}

void ParseError(const void *parentparser, const uint32_t errorNum, const char *errorString) {
    HLSRapidParser *parser = (__bridge HLSRapidParser *)(parentparser);
    NSString *error = [NSString stringWithUTF8String:errorString];
    [parser parseError:error errorNumber:errorNum];
}

#pragma mark HLSRapidParser Interface

@interface HLSRapidParser ()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, weak) id<HLSRapidParserCallback> callback;

@end

#pragma mark HLSRapidParser Implementation

@implementation HLSRapidParser

- (instancetype)init{
    self = [super init];
    if (self) {
        dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
        _queue = dispatch_queue_create("com.comcast.mamba.HLSRapidParser", qosAttribute);
    }
    return self;
}

#pragma mark Main Parser Method

- (void)parseHLSData:(NSData * _Nonnull)data callback:(id<HLSRapidParserCallback> _Nonnull)callback {
    
    self.data = data;
    self.callback = callback;
    
    const unsigned char *bytes = [data bytes];
    const uint64_t length = [data length];
    
    dispatch_async(self.queue, ^{
        parseHLS((__bridge const void *)(self), bytes, length);
    });
}

#pragma mark Fast C Parser callbacks

/*
 These should all be called on the tagHandlingQueue.
 */

- (void)newTagWithStartTagName:(UInt64)startTagName
                    endTagName:(UInt64)endTagName
                  startTagData:(UInt64)startTagData
                    endTagData:(UInt64)endTagData {
    
    HLSStringRef *tagName = [[HLSStringRef alloc] initWithBytesNoCopy:[self.data bytes] + startTagName length:(NSUInteger)(endTagName - startTagName + 1)];
    HLSStringRef *tagData = [[HLSStringRef alloc] initWithBytesNoCopy:[self.data bytes] + startTagData length:(NSUInteger)(endTagData - startTagData + 1)];
    
    [self.callback addedTagWithName:tagName value:tagData];
}

- (void)newNoDataTagWithStartTagName:(UInt64)startTagName
                          endTagName:(UInt64)endTagName {
    
    HLSStringRef *tagName = [[HLSStringRef alloc] initWithBytesNoCopy:[self.data bytes] + startTagName length:(NSUInteger)(endTagName - startTagName + 1)];
    
    [self.callback addedNoValueTagWithName:tagName];
}

- (void)newEXTINFTagWithStartTagName:(UInt64)startTagName
                          endTagName:(UInt64)endTagName
                       startDuration:(UInt64)startDuration
                         endDuration:(UInt64)endDuration
                        startTagData:(UInt64)startTagData
                          endTagData:(UInt64)endTagData {
    
    HLSStringRef *tagName = [[HLSStringRef alloc] initWithBytesNoCopy:[self.data bytes] + startTagName length:(NSUInteger)(endTagName - startTagName + 1)];
    HLSStringRef *duration = [[HLSStringRef alloc] initWithBytesNoCopy:[self.data bytes] + startDuration length:(NSUInteger)(endDuration - startDuration + 1)];
    HLSStringRef *tagData = [[HLSStringRef alloc] initWithBytesNoCopy:[self.data bytes] + startTagData length:(NSUInteger)(endTagData - startTagData + 1)];
    
    [self.callback addedEXTINFTagWithName:tagName
                                 duration:duration
                                    value:tagData];
}

- (void)newCommentWithStart:(UInt64)startComment
                        end:(UInt64)endComment {
    
    HLSStringRef *comment = [[HLSStringRef alloc] initWithBytesNoCopy:[self.data bytes] + startComment length:(NSUInteger)(endComment - startComment + 1)];
    
    [self.callback addedCommentLine:comment];
}

- (void)newURLWithStart:(UInt64)startURL
                    end:(UInt64)endURL {
    
    HLSStringRef *url = [[HLSStringRef alloc] initWithBytesNoCopy:[self.data bytes] + startURL length:(NSUInteger)(endURL - startURL + 1)];
        
    [self.callback addedURLLine:url];
}

- (void)parseComplete {
    [self.callback parseComplete];
    self.data = nil;
    self.callback = nil;
}

- (void)parseError:(NSString *)errorString
       errorNumber:(UInt32)errorNumber {
    [self.callback parseError:errorString errorNumber:errorNumber];
    self.data = nil;
    self.callback = nil;
}

@end
