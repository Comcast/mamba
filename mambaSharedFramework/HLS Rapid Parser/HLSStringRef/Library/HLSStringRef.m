//
//  HLSStringRef.m
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

#import "HLSStringRef.h"
#import "HLSStringRefFactory.h"
#import "../../../HLS Utils/String Util/Library/CMTimeMakeFromString.h"

@interface HLSStringRef ()

@property (nonatomic, assign) NSUInteger hashCopy;
@property (nonatomic, nullable) NSString *stringCopy;

@end

@implementation HLSStringRef

// This method implements the class cluster magic and avoids double-allocations when returning subclass types from initWith...:
+ (id)allocWithZone:(struct _NSZone *)zone {
    if (self == [HLSStringRef class]) {
        static id factory = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            factory = [HLSStringRefFactory alloc];
        });
        return factory;
    }
    else {
        return [super allocWithZone:zone];
    }
}

#pragma mark Initializers

// This isn't actually called directly when you call [[HLSStringRef alloc] init]. Instead, the HLSStringRefFactory instantiates a concrete subclass.
// However, all concrete subclass initializers call this method.
- (instancetype)init {
    self = [super init];
    if (self) {
        _hashCopy = 0;
        _stringCopy = nil;
    }
    return self;
}

#pragma mark Subclass initializers

- (instancetype)initWithBytesNoCopy:(const char *)bytes length:(NSUInteger)length {
    [NSException raise:NSInvalidArgumentException format:@"subclasses must implement this method"];
    __builtin_unreachable();
}

- (instancetype)initWithData:(const NSData *)data {
    [NSException raise:NSInvalidArgumentException format:@"subclasses must implement this method"];
    __builtin_unreachable();
}

- (instancetype)initWithString:(const NSString *)string {
    [NSException raise:NSInvalidArgumentException format:@"subclasses must implement this method"];
    __builtin_unreachable();
}

- (instancetype)initWithURL:(const NSURL *)url {
    [NSException raise:NSInvalidArgumentException format:@"subclasses must implement this method"];
    __builtin_unreachable();
}

- (instancetype)initWithHLSStringRef:(HLSStringRef *)relativeURL relativeToURL:(NSURL *)baseUrl {
    [NSException raise:NSInvalidArgumentException format:@"subclasses must implement this method"];
    __builtin_unreachable();
}

#pragma mark Subclass Requirements

- (const char *)UTF8Bytes {
    [NSException raise:NSInvalidArgumentException format:@"subclasses must implement this method"];
    __builtin_unreachable();
}

#pragma mark Default implementations

// It is strongly suggested that your subclass override this method and provide a more efficient implementation.
- (NSString * _Nonnull)stringValue {
    if (self.stringCopy == nil) {
        self.stringCopy = [[NSString alloc] initWithBytes:[self UTF8Bytes]
                                                   length:self.length
                                                 encoding:NSUTF8StringEncoding];
    }
    return self.stringCopy;
}

// This method uses strictly fixed-point arithmetic to compute EXTINF segment durations.
// Using floating-point math can cause rounding errors on the order of .0001 seconds that make
// timelines non-continuous.
- (CMTime)EXTINFSegmentDuration {
    if (self.length == 0) {
        return kCMTimeInvalid;
    }
    
    // Clamp segment durations to 7 characters for efficiency. Unlikely to find a longer one in production.
    static const int clamping = 7;
    // Must null-terminate string
    char c[clamping + 1] = {0};
    memcpy(&c, [self UTF8Bytes], MIN(self.length, clamping));
    
    // Matches the limit of seven characters (one whole digit plus the decimal point plus five fractional digits)
    static const uint8_t decimalPlaces = 5;
    
    // Remainder gets set to the first unrecognized character
    const char *remainder = NULL;
    CMTime time = mamba_CMTimeMakeFromString(c, decimalPlaces, &remainder);
    
    // Negative times are disallowed
    if (CMTimeCompare(time, kCMTimeZero) < 0) {
        time = kCMTimeInvalid;
    }
    
    // time must be followed by a comma or end of string
    // otherwise, does not match EXTINF spec
    if (!(*remainder == ',' || *remainder == '\0')) {
        time = kCMTimeInvalid;
    }
    
    return time;
}

- (BOOL)isEqual:(id)object {
    // only compares with other HLSStringRefs to meet hashable requirements
    if ([object isKindOfClass:[HLSStringRef class]]) {
        return [self isEqualToStringRef:object];
    }
    return NO;
}

// Subclasses may override this method for efficiency if desired; however, the default implementation works for all cases.
// If you override this method, you must return true if and only if both string refs have identical UTF-8 representations.
- (BOOL)isEqualToStringRef:(HLSStringRef * _Nonnull)aStringRef {
    if (aStringRef.length != self.length) {
        return NO;
    }
    if (self.length == 0) {
        return YES;
    }
    return strncmp([self UTF8Bytes], [aStringRef UTF8Bytes], self.length) == 0;
}

- (BOOL)isEqualToString:(NSString * _Nonnull)aString {
    return strncmp([self UTF8Bytes], [aString UTF8String], self.length) == 0;
}

// Subclasses must not override this method.
- (NSUInteger)hash {
    if (self.hashCopy != 0) {
        return self.hashCopy;
    }
    // djb2 hash. http://www.cse.yorku.ca/~oz/hash.html
    NSUInteger hash = 5381;
    if (self.length == 0) {
        return hash;
    }
    NSUInteger result = 0;
    const char *position = [self UTF8Bytes];
    const char *end = position + self.length;
    while (position < end) {
        result = *position;
        hash = ((hash << 5) + hash) + result; /* hash * 33 + result */
        ++position;
    }
    self.hashCopy = hash;
    return hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ HASH:%lu", [self stringValue], (unsigned long)[self hash]];
}

- (id)debugQuickLookObject {
    return [self description];
}

@end
