//
//  RapidParserStateHandlers.c
//  mamba
//
//  Created by David Coufal on 1/20/17.
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

#include "RapidParserStateHandlers.h"
#include "RapidParserState.h"
#include "RapidParserNewTagCallbacks.h"
#include "RapidParserError.h"
#include "RapidParserDebug.h"

// General Purpose Scanning Handlers (used for all states)

uint8_t noOpContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return Scanning;
}

uint8_t addCommaAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    // overwriting the last comma is ok, we only care about the comma that's earliest in the line
    lineState->commaPosition = index;
    return Scanning;
}

uint8_t addColonAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    // overwriting the last colon is ok, we only care about the colon that's earliest in the line
    lineState->colonPosition = index;
    return Scanning;
}

uint8_t foundTAndLookForXForEXT(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForXForEXT;
}

uint8_t foundFAndLookForNForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForNForEXTINF;
}

uint8_t foundHashAndLookForNewline(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForNewLineForComment;
}

uint8_t endOfLineForURLAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    
    // index is currently a newline. we do not want to include it
    lineState->start = index + 1;
    
    if ( lineState->end <= lineState->start ) {
        // this is either a blank line or a \n\r pair. We're not going to parse this, just keep moving
        lineState->end = index - 1;
        return Scanning;
    }
    NewURLCallback(parentparser, lineState->start, lineState->end);
    initializeLineState(lineState);
    lineState->end = index - 1;
    return Scanning;
}

// Scanning Handlers for LookingForX state

uint8_t foundXAndLookForEForEXT(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForEForEXT;
}

// Scanning Handlers for LookingForE state

uint8_t foundEAndLookForHashForEXT(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForHashForEXT;
}

// Scanning Handlers for LookingForHash state

uint8_t foundHashAndLookForNewlineForEXT(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForNewLineForEXT;
}

// Scanning Handlers for LookingForNewLineForEXT state

uint8_t foundNewlineCompletingEXTBeginAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    
    // index is currently a newline. we do not want to include it
    lineState->start = index + 1;

    if ( lineState->colonPosition == lineStateInvalidValue ) {
        // we are a no value tag
        NewTagNoDataCallback(parentparser, lineState->start, lineState->end);
    }
    else {
        // we are a single value, key-value or EXTINF tag
        
        if (lineState->end - lineState->colonPosition == 0) {
            ParseError(parentparser, RapidParserErrorMissingTagData, RapidParserErrorMissingTagData_Message);
            return ErrorEarlyExit;
        }
       
        NewTagCallback(parentparser, lineState->start, (lineState->colonPosition - 1), (lineState->colonPosition + 1), lineState->end);
    }
    initializeLineState(lineState);
    lineState->end = index - 1;
    return Scanning;
}

// Scanning Handlers for LookingForNewLineForHash state

uint8_t foundNewlineForCommentBeginAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {

    // index is currently a newline. we do not want to include it
    lineState->start = index + 1;

    NewCommentCallback(parentparser, lineState->start, lineState->end);
    initializeLineState(lineState);
    lineState->end = index - 1;
    return Scanning;
}

// Scanning Handlers for LookingForNForEXTINF

uint8_t foundNLookingForIForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForIForEXTINF;
}

// Scanning Handlers for LookingForIForEXTINF

uint8_t foundILookingForTForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForTForEXTINF;
}

// Scanning Handlers for LookingForTForEXTINF

uint8_t foundTLookingForXForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForXForEXTINF;
}

// Scanning Handlers for LookingForXForEXTINF

uint8_t foundXLookingForEForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForEForEXTINF;
}

// Scanning Handlers for LookingForEForEXTINF

uint8_t foundELookingForHashForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForHashForEXTINF;
}

// Scanning Handlers for LookingForHashForEXTINF

uint8_t foundHashLookingForNewlineForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    return LookingForNewlineForEXTINF;
}

// Scanning Handlers for LookingForNewlineForEXTINF

uint8_t foundNewlineCompletingEXTINFBeginAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState) {
    
    static uint64_t commaPosition = 0;
    static uint64_t endDurationPosition = 0;

    // index is currently a newline. we do not want to include it
    lineState->start = index + 1;
    
    if ( lineState->colonPosition == lineStateInvalidValue ) {
        // this is an error, all EXTINF tags must have a :
        ParseError(parentparser, RapidParserErrorMissingTagDataForEXTINF, RapidParserErrorMissingTagDataForEXTINF_Message);
        return ErrorEarlyExit;
    }
    
    if (lineState->end - lineState->colonPosition == 0) {
        ParseError(parentparser, RapidParserErrorMissingTagData, RapidParserErrorMissingTagData_Message);
        return ErrorEarlyExit;
    }
    
    commaPosition = lineState->end;
    endDurationPosition = lineState->end;
    if ( lineState->commaPosition != lineStateInvalidValue ) {
        commaPosition = lineState->commaPosition;
        endDurationPosition = commaPosition - 1;
    }

    NewEXTINFTagNoDataCallback(parentparser, lineState->start, (lineState->colonPosition - 1), (lineState->colonPosition + 1), endDurationPosition, (lineState->colonPosition + 1), lineState->end);

    initializeLineState(lineState);
    lineState->end = index - 1;
    return Scanning;

}

