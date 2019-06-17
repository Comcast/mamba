//
//  OrderedDictionary.swift
//  mamba
//
//  Created by David Coufal on 7/13/16.
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

/**
 An implementation of a Dictionary where the order of the keys is retained.
 
 This struct should, in general, behave as expected as if it were a regular swift `Dictionary`.
 */
public struct OrderedDictionary<K: Hashable, V>: MutableCollection, ExpressibleByDictionaryLiteral, CustomDebugStringConvertible, CustomStringConvertible {
    
    public typealias Iterator = AnyIterator<(K, V)>
    public typealias Index = ContiguousArray<K>.Index
    public typealias _Element = (K, V)
    public typealias Key = K
    public typealias Value = V

    public private(set) var keys: ContiguousArray<K>
    private var values: Dictionary<K, V>
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        keys = ContiguousArray<K>()
        values = [K:V](minimumCapacity: elements.count)
        for element in elements {
            self[element.0] = element.1
        }
    }
    
    public init(minimumCapacity: Int) {
        keys = ContiguousArray<K>()
        values = [K:V](minimumCapacity: minimumCapacity)
    }
    
    init() {
        keys = ContiguousArray<K>()
        values = [K:V]()
    }
    
    @discardableResult
    public mutating func removeValue(forKey key: K) -> _Element? {
        if let removedValue = values.removeValue(forKey: key) {
            keys.remove(element: key)
            return (key, removedValue)
        }
        return nil
    }
    
    public var startIndex: Index {
        get {
            return keys.startIndex
        }
    }
    
    public var endIndex: Index {
        get {
            return keys.endIndex
        }
    }
    
    public func indexForKey(_ key: Key) -> Index? {
        return keys.index(of: key)
    }
    
    @discardableResult
    public mutating func updateValue(_ value: V, forKey key: K) -> V? {
        if let oldValue = values.updateValue(value, forKey: key) {
            assert(validState())
            return oldValue
        }
        keys.append(key)
        assert(validState())
        return nil
    }
    
    @discardableResult
    public mutating func remove(at index: Index) -> (K, V) {
        assert(validState())
        assert(keys[safe: index] != nil, "OrderedDictionary Error: removeAtIndex attempting remove out of bounds")
        let key = keys[index]
        let value = values[key]
        keys.remove(at: index)
        values.removeValue(forKey: key)
        assert(validState())
        return (key, value!)
    }
    
    public mutating func removeAll(keepingCapacity: Bool = true) {
        keys.removeAll()
        values.removeAll(keepingCapacity: keepingCapacity)
    }

    public subscript(key: K) -> V? {
        get {
            assert(validState())
            return values[key]
        }
        set(new) {
            if let new = new {
                let old = values.updateValue(new, forKey: key)
                if old == nil {
                    keys.append(key)
                }
            }
            else {
                values.removeValue(forKey: key)
                keys.remove(element: key)
            }
            assert(validState())
        }
    }
    
    public subscript(index: Index) -> _Element {
        get {
            assert(validState())
            // expected behavior to crash here if user tried to access array beyond our bounds.
            // Use the "safe" subscript as defined below to avoid i.e.
            //  if let item = myOrderedDictionary[safe: index] {
            //      <do stuff>
            //  }
            assert(keys[safe: index] != nil, "OrderedDictionary Error: Access Out Of Bounds")
            let key = keys[index]
            return (key, values[key]!)
        }
        set(new) {
            // expected to crash if user is trying to modify us outside our bounds
            assert(keys[safe: index] != nil, "OrderedDictionary Error: Access Out Of Bounds")
            let key = keys[index]
            if key == new.0 {
                // we are replacing this keys' value
                self[key] = new.1
            }
            else if let oldIndex = keys.index(of: new.0) {
                // we are replacing this keys value, but original key is in a different position
                var newIndex = index
                if oldIndex < index {
                    newIndex -= 1 // correct the incoming index since we are about to delete an element previous to it in the array
                }
                keys.remove(at: oldIndex)
                keys[newIndex] = new.0
                values.removeValue(forKey: key)
                values[new.0] = new.1
            }
            else {
                // we are removing the old key and replacing with the new key
                keys[index] = new.0
                values.removeValue(forKey: key)
                values[new.0] = new.1
            }
            assert(validState())
        }
    }
        
    /// Returns the key for the dictionary pair at the specified index
    ///
    /// myOrderedDictionary[key: 0] will return the key for position 0
    public subscript(key index: Index) -> K? {
        get {
            assert(validState())
            return keys[safe: index]
        }
    }

    /// Returns the value for the dictionary pair at the specified index
    ///
    /// myOrderedDictionary[value: 0] will return the value for position 0
    public subscript(value index: Index) -> V? {
        get {
            assert(validState())
            if let key = keys[safe: index] {
                return values[key]
            }
            return nil
        }
    }
    
    /// Returns the key for the dictionary pair at the specified index
    public func key(index: Index) -> K? {
        return self[key: index]
    }
    
    /// Returns the value for the dictionary pair at the specified index
    public func value(index: Index) -> V? {
        return self[value: index]
    }
    
    public var isEmpty: Bool {
        get {
            assert(validState())
            return keys.isEmpty
        }
    }
    
    public func makeIterator() -> OrderedDictionary.Iterator {
        return AnyIterator(OrderedDictionaryIterator(keys: keys, values: values))
    }
    
    public var count: Int {
        assert(validState())
        return keys.count
    }
    
    /// Returns our content as a standard dictionary. Return value has no meaningful order info.
    public func asDictionary() -> [K: V] {
        assert(validState())
        return values
    }
    
    // Adds the dictionary in the argument to this dictionary, at the end, in order
    //
    // Note that adding duplicates will not change the order of the dictionary, i.e. adding a duplicate key will still retain its order from the "parent" dictionary
    public mutating func add(orderedDictionary dictionary:OrderedDictionary<K, V>) {
        for (key,value) in dictionary {
            self.updateValue(value, forKey:key)
        }
    }
    
    // Adds the dictionary in the argument to this dictionary, at the end. No order is guaranteed in the add, since Dictionary is unordered.
    //
    // Note that adding duplicates will not change the order of the dictionary, i.e. adding a duplicate key will still retain it's order from the "parent" dictionary
    public mutating func add(dictionary:[K:V]) {
        for (key,value) in dictionary {
            self.updateValue(value, forKey:key)
        }
    }
    
    public func index(after i: OrderedDictionary.Index) -> OrderedDictionary.Index {
        return keys.index(after: i)
    }
    
    public func formIndex(after i: inout OrderedDictionary.Index) {
        keys.formIndex(after: &i)
    }
    
    public var debugDescription: String {
        if !validState() {
            return "OrderedDictionary in invalid state. \nOrdered keys:\n\(keys)\nValues:\n\(values)\n"
        }
        var description = "OrderedDictionary {\n"
        var i = 0
        for key in keys {
            description += "   [\(i)]: \(key) => \(String(describing: self[key]))\n"
            i += 1
        }
        description += "}"
        return description
    }
    
    public var description: String {
        return debugDescription
    }
    
    private func validState() -> Bool {
        return keys.count == values.count
    }
}

private struct OrderedDictionaryIterator<K: Hashable, V>: IteratorProtocol {
    fileprivate typealias Element = (K, V)
    
    private let keys: ContiguousArray<K>
    private let values: Dictionary<K, V>
    private var index = 0
    
    init(keys: ContiguousArray<K>, values: Dictionary<K, V>) {
        self.keys = keys
        self.values = values
    }
    
    mutating fileprivate func next() -> Element? {
        if index == keys.endIndex {
            return nil
        }
        assert(keys[safe: index] != nil, "OrderedDictionaryIterator Error: Access Out Of Bounds")
        let key = keys[index]
        let value = values[key]
        assert(value != nil, "OrderedDictionaryIterator Error: Value not found")
        index += 1
        return (key, value!)
    }
}

private extension ContiguousArray where Element: Equatable {
    mutating func remove(element: Element) {
        if let indexToRemove = index(of: element) {
            remove(at: indexToRemove)
        }
    }
}


