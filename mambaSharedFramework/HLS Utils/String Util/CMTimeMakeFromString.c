//
//  CMTimeMakeFromString.c
//  mamba
//
//  Created by Andrew Morrow on 8/7/17.
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

#include "CMTimeMakeFromString.h"

// Used in calculating segment durations to avoid floating point math.
// On overflow, returns -1.
static inline int32_t int32exp10(uint8_t exp) {
    static const int32_t powers[] = { 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };
    static const uint8_t maxExp = 9;
    
    if (exp > maxExp) {
        return -1;
    }
    
    return powers[exp];
}

CMTime mamba_CMTimeMakeFromString(const char * _Nullable string, uint8_t decimal_places, const char * _Nullable * _Nullable remainder) {
    // head points to where we currently are in the string
    const char *head = string;
    
    CMTime result = kCMTimeInvalid;
    
    if (string == NULL) {
        goto end;
    }
    
    // Cannot represent a number with more than 19 digits in int64_t
    // plus one char for minus sign
    char integralString[21];
    // Must copy out this value to detect its presence
    char decimalPoint;
    // Cannot represent more than 9 decimal places with a power of 10 in int32_t
    char decimalString[10];
    
    size_t charsRead = 0;
    
    int argsRead = sscanf(string, " %20[-0-9]%zn%1[.]%zn%9[0-9]%zn", integralString, &charsRead, &decimalPoint, &charsRead, decimalString, &charsRead);
    head += charsRead;
    
    // must read one integer, or two separated by a period
    // should not accept "1234."
    if (!(argsRead == 1 || argsRead == 3)) {
        goto end;
    }
    
    int32_t timebase = int32exp10(decimal_places);
    if (timebase == -1) {
        goto end;
    }
    
    char *integralRemainder = NULL;
    int64_t time = strtoll(integralString, &integralRemainder, 10);
    
    // the entire portion before the decimal point must be a single valid signed integer
    if (*integralRemainder != '\0') {
        goto end;
    }
    
    time *= timebase;
    
    if (argsRead == 3) {
        char *decimalRemainder = NULL;
        int64_t fractionalTime = strtoull(decimalString, &decimalRemainder, 10);
        
        uint8_t numberOfDecimalDigits = (uint8_t)(decimalRemainder - decimalString);
        
        // This will not overflow because:
        // * the max number of digits will be 9
        // * thus the largest fractional time value is 999999999
        // * the timebase is constrained to int32_t
        // * the timebase must be a power of 10
        // * thus the largest timebase is 1e9
        // * thus this value cannot exceed 999999999e9 == 9.99999999e17 < 1e18
        // * int64_t max is 2^63 - 1 > 1e18
        // * max value < 1e18 < int64_t max
        fractionalTime *= timebase;
        fractionalTime /= int32exp10(numberOfDecimalDigits);
        
        if (integralString[0] == '-') {
            fractionalTime *= -1;
        }
        
        time += fractionalTime;
    }
    
    result = CMTimeMake(time, timebase);
    
end:
    if (remainder != NULL) {
        *remainder = head;
    }
    return result;
}
