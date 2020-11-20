//
//  HLSStringRefFactory.m
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

#import "HLSStringRefFactory.h"

#import "HLSStringRef_ConcreteUnownedBytes.h"
#import "HLSStringRef_ConcreteNSString.h"
#import "HLSStringRef_ConcreteNSData.h"

@implementation HLSStringRefFactory

- (id)init {
    return (id)[[HLSStringRef_ConcreteNSString alloc] initWithString:[NSString string]];
}

- (id)initWithBytesNoCopy:(const char *)bytes length:(NSUInteger)length {
    return (id)[[HLSStringRef_ConcreteUnownedBytes alloc] initWithBytesNoCopy:bytes length:length];
}

- (id)initWithData:(NSData *)data {
    return (id)[[HLSStringRef_ConcreteNSData alloc] initWithData:data];
}

- (id)initWithString:(NSString *)string {
    return (id)[[HLSStringRef_ConcreteNSString alloc] initWithString:string];
}

- (id)initWithURL:(NSURL *)url {
    return (id)[[HLSStringRef_ConcreteNSData alloc] initWithURL:url];
}

- (id)initWithHLSStringRef:(HLSStringRef *)relativeURL relativeToURL:(NSURL *)baseUrl {
    return (id)[[HLSStringRef_ConcreteNSData alloc] initWithHLSStringRef:relativeURL relativeToURL:baseUrl];
}

@end
