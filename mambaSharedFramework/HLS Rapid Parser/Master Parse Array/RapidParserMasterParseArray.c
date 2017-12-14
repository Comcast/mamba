//
//  RapidParserMasterParseArray.c
//  mamba
//
//  Created by David Coufal on 1/20/17.
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

#include "RapidParserMasterParseArray.h"

/*
 This is where we define the masterParseArray, which contains a 2D array of 
 function pointers to parse HLS manifests.
 
 The first dimension of the array is the current state of the parser (defined 
 in RapidParserState.h)
 
 The second dimension is the byte value.
 
 By combining the current state and the byte value, we get a function pointer 
 that takes appropriate actions to local parser state and makes callbacks to 
 our parent to make new tags, and also determines the new state of the parser.
 
 This file greatly abuses the preprocessor. The function pointers for each
 state are defined in seperate files for readability (in ".include" files)
 and are included here via the preprocessor.
 */

const parserStateHandler masterParseArray[numberOfScanningParseStates][256] = {
    {
#include "RapidParser_ScanningState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForXForEXTState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForEForEXTState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForHashForEXTState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForNewLineForEXTState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForNewLineForHashState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForNForEXTINFState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForIForEXTINFState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForTForEXTINFState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForXForEXTINFState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForEForEXTINFState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForHashForEXTINFState_ParseArray.include"
    },
    {
#include "RapidParser_LookingForNewlineForEXTINFState_ParseArray.include"
    },
};
