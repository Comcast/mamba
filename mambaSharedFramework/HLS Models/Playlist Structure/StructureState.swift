//
//  StructureState.swift
//  mamba
//
//  Created by David Coufal on 4/13/17.
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

import Foundation

enum StructureState {
    case clean
    case dirtyWithTagChanges([TagChangeRecord])
    case dirtyRequiresRebuild
}

extension StructureState: Equatable {
}

func ==(lhs: StructureState, rhs: StructureState) -> Bool {
    switch (lhs, rhs) {
    case (.clean, .clean):
        return true
        
    case (.dirtyWithTagChanges(_), .dirtyWithTagChanges(_)):
        return true
        
    case (.dirtyRequiresRebuild, .dirtyRequiresRebuild):
        return true
        
    default:
        return false
    }
}

struct TagChangeRecord {
    let tagChangeCount: Int
    let index: Int
}
