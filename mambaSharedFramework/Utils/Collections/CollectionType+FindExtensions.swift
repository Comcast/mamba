//
//  CollectionType+FindExtensions.swift
//  mamba
//
//  Created by David Coufal on 8/16/16.
//  Copyright © 2016 Comcast Cable Communications Management, LLC
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

public extension Collection {
    
    // Finds the first index _after_ the parameter index that matches the predicate
    func findIndexAfterIndex(index:Self.Index, predicate: (Self.SubSequence.Iterator.Element) throws -> Bool) rethrows -> Self.Index? {
        
        guard indicies(containsIndex: index) else { return nil }
        
        var current = self.index(after: index) // we move one forward to not match the current index
        
        guard indicies(containsIndex: current) else { return nil }
        
        let subcollection = self.suffix(from: current)
        
        for element in subcollection {
            if try predicate(element) {
                return current
            }
            current = self.index(after: current)
        }
        return nil
    }
    
    // Finds the first index _before_ the parameter index that matches the predicate
    func findIndexBeforeIndex(index:Self.Index, predicate: (Self.SubSequence.Iterator.Element) throws -> Bool) rethrows -> Self.Index? {
        
        guard indicies(containsIndex: index) || index == self.endIndex else { return nil }

        var current = self.index(index, offsetBy: -1) // we move one backward to not match the current index

        guard indicies(containsIndex: current) else { return nil }

        let subcollection = self.prefix(through: current).reversed()
        
        for element in subcollection {
            if try predicate(element) {
                return current
            }
            current = self.index(current, offsetBy: -1)
        }
        return nil
    }

}

