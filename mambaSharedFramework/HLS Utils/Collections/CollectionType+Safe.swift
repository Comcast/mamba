//
//  CollectionType+Safe.swift
//  mamba
//
//  Created by David Coufal on 7/14/16.
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

import Swift

/// Utility replacement for (collection).indicies.contains(index) which went away in Swift 3
extension Collection {
    public func indicies(containsIndex index: Index) -> Bool {
        return index >= startIndex && index < endIndex
    }
}

/// Generalized safe subscript access for out of bounds index for all CollectionTypes
/// Usage:
///  if let item = myCollectionType[safe: index] {
///      <do stuff>
///  }
/// http://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
public extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indicies(containsIndex: index) ? self[index] : nil
    }
}
