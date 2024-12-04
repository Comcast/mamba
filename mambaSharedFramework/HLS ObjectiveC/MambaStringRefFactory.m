//
//  MambaStringRefFactory.m
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

#import "MambaStringRefFactory.h"

#import "MambaStringRef_ConcreteUnownedBytes.h"
#import "MambaStringRef_ConcreteNSString.h"
#import "MambaStringRef_ConcreteNSData.h"

@implementation MambaStringRefFactory

- (id)init {
    return (id)[[MambaStringRef_ConcreteNSString alloc] initWithString:[NSString string]];
}

- (id)initWithBytesNoCopy:(const char *)bytes length:(NSUInteger)length {
    return (id)[[MambaStringRef_ConcreteUnownedBytes alloc] initWithBytesNoCopy:bytes length:length];
}

- (id)initWithData:(NSData *)data {
    return (id)[[MambaStringRef_ConcreteNSData alloc] initWithData:data];
}

- (id)initWithString:(NSString *)string {
    return (id)[[MambaStringRef_ConcreteNSString alloc] initWithString:string];
}

- (id)initWithURL:(NSURL *)url {
    return (id)[[MambaStringRef_ConcreteNSData alloc] initWithURL:url];
}

- (id)initWithMambaStringRef:(MambaStringRef *)relativeURL relativeToURL:(NSURL *)baseUrl {
    return (id)[[MambaStringRef_ConcreteNSData alloc] initWithMambaStringRef:relativeURL relativeToURL:baseUrl];
}

@end
