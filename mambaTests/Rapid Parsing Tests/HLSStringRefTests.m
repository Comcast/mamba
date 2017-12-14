//
//  HLSStringRefTests.m
//  mamba
//
//  Created by David Coufal on 2/3/17.
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

#import <XCTest/XCTest.h>
#import "HLSStringRef.h"

static const char *numberTestBytes = "1.7435XHGSH2.4536";
static const char *testBytes = "TEST.DATA.TEST";
static const int32_t testTimescale = 100000;

@interface HLSStringRefTests : XCTestCase

@end

@implementation HLSStringRefTests

- (void)testInitFromBytes {
    
    HLSStringRef * test = [[HLSStringRef alloc] initWithBytesNoCopy:testBytes length:4];
    HLSStringRef * data = [[HLSStringRef alloc] initWithBytesNoCopy:testBytes + 5 length:4];
    
    XCTAssert([@"TEST" isEqualToString:[test stringValue]], @"Did not find an equal string");
    XCTAssert([@"DATA" isEqualToString:[data stringValue]], @"Did not find an equal string");
}

- (void)testInitFromData {
    
    NSString *testString = @"Test String";
    
    NSData *data = [testString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *testData = [NSMutableData dataWithData:data];
    
    HLSStringRef *fromDataOwn = [[HLSStringRef alloc] initWithData:testData];
    
    // changing the underlying data
    static const char b = 'B';
    [testData replaceBytesInRange:NSMakeRange(0, 1) withBytes:&b length:1];

    // when we change the underlying data, we expect the `owned` string ref to change (since we are just pointing to the original data)
    
    XCTAssert(![testString isEqualToString:[fromDataOwn stringValue]], @"Did not find an equal string");
    XCTAssert([@"Best String" isEqualToString:[fromDataOwn stringValue]], @"Did not find an equal string");
}

- (void)testInitFromString {
    
    NSString *testString = @"Test String";
    
    HLSStringRef *testRef = [[HLSStringRef alloc] initWithString:testString];
    
    XCTAssert([testString isEqualToString:[testRef stringValue]], @"Did not find an equal string");
}

- (void)testInitFromURL {
    __block HLSStringRef *stringRef = nil;
    
    @autoreleasepool {
        NSURL *baseURL = [NSURL URLWithString:@"https://not.a.server.nowhere/media/manifest.m3u8"];
        // By creating a relative URL, we ensure that memory is dynamically allocated for the URL's storage.
        // Thus, we should see a crash in a use-after-free case, whereas a URL that points to a static string
        // might return a pointer that would still be valid even after it is "freed".
        NSURL *url = [NSURL URLWithString:@"variants/low.m3u8" relativeToURL:baseURL];
        stringRef = [[HLSStringRef alloc] initWithURL:url];
    }
    
    // The string ref must access every byte of the string to compute the hash value.
    // If there is a use-after-free bug, it should crash here.
    XCTAssert(stringRef.hash > 0, @"invalid hash value");
}

- (void)testEquality {
    
    HLSStringRef * test1 = [[HLSStringRef alloc] initWithBytesNoCopy:testBytes length:4];
    HLSStringRef * data = [[HLSStringRef alloc] initWithBytesNoCopy:testBytes + 5 length:4];
    HLSStringRef * test2 = [[HLSStringRef alloc] initWithBytesNoCopy:testBytes + 10 length:4];

    XCTAssert([test1 isEqualToStringRef:test2], @"Did not find an equal string");
    XCTAssert([test2 isEqualToStringRef:test1], @"Did not find an equal string");
    XCTAssert([test1 hash] == [test2 hash], @"Did not find an equal hash");

    XCTAssertFalse([test1 isEqualToStringRef:data], @"Should not be equal");
    XCTAssertFalse([data isEqualToStringRef:test1], @"Should not be equal");
    XCTAssertFalse([data hash] == [test2 hash], @"hash should not be equal");
}

- (void)testSegmentDurationValueConversion {
    
    HLSStringRef * str1_7 = [[HLSStringRef alloc] initWithBytesNoCopy:numberTestBytes length:3];
    HLSStringRef * str1_7435a = [[HLSStringRef alloc] initWithBytesNoCopy:numberTestBytes length:6];
    HLSStringRef * str1_7435b = [[HLSStringRef alloc] initWithBytesNoCopy:numberTestBytes length:8];
    HLSStringRef * str0_0 = [[HLSStringRef alloc] initWithBytesNoCopy:numberTestBytes + 10 length:7];
    HLSStringRef * str2_4 = [[HLSStringRef alloc] initWithBytesNoCopy:numberTestBytes + 11 length:3];
    HLSStringRef * str2_4536a = [[HLSStringRef alloc] initWithBytesNoCopy:numberTestBytes + 11 length:6];
    HLSStringRef * str2_4536b = [[HLSStringRef alloc] initWithBytesNoCopy:numberTestBytes + 11 length:7]; // includes the built in ending null
    
    double d1_7 = CMTimeGetSeconds([str1_7 EXTINFSegmentDuration]);
    double d1_7435a = CMTimeGetSeconds([str1_7435a EXTINFSegmentDuration]);
    double d1_7435b = CMTimeGetSeconds([str1_7435b EXTINFSegmentDuration]);
    double d0_0 = CMTimeGetSeconds([str0_0 EXTINFSegmentDuration]);
    double d2_4 = CMTimeGetSeconds([str2_4 EXTINFSegmentDuration]);
    double d2_4536a = CMTimeGetSeconds([str2_4536a EXTINFSegmentDuration]);
    double d2_4536b = CMTimeGetSeconds([str2_4536b EXTINFSegmentDuration]);
    
    XCTAssert(d1_7 == 1.7, @"Unexpected return value");
    XCTAssert(d1_7435a == 1.7435, @"Unexpected return value");
    XCTAssert(isnan(d1_7435b), @"Unexpected return value");
    XCTAssert(isnan(d0_0), @"Unexpected return value");
    XCTAssert(d2_4 == 2.4, @"Unexpected return value");
    XCTAssert(d2_4536a == 2.4536, @"Unexpected return value");
    XCTAssert(d2_4536b == 2.4536, @"Unexpected return value");
}

- (void)testCMTimePreciseConversion {
    static const char *tag1 = "2.002,1";
    
    HLSStringRef *tag1String = [[HLSStringRef alloc] initWithBytesNoCopy:tag1 length:strlen(tag1)];
    
    XCTAssert(CMTIME_IS_VALID([tag1String EXTINFSegmentDuration]), @"Tag 1 string should return valid CMTime");
    
    CMTime converted = CMTimeConvertScale([tag1String EXTINFSegmentDuration], testTimescale, kCMTimeRoundingMethod_Default);
    XCTAssertFalse(CMTIME_HAS_BEEN_ROUNDED(converted), @"Tag 1 should not be rounded going to longer timescale");
    XCTAssertEqual(200200, converted.value, @"Tag 1 CMTime was not precise");
    
}

- (void)testCMTimeInteger {
    static const char *tag = "2,2";
    HLSStringRef *tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag length:strlen(tag)];
    XCTAssert(CMTIME_IS_VALID([tagString EXTINFSegmentDuration]), @"Integer with comment string should return valid CMTime");
    
    CMTime converted = CMTimeConvertScale([tagString EXTINFSegmentDuration], testTimescale, kCMTimeRoundingMethod_Default);
    XCTAssertFalse(CMTIME_HAS_BEEN_ROUNDED(converted), @"Integer with comment should not be rounded going to longer timescale");
    XCTAssertEqual(200000, converted.value, @"Integer with comment CMTime was not precise");
}

