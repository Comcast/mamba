//
//  CMTimeMakeFromString.h
//  mamba
//
//  Created by Andrew Morrow on 8/7/17.
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

#ifndef CMTimeMakeFromString_h
#define CMTimeMakeFromString_h

#include <CoreMedia/CMTime.h>

/**
 Interprets a CMTime value from string.
 @param string A null-terminated UTF-8 string from which to read the CMTime value.
 @param decimal_places The number of figures after the decimal place to be preserved. Must be [0-9] (inclusive).
 @param remainder An optional pointer. If remainder is non-null, a pointer to the first unrecognized character will be stored on output.
 This value will be set even if an invalid time is returned.
 @return A CMTime value, or an invalid CMTime if the string could not be interpreted. Use CMTIME_IS_VALID to check. A zero-length
 string is considered invalid.
 @note Leading whitespace will be ignored. This function does not check for over/underflow, as the 64-bit value of CMTime is unlikely to overflow.
 The format recognized by this function can be described with the following regular expression.
 @code \s*-?[0-9]+(\.[0-9]+)?
 */
CMTime mamba_CMTimeMakeFromString(const char * _Nullable string, uint8_t decimal_places, const char * _Nullable * _Nullable remainder);

#endif /* CMTimeMakeFromString_h */
