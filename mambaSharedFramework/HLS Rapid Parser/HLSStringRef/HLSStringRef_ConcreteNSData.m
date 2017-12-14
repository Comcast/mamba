//
//  HLSStringRef_ConcreteNSData.m
//  mamba
//
//  Created by Andrew Morrow on 3/14/17.
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

#import "HLSStringRef_ConcreteNSData.h"

@interface HLSStringRef_ConcreteNSData ()

@property (nonatomic, readonly, nonnull) NSData *internalData;

@end

@implementation HLSStringRef_ConcreteNSData

@synthesize length=_length;

- (instancetype)initWithData:(NSData *)data {
    self = [self init];
    if (self) {
        _internalData = data;
        _length = data.length;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    return self = [self initWithData:url.absoluteURL.dataRepresentation];
}

- (instancetype)initWithHLSStringRef:(HLSStringRef *)relativeURL relativeToURL:(NSURL *)baseUrl {
    NSURL *absoluteURL = CFBridgingRelease(CFURLCreateAbsoluteURLWithBytes(kCFAllocatorDefault, (const UInt8 *)[relativeURL UTF8Bytes], relativeURL.length, kCFStringEncodingUTF8, (__bridge CFURLRef)baseUrl, NO));
    if (absoluteURL == nil) {
        return self = nil;
    }
    else {
        return self = [self initWithURL:absoluteURL];
    }
}

- (const char *)UTF8Bytes {
    return self.internalData.bytes;
}

- (NSString *)stringValue {
    return [[NSString alloc] initWithData:self.internalData encoding:NSUTF8StringEncoding];
}

@end
