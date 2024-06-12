//
//  RapidParserNewTagCallbacks.h
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

#ifndef RapidParserCallback_h
#define RapidParserCallback_h

#include <stdbool.h>
#include <stdint.h>

void NewTagCallback(const void *parentparser, const uint64_t startTagName, const uint64_t endTagName, const uint64_t startTagData, const uint64_t endTagData);
void NewTagNoDataCallback(const void *parentparser, const uint64_t startTagName, const uint64_t endTagName);
void NewEXTINFTagNoDataCallback(const void *parentparser, const uint64_t startTagName, const uint64_t endTagName, const uint64_t startDuration, const uint64_t endDuration, const uint64_t startTagData, const uint64_t endTagData);
void NewCommentCallback(const void *parentparser, const uint64_t startComment, const uint64_t endComment);
// return true to NewURLCallback to continue scanning, false to trigger an early exit and stop the parse
bool NewURLCallback(const void *parentparser, const uint64_t startURL, const uint64_t endURL);
void ParseComplete(const void *parentparser);
void ParseError(const void *parentparser, const uint32_t errorNum, const char *errorString);

#endif /* RapidParserCallback_h */
