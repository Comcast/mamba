//
//  RapidParserDebug.h
//  mamba
//
//  Created by David Coufal on 1/24/17.
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

#ifndef RapidParserDebug_h
#define RapidParserDebug_h

#include <stdio.h>
#include <assert.h>

#ifdef DEBUG

// comment or uncomment this line to turn on and off console logging and debug services for the rapid parser
// note that even if on, it will not run in production builds
// in general it should be off unless debugging the rapid parser
//#define RAPID_PARSER_DEBUG (1)

#endif

#ifdef RAPID_PARSER_DEBUG

#define rapid_parser_debug_print(fmt, ...) \
do { fprintf(stderr, fmt, __VA_ARGS__); } while (0)

#define rapid_parser_assertion_failure(fmt, ...) \
do { fprintf(stderr, fmt, __VA_ARGS__); assert(0); } while (0)

#define rapid_parser_assert(assertion, fmt, ...) \
if (!(assertion)) { fprintf(stderr, fmt, __VA_ARGS__); assert(0); }

#else

#define rapid_parser_debug_print(fmt, ...)
#define rapid_parser_assertion_failure(fmt, ...)
#define rapid_parser_assert(assertion, fmt, ...)

#endif


#endif /* RapidParserDebug_h */