- (void)testCMTimeInvalidString {
    static const char *invalid = ".002,1";
    HLSStringRef *invalidString = [[HLSStringRef alloc] initWithBytesNoCopy:invalid length:strlen(invalid)];
    XCTAssert(CMTIME_IS_INVALID([invalidString EXTINFSegmentDuration]), @"Invalid string should return invalid CMTime");
    
    static const char *empty = "";
    HLSStringRef *emptyString = [[HLSStringRef alloc] initWithBytesNoCopy:empty length:strlen(empty)];
    XCTAssert(CMTIME_IS_INVALID([emptyString EXTINFSegmentDuration]), @"Empty string should return invalid CMTime");
}

- (void)testCMTimeLongString {
    static const char *longTag = "2.002,this is a pretty long comment";
    HLSStringRef *longTagString = [[HLSStringRef alloc] initWithBytesNoCopy:longTag length:strlen(longTag)];
    XCTAssert(CMTIME_IS_VALID([longTagString EXTINFSegmentDuration]), @"Long tag string should return valid CMTime");
    
    CMTime converted = CMTimeConvertScale([longTagString EXTINFSegmentDuration], testTimescale, kCMTimeRoundingMethod_Default);
    XCTAssertFalse(CMTIME_HAS_BEEN_ROUNDED(converted), @"Long tag should not be rounded going to longer timescale");
    XCTAssertEqual(200200, converted.value, @"Long tag CMTime was not precise");
}

