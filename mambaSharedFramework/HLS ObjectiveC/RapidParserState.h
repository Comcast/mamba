//
//  RapidParserState.h
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

#ifndef RapidParserState_h
#define RapidParserState_h

#include <stdio.h>
#include <stdint.h>

enum ParseState {
    // normal scanning state
    Scanning = 0,
    // when we find a T, we start looking for a X to possibly complete a #EXT
    LookingForXForEXT,
    // when we find a XT, we start looking for a E to possibly complete a #EXT
    LookingForEForEXT,
    // when we find a EXT, we start looking for a # to possibly complete a #EXT
    LookingForHashForEXT,
    // when we find a #EXT, we start looking for a newline to possibly complete a #EXT and make a tag
    LookingForNewLineForEXT,
    // when we find a #, we start looking for a newline to possibly make a comment
    LookingForNewLineForComment,
    // when we find a F, we start looking for a N to possibly make a #EXTINF
    LookingForNForEXTINF,
    // when we find a N, we start looking for a I to possibly make a #EXTINF
    LookingForIForEXTINF,
    // when we find a I, we start looking for a T to possibly make a #EXTINF
    LookingForTForEXTINF,
    // when we find a T, we start looking for a X to possibly make a #EXTINF
    LookingForXForEXTINF,
    // when we find a X, we start looking for a E to possibly make a #EXTINF
    LookingForEForEXTINF,
    // when we find a E, we start looking for a # to possibly make a #EXTINF
    LookingForHashForEXTINF,
    // when we find a #, we start looking for a newline to possibly complete a #EXTINF and make a tag
    LookingForNewlineForEXTINF,
    // signal an early exit (not an error, but the client has requested a stop scanning) (THIS NEEDS TO BE SECOND TO LAST IN THE PARSE STATE LIST)
    EarlyExit,
    // when we encounter an error, signal an early exit (THIS NEEDS TO BE LAST IN THE PARSE STATE LIST)
    ErrorEarlyExit
};

// This value only includes non-ErrorEarlyExit states. We will not be parsing any characters while in the ErrorEarlyExit state.
const static uint8_t numberOfScanningParseStates = 13;

#endif /* RapidParserState_h */

/*
 
 Parse State Machine:
 
 We start in the Scanning state. We scan through each character in the 
 playlist in reverse and move to different states based on that character.
 
 We may take other actions based on the character value, but those are not
 part of the state machine and are not documented here. The actions taken
 per character are found in the `masterParseArray`.
 
 Note that there is a special state ErrorEarlyExit. This is triggered when we find an error
 that forces us to stop parsing. This is a "final" state, and we exit the loop when we 
 hit it. There is not an entry in the `masterParseArray` for this state since we
 immediately exit when we find it.
 
 The other exit condition is when we run out of characters.
 
 
    +-------------------------------------<--------------------------------------------------<-----------------------------------------------------------------+
    |                                                                                                                                                          |
    |      +--> Found a F ---------------------------------------------------------------------------------+                                                   |
    v      |                                                                                               |                                                   ^
[Scanning]-+--> Found an T ---------------------------------------------------------------+              {This pathway is where we                             |
    ^      |                                                                              |               look for EXTINF tags}                                |
    |      +--> Found a # ----------------+                                               |                |                                                   |
    |      |                              |                                               |              [LookingForN] ---------------> Found anything else >--+
    |      +--> Found a newline ------+   |                                               |                |                                                   |
    |      |                          |   |                                               |               Found a N                                            ^
    |      |    +-- (Handle New URL)--+   |                                               |                |                                                   |
    |   Found   |                         |                                               |              [LookingForI] ---------------> Found anything else >--+
    |  Anything v            {This pathway is where we                                    |                |                                                   |
    |    Else   |             look for possible Comments}                                 |               Found a I                                            ^
    |      |    |                         |                                               |                |                                                   |
    +--<---+--<-+            [LookingForNewLineForHash]                                   |              [LookingForT] ---------------> Found anything else >--+
    |                                     |                                               |                |                                                   |
    |                                     +--> Found a Newline --> (Handle Comment) --+   |               Found a T                                            ^
    |                                     |                                           |   |                |                                                   |
    |                                     +--> Found anything else --+                |   |              [LookingForX] ---------------> Found anything else >--+
    |                                                                |                |   |                |                                                   |
    +----------------------------------<-----------------------------+-------<--------+   |               Found a X                                            ^
    |                                                                                     |                |                                                   |
    |                                                                         {This pathway is where we  [LookingForE] ---------------> Found anything else >--+
    ^                                                                          look for possible Tags}     |                                                   |
    |                                                                                     |               Found a E                                            ^
    |                                                                 +------------ [LookingForX]          |                                                   |
    |                                                                 |                   |              [LookingForHash] ------------> Found anything else >--+
    +----------------------------------<--------------------- Found anything else    Found an X            |                                                   |
    |                                                                                     |               Found a #                                            ^
    ^                                                                 +------------ [LookingForE]          |                                                   |
    |                                                                 |                   |              [LookingForNewline] ---------> Found anything else >--+
    +----------------------------------<--------------------- Found anything else    Found an E            |                                                   |
    |                                                                                     |               Found a newline                                      ^
    ^                                                                 +----------- [LookingForHash]        |                                                   |
    |                                                                 |                   |               (Handle new EXTINF tag) ------------->---------------+
    +----------------------------------<--------------------- Found anything else     Found a #
    |                                                                                     |
    ^                                                                 +------ [LookingForNewLineForEXT]
    |                                                                 |                   |
    +----------------------------------<--------------------- Found anything else   Found a newline
    |                                                                                     |
    +----------------------------------<------------------------------------------- (Handle New Tag)

 */
