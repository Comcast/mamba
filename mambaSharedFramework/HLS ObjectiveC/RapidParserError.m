//
//  RapidParserError.m
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

#include "RapidParserError.h"
// Module mamba-Swift is not available in Swift Package Manager.
// In order to import 'HLSParserError.swift' a new module in Package.swift was created.
// This is needed to access HLSParserInternalErrorCode enum.
#if SWIFT_PACKAGE
@import HLSParserError;
#else
#import <mamba/mamba-Swift.h>
#endif

const uint32_t RapidParserErrorMissingTagData = HLSParserInternalErrorCodeMissingTagData;

const uint32_t RapidParserErrorMissingTagDataForEXTINF = HLSParserInternalErrorCodeMissingTagDataForEXTINF;

const char * RapidParserErrorMissingTagData_Message = "Found a tag with missing tag data";

const char * RapidParserErrorMissingTagDataForEXTINF_Message = "Found an EXTINF tag with missing tag data";
