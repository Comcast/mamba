//
//  parseHLS.c
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

#include <stdio.h>
#include "RapidParserNewTagCallbacks.h"
#include "RapidParserState.h"
#include "RapidParserLineState.h"
#include "RapidParserMasterParseArray.h"
#include "RapidParserDebug.h"

void parseHLS(const void *parentparser, const unsigned char *bytes, const uint64_t length) {
    
    uint64_t index = length;
    uint8_t state = Scanning;
    
    struct LineState lineState;
    initializeLineState(&lineState);
    lineState.end = index - 1;
    
    rapid_parser_debug_print("Begining parse of hls data with length %llu\n", length);
    
    while (index > 0 && state < numberOfScanningParseStates) {
        
        index -= 1;
        
        state = (*masterParseArray[state][bytes[index]]) (parentparser, bytes[index], index, state, &lineState);
        
        rapid_parser_debug_print("State %i after processing character %c at index %llu\n", (int)state, bytes[index], index);
    }
    
    // if we are in ErrorEarlyExit or EarlyExit we do not have to handle the final line
    if (index == 0 && state < numberOfScanningParseStates) {
        // handle the final line, force a line completion
        // note that we pass "-1" as the index, because we are pretending that there is a newline at position -1
        (*masterParseArray[state]['\n']) (parentparser, '\n', -1, state, &lineState);
    }
    
    // if we are in ErrorEarlyExit another part of the code already called ParseError to exit out
    // if we are in EarlyExit, its because the client has asked us to exit and they know that parsing is complete
    if (state < numberOfScanningParseStates) {
        
        rapid_parser_debug_print("Ending parse of hls data with length %llu\n", length);
        
        ParseComplete(parentparser);
    }
}
