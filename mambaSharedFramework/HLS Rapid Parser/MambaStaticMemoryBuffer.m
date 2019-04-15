//
//  MambaStaticMemoryBuffer.m
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

#import "MambaStaticMemoryBuffer.h"

@implementation MambaStaticMemoryBuffer

- (instancetype)init {
    self = [super init];
    if (self) {
        _length = 0;
        _bytes = 0;
    }
    return self;
}

- (instancetype)initWithData:(const NSData *)data {
    self = [super init];
    if (self) {
        void *buffer = malloc(data.length);
        [data getBytes:buffer length:data.length];
        _bytes = buffer;
        _length = data.length;
    }
    return self;
}

- (void)dealloc
{
    if (_bytes > 0) {
        free((void *)_bytes);
        _bytes = 0;
    }
    _length = 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MambaStaticMemoryBuffer bytes:%lu length:%lu", (unsigned long)[self bytes], [self length]];
}

- (id)debugQuickLookObject {
    return [self description];
}

@end