- (void)testCMTimeLongFraction {
    static const char *tag = "0.123456789";
    static const int64_t tagValue = 123456789;
    static const int64_t tagValueTimescale = 1000000000; // tagValue / tagValueTimescale == seconds
    
    HLSStringRef *tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag length:strlen(tag)];
    CMTime time = [tagString EXTINFSegmentDuration];
    
    XCTAssert(CMTIME_IS_VALID(time));
    XCTAssert(CMTIME_IS_NUMERIC(time));
    XCTAssertFalse(CMTIME_HAS_BEEN_ROUNDED(time));
    XCTAssertGreaterThan(time.value, 0);
    if (time.timescale > 0) {
        int64_t adjustedTagValue = tagValue / (tagValueTimescale / time.timescale);
        XCTAssertEqual(time.value, adjustedTagValue);
    }
    else {
        XCTFail(@"Invalid timescale");
    }
}

- (void)testCMTimeTruncation {
    static const char *tag = "1.23456789"; // decimal place is intentional to avoid rounding with any timescale >= 10^5
    static const int64_t tagValue = 123456789;
    static const int64_t tagValueTimescale = 100000000; // tagValue / tagValueTimescale == seconds
    
    HLSStringRef *tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag length:strlen(tag)];
    
    CMTime time = [tagString EXTINFSegmentDuration];
    XCTAssert(CMTIME_IS_VALID(time), @"Long number should produce a valid CMTime");
    XCTAssertFalse(CMTIME_HAS_BEEN_ROUNDED(time), "Long number should not have been rounded"); // this assumes that timescale >= 1000
    if (time.timescale > 0) {
        int64_t adjustedTagValue = tagValue / (tagValueTimescale / time.timescale); // truncates tagValue to the same precision that time uses
        XCTAssertEqual(time.value, adjustedTagValue, @"Truncated tag value was not as expected");
    }
    else {
        XCTFail(@"Invalid timescale");
    }
}

- (void)testCMTimeIntegerTruncation {
    static const char *tag = "123456789";
    static const int64_t truncatedTagValue = 1234567; // truncated after 7 bytes as per documentation
    
    HLSStringRef *tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag length:strlen(tag)];
    
    CMTime time = [tagString EXTINFSegmentDuration];
    XCTAssert(CMTIME_IS_VALID(time), @"Truncated integer time should be valid");
    XCTAssertFalse(CMTIME_HAS_BEEN_ROUNDED(time), @"Truncated integer time should not have been rounded");
    XCTAssertEqual(truncatedTagValue * time.timescale, time.value, @"Truncated integer time did not match expected value");
}

