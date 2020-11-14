//
//  StaticMemoryStorage.h
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

#import <Foundation/Foundation.h>

/**
 Minimal memory storage wrapper.
 
 This class takes a NSData instance and makes a static copy of the memory for reference.
 
 StaticMemoryStorage will allocate and deallocate this memory on initialization and deinitialization,
 respectively.
 
 This is done so that mamba can construct `HLSStringRef` objects that refer to this static memory
 storage. See `HLSPlaylistCore` for where we keep a reference to this `StaticMemoryStorage` object.
 */
@interface StaticMemoryStorage : NSObject

/**
 Instantiates an StaticMemoryStorage with the contents of the provided NSData.
 This will make a static copy of the data in the NSData object, owned by the StaticMemoryStorage.
 */
- (instancetype _Nonnull)initWithData:(NSData * _Nonnull)data;

/**
 Instantiates an empty StaticMemoryStorage. `length` and `bytes` will be zero.
 */
- (instancetype _Nonnull)init;

/**
 Length of the internal buffer in bytes.
 */
@property (nonatomic, readonly) NSUInteger length;

/**
 A pointer to the start of the memory buffer that this class wraps.
 
 @warning You cannot access memory before `bytes` or after `bytes` + `length - 1` safely.
 
 @warning You must not modify memory in this area. This is a read-only object.
 */
@property (nonatomic, readonly) const void * _Nullable bytes;

@end
