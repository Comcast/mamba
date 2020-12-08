//
//  RapidParserLineState.h
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

#ifndef RapidParserLineState_h
#define RapidParserLineState_h

#include <stdio.h>

struct LineState {
    int64_t colonPosition;
    int64_t commaPosition;
    int64_t start;
    int64_t end;
};

void initializeLineState(struct LineState *lineState);

extern const int64_t lineStateInvalidValue;

#endif /* RapidParserLineState_h */
