//
//  MambaStringRef_ConcreteNSString.m
//  mamba
//
//  Created by Andrew Morrow on 3/14/17.
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

#import "MambaStringRef_ConcreteNSString.h"

@interface MambaStringRef_ConcreteNSString ()

@property (nonatomic, readonly, nonnull) NSString *internalString;

@end

@implementation MambaStringRef_ConcreteNSString

@synthesize length=_length;

- (instancetype)initWithString:(NSString *)string {
    self = [self init];
    if (self) {
        _internalString = string;
        _length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (const char *)UTF8Bytes {
    return self.internalString.UTF8String;
}

- (NSString *)stringValue {
    return self.internalString;
}

@end