- (void)testCMTimeRejectsNegativeNumbers {
    static const char *tag = "-2.002,test";
    HLSStringRef *tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag length:strlen(tag)];
    XCTAssert(CMTIME_IS_INVALID([tagString EXTINFSegmentDuration]), @"Should return an invalid time on negative numbers");
}

- (void)testCMTimeRejectsSomeBrokenNumbers {
    static const char *tag = "2-002,test";
    HLSStringRef *tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag length:strlen(tag)];
    XCTAssert(CMTIME_IS_INVALID([tagString EXTINFSegmentDuration]), @"Should return an invalid time on specific nonsense numbers");
    
    static const char *tag2 = "2.-002,test";
    tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag2 length:strlen(tag2)];
    XCTAssert(CMTIME_IS_INVALID([tagString EXTINFSegmentDuration]), @"Should return an invalid time on specific nonsense numbers");
    
    static const char *tag3 = "-.002,test";
    tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag3 length:strlen(tag3)];
    XCTAssert(CMTIME_IS_INVALID([tagString EXTINFSegmentDuration]), @"Should return an invalid time on specific nonsense numbers");
    
    static const char *tag4 = "1234.";
    tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag4 length:strlen(tag4)];
    XCTAssert(CMTIME_IS_INVALID([tagString EXTINFSegmentDuration]), @"Should return an invalid time on specific nonsense numbers");
    
    static const char *tag5 = "-";
    tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag5 length:strlen(tag5)];
    XCTAssert(CMTIME_IS_INVALID([tagString EXTINFSegmentDuration]), @"Should return an invalid time on specific nonsense numbers");
}

- (void)testCMTimeAcceptStringWithoutComments {
    static const char *tag = "10";
    static const int64_t tagValue = 10;
    HLSStringRef *tagString = [[HLSStringRef alloc] initWithBytesNoCopy:tag length:strlen(tag)];
    
    CMTime time = [tagString EXTINFSegmentDuration];
    XCTAssert(CMTIME_IS_VALID(time), @"String without comments should return valid time");
    XCTAssertEqual(tagValue * time.timescale, time.value, @"String without comments did not return expected value");
}

- (void)testEmptyString {
    
    HLSStringRef * empty1 = [[HLSStringRef alloc] init];
    HLSStringRef * empty2 = [[HLSStringRef alloc] init];
    
    XCTAssert([empty1 isEqualToStringRef:empty2], @"Empty strings should be equal");
    XCTAssert([empty1 isEqualToString:@""], @"Empty strings should be equal");
    
    XCTAssert([empty1 hash] == [empty2 hash], @"hash should be equal");
    
    XCTAssert(empty1.length == 0, @"Empty strings should have 0 length");
    // not safe to test the bytes because HLSStringRef makes no guarantee of null termination
    
    NSString *emptyString = [empty1 stringValue];
    
    XCTAssert(emptyString.length == 0, @"Empty strings should have 0 length");
}

- (void)testNSStringEquality {
    
    HLSStringRef * test = [[HLSStringRef alloc] initWithBytesNoCopy:testBytes length:4];
    HLSStringRef * data = [[HLSStringRef alloc] initWithBytesNoCopy:testBytes + 5 length:4];
    
    NSString * test_str = @"TEST";
    NSString * dummy_str = @"DUMMY";
    
    XCTAssert([test isEqualToString:test_str], @"Expecting equality");
    XCTAssertFalse([data isEqualToString:test_str], @"Expecting inequality");
    XCTAssertFalse([test isEqualToString:dummy_str], @"Expecting inequality");
    XCTAssertFalse([data isEqualToString:test_str], @"Expecting inequality");
    XCTAssertFalse([data isEqualToString:dummy_str], @"Expecting inequality");
}

- (void)testInEquality {
    
    NSString * string = @"testing";
    HLSStringRef * test = [[HLSStringRef alloc] initWithString:string];
    
    XCTAssertFalse([test isEqual: string], @"Should return false when compared with other types.");
}

@end
