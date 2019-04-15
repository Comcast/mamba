//
//  MambaStaticMemoryBufferTests.m
//  mamba
//
//  Created by David Coufal on 4/15/19.
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

#import <XCTest/XCTest.h>
@import mamba;

@interface MambaStaticMemoryBufferTests : XCTestCase

@end

@implementation MambaStaticMemoryBufferTests

- (void)testMemoryCopy {
    NSData *data = [NSData dataWithBytes:"abcdefg" length:7];
    MambaStaticMemoryBuffer *buffer = [[MambaStaticMemoryBuffer alloc] initWithData:data];
    
    const char * databytes = data.bytes;
    const char * bufferbytes = buffer.bytes;

    XCTAssertEqual(databytes[0], bufferbytes[0]);
    XCTAssertEqual(databytes[1], bufferbytes[1]);
    XCTAssertEqual(databytes[2], bufferbytes[2]);
    XCTAssertEqual(databytes[3], bufferbytes[3]);
    XCTAssertEqual(databytes[4], bufferbytes[4]);
    XCTAssertEqual(databytes[5], bufferbytes[5]);
    XCTAssertEqual(databytes[6], bufferbytes[6]);
    
    XCTAssertEqual(data.length, buffer.length);
}

@end
