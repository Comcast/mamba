//
//  RapidParserStateHandlers.h
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

#ifndef RapidParserStateHandlers_h
#define RapidParserStateHandlers_h

#include <stdio.h>
#include "RapidParserLineState.h"

// Type definition of the standard parser handler

typedef uint8_t (*parserStateHandler) (const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// General Purpose Scanning Handlers (used for all states)

uint8_t noOpContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);
uint8_t addCommaAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);
uint8_t addColonAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);
uint8_t foundTAndLookForXForEXT(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);
uint8_t foundFAndLookForNForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);
uint8_t foundHashAndLookForNewline(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);
uint8_t endOfLineForURLAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForXForEXT

uint8_t foundXAndLookForEForEXT(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForEForEXT

uint8_t foundEAndLookForHashForEXT(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForHashForEXT

uint8_t foundHashAndLookForNewlineForEXT(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForNewLineForEXT

uint8_t foundNewlineCompletingEXTBeginAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForNewLineForComment

uint8_t foundNewlineForCommentBeginAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForNForEXTINF

uint8_t foundNLookingForIForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForIForEXTINF

uint8_t foundILookingForTForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForTForEXTINF

uint8_t foundTLookingForXForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForXForEXTINF

uint8_t foundXLookingForEForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForEForEXTINF

uint8_t foundELookingForHashForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForHashForEXTINF

uint8_t foundHashLookingForNewlineForEXTINF(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

// Scanning Handlers for LookingForNewlineForEXTINF

uint8_t foundNewlineCompletingEXTINFBeginAndContinueScanning(const void *parentparser, const unsigned char character, const uint64_t index, uint8_t currentState, struct LineState *lineState);

#endif /* RapidParserStateHandlers_h */
