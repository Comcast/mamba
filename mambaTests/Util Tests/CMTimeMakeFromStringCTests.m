//
//  CMTimeMakeFromStringCTests.m
//  mamba
//
//  Created by David Coufal on 10/2/18.
//  Copyright © 2018 Comcast Corporation.
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

#import <XCTest/XCTest.h>
@import mamba;

@interface CMTimeMakeFromStringCTests : XCTestCase

@end

@implementation CMTimeMakeFromStringCTests

- (void)testCommaRemainder {
    const char *c = "1.0,";
    const char *remainder = NULL;
    CMTime time = mamba_CMTimeMakeFromString(c, 5, &remainder);
    XCTAssert(CMTIME_IS_NUMERIC(time));
    XCTAssert(time.value == 100000);
    XCTAssert(strcmp(remainder, ",") == 0);
}

- (void)testWordRemainder {
    const char *c = "1.0word";
    const char *remainder = NULL;
    CMTime time = mamba_CMTimeMakeFromString(c, 5, &remainder);
    XCTAssert(CMTIME_IS_NUMERIC(time));
    XCTAssert(time.value == 100000);
    XCTAssert(strcmp(remainder, "word") == 0);
}

- (void)testNullRemainder {
    const char *c = "1.0\0";
    const char *remainder = NULL;
    CMTime time = mamba_CMTimeMakeFromString(c, 5, &remainder);
    XCTAssert(CMTIME_IS_NUMERIC(time));
    XCTAssert(time.value == 100000);
    XCTAssert(strcmp(remainder, "\0") == 0);
}

@end
