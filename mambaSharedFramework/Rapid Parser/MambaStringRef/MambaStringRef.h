//
//  MambaStringRef.h
//  mamba
//
//  Created by David Coufal on 1/19/17.
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

@import Foundation;
@import CoreMedia;

/**
 Minimal string class intended to minimize memory alloctions. Although it can wrap
 multiple types of data, it always exposes a UTF-8 byte array.
 
 Once allocated, this class is invariant. You cannot mutate the string in any way.
 */
@interface MambaStringRef : NSObject

+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 Instantiates an MambaStringRef referencing unowned memory containing a UTF-8 string.
 
 @warning If instantiated using this method, this class points to external memory, and depends
 on the caller to arrange for that memory to not be deallocated for the lifetime
 of this string. We do not hold a strong reference to that memory.
 If that memory is deallocated, that will likely result in a crash.
 */
- (instancetype _Nonnull)initWithBytesNoCopy:(const char * _Nonnull)bytes length:(NSUInteger)length;

/**
 Instantiates an MambaStringRef with the contents of the provided NSData.
 This creates a strong reference to the NSData instance.
 */
- (instancetype _Nonnull)initWithData:(NSData * _Nonnull)data;

/**
 Instantiates an MambaStringRef with the contents of the provided NSString.
 This creates a strong reference to the NSString instance.
 */
- (instancetype _Nonnull)initWithString:(NSString * _Nonnull)string;

/**
 Instantiates an MambaStringRef with the contents of the provided NSURL.
 If the provided NSURL is absolute, this creates a strong reference to the NSURL instance.
 Otherwise, it will create an absolute copy.
 */
- (instancetype _Nonnull)initWithURL:(NSURL * _Nonnull)url;

/**
 Instantiates an MambaStringRef with a base URL and a relative component.
 Neither object is retained.
 If an absolute URL cannot be formed, this will return nil.
 */
- (instancetype _Nullable)initWithMambaStringRef:(MambaStringRef * _Nonnull)relativeURL relativeToURL:(NSURL * _Nonnull)baseUrl;

/**
 Convenience initializer for an empty string.
 */
- (instancetype _Nonnull)init;

/**
 Returns the internal storage of the MambaStringRef.
 
 @discussion The lifetime of this buffer will be no longer than the owning MambaStringRef and may be shorter. You should not retain
 a reference to it outside of the calling scope.
 
 @warning This string is not null-terminated. You must not read more than `length` bytes. If you need a null-terminated C string,
 you must copy at most `length` bytes from this buffer and append the null character.
 
 @see length
 */
- (const char * _Nonnull)UTF8Bytes;

/**
 This may instantiate a new NSString and cause a copy of the data, so take care when calling.
 */
- (NSString * _Nonnull)stringValue;

/**
 Specialized value getter for segment duration values in #EXTINF tags.
 
 @return A CMTime representing the duration of the #EXTINF tag body stored in this string, or an invalid CMTime if the string does
 not conform to the EXTINF spec and could not be parsed.
 
 @warning If this string cannot be parsed, an invalid CMTime is returned. You can test a CMTime using the
 CMTIME_IS_VALID() and CMTIME_IS_INVALID() functions. Calling CMTimeGetSeconds() on an invalid time will return NaN (not 0).
 
 @discussion This method only examines the first 7 bytes of the string. In practice, EXTINF durations are usually shorter than 7
 characters (including the decimal place). If you require more precision, use a different method to parse.
 
 This method does not strictly enforce the EXTINF tag specification, but any string which conforms will be parsed
 correctly. This is not a general purpose "to double" method and rejects negative numbers amongst other valid doubles.
 */
- (CMTime)EXTINFSegmentDuration;

- (BOOL)isEqualToStringRef:(MambaStringRef * _Nonnull)aStringRef;
- (BOOL)isEqualToString:(NSString * _Nonnull)aString;

/**
 Length of the UTF-8 bytes.
 @see UTF8Bytes
 */
@property (nonatomic, readonly) NSUInteger length;

/**
 Hash value of the string.
 @warning This hash value will not match the value of underlying Foundation objects including NSData, NSString, and NSURL.
 */
@property (nonatomic, readonly) NSUInteger hash;

@end
