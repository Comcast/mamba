//
//  HLSStringRef_ConcreteUnownedBytes.m
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

#import "HLSStringRef_ConcreteUnownedBytes.h"

@interface HLSStringRef_ConcreteUnownedBytes ()

@property (nonatomic, assign, readonly, nonnull) const char *bytes;

@end

@implementation HLSStringRef_ConcreteUnownedBytes

@synthesize length=_length;

- (instancetype)initWithBytesNoCopy:(const char *)bytes length:(NSUInteger)length {
    self = [self init];
    if (self) {
        _bytes = bytes;
        _length = length;
    }
    return self;
}

- (const char *)UTF8Bytes {
    return self.bytes;
}

@end
