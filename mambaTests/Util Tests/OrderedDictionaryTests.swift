//
//  OrderedDictionaryTests.swift
//  mamba
//
//  Created by David Coufal on 8/19/16.
//  Copyright © 2016 Comcast Corporation.
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

import XCTest

@testable import mamba

typealias StringStringOrderedDictionary = OrderedDictionary<String, String>

class OrderedDictionaryTests: XCTestCase {

    func testOrderedDictionary_subscriptAccess() {
        var orderedDict = StringStringOrderedDictionary()
        
        orderedDict["1"] = "1"
        orderedDict["2"] = "2"
        orderedDict["3"] = "3"
        orderedDict["4"] = "4"
        
        runTestsOnOrderedDict(orderedDict: &orderedDict)
    }
    
    func testOrderedDictionary_literal() {
        var orderedDict:StringStringOrderedDictionary = ["1": "1", "2":"2", "3":"3", "4":"4"]
        runTestsOnOrderedDict(orderedDict: &orderedDict)
    }
    
    func testOrderedDictionary_minimumCapacity() {
        var orderedDict = StringStringOrderedDictionary(minimumCapacity: 4)
        
        orderedDict["1"] = "1"
        orderedDict["2"] = "2"
        orderedDict["3"] = "3"
        orderedDict["4"] = "4"
        
        runTestsOnOrderedDict(orderedDict: &orderedDict)
    }
    
    func testOrderedDictionary_removeValueForKey() {
        var orderedDict:OrderedDictionary = ["1": "1", "2":"2", "3":"3", "4":"4"]
        
        let removedValue = orderedDict.removeValue(forKey: "2")
        
        XCTAssert(removedValue! == ("2", "2"), "Did not remove expected item")
        XCTAssert(orderedDict.count == 3, "Did not remove expected item")
        XCTAssert(orderedDict.removeValue(forKey: "a") == nil, "Should not have removed an item for a non-existant key")
        
        orderedDict["3"] = nil
        XCTAssert(orderedDict.count == 2, "Did not remove expected item")
        XCTAssert(orderedDict["3"] == nil, "Did not remove expected item")
    }
    
    func testOrderedDictionary_indexForKey() {
        let od:OrderedDictionary = ["0": "0", "1": "1", "2":"2", "3":"3"]
        
        XCTAssert(od.indexForKey("0") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("1") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 2, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 3, "Not in expected position")
    }
    
    func testOrderedDictionary_addAlreadyExistingKeyInNewPosition_AtSamePosition() {
        var od:OrderedDictionary = ["0": "0", "1": "1", "2":"2", "3":"3"]
        
        od[1] = ("1","a")
        
        XCTAssert(od.indexForKey("0") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("1") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 2, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 3, "Not in expected position")
        XCTAssert(od["0"] == "0", "Does not have expected value")
        XCTAssert(od["1"] == "a", "Does not have expected value")
        XCTAssert(od["2"] == "2", "Does not have expected value")
        XCTAssert(od["3"] == "3", "Does not have expected value")
        XCTAssert(od.count == 4, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_addAlreadyExistingKeyInNewPosition_AtPreviousPosition() {
        var od:OrderedDictionary = ["0": "0", "1": "1", "2":"2", "3":"3"]
        
        od[1] = ("2","a")
        
        XCTAssert(od.indexForKey("0") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 2, "Not in expected position") // we told the dict to replace the entry at 1 with the key "2", so we had to erase the already existing entry for "2" to maintain key uniqueness. This slid some keys down.
        XCTAssert(od["0"] == "0", "Does not have expected value")
        XCTAssert(od["2"] == "a", "Does not have expected value")
        XCTAssert(od["3"] == "3", "Does not have expected value")
        XCTAssert(od.count == 3, "Does not have expected number of elements") // we told the dict to replace the entry at 1 with the key "2", so we had to erase the already existing entry for "2" to maintain key uniqueness.
    }
    
    func testOrderedDictionary_addAlreadyExistingKeyInNewPosition_AtLaterPosition() {
        var od:OrderedDictionary = ["0": "0", "1": "1", "2":"2", "3":"3"]
        
        od[3] = ("1","a")
        
        XCTAssert(od.indexForKey("0") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 1, "Not in expected position") // we told the dict to replace the entry at 3 with the key "1", so we had to erase the already existing entry for "1" to maintain key uniqueness. This slid some keys down.
        XCTAssert(od.indexForKey("1") == 2, "Not in expected position") // we told the dict to replace the entry at 3 with the key "1", so we had to erase the already existing entry for "1" to maintain key uniqueness. This slid some keys down.
        XCTAssert(od["0"] == "0", "Does not have expected value")
        XCTAssert(od["1"] == "a", "Does not have expected value")
        XCTAssert(od["2"] == "2", "Does not have expected value")
        XCTAssert(od.count == 3, "Does not have expected number of elements") // we told the dict to replace the entry at 3 with the key "1", so we had to erase the already existing entry for "1" to maintain key uniqueness.
    }
    
    func testOrderedDictionary_addANewKeyViaSubscript() {
        var od:OrderedDictionary = ["0": "0", "1": "1", "2":"2", "3":"3"]
        
        od[1] = ("a","a")
        
        XCTAssert(od.indexForKey("0") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("a") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 2, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 3, "Not in expected position")
        XCTAssert(od["0"] == "0", "Does not have expected value")
        XCTAssert(od["a"] == "a", "Does not have expected value")
        XCTAssert(od["2"] == "2", "Does not have expected value")
        XCTAssert(od["3"] == "3", "Does not have expected value")
        XCTAssert(od.count == 4, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_updateValue_Existing() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3", "4":"4"]
        
        XCTAssert(od.updateValue("a", forKey: "2") == "2", "Update value did not return old value")
        
        XCTAssert(od.indexForKey("1") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 2, "Not in expected position")
        XCTAssert(od.indexForKey("4") == 3, "Not in expected position")
        XCTAssert(od["1"] == "1", "Does not have expected value")
        XCTAssert(od["2"] == "a", "Does not have expected value")
        XCTAssert(od["3"] == "3", "Does not have expected value")
        XCTAssert(od["4"] == "4", "Does not have expected value")
        XCTAssert(od.count == 4, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_updateValue_New() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3", "4":"4"]
        
        XCTAssert(od.updateValue("a", forKey: "5") == nil, "Update value did not return nil value for new key")
        
        XCTAssert(od.indexForKey("1") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 2, "Not in expected position")
        XCTAssert(od.indexForKey("4") == 3, "Not in expected position")
        XCTAssert(od.indexForKey("5") == 4, "Not in expected position")
        XCTAssert(od["1"] == "1", "Does not have expected value")
        XCTAssert(od["2"] == "2", "Does not have expected value")
        XCTAssert(od["3"] == "3", "Does not have expected value")
        XCTAssert(od["4"] == "4", "Does not have expected value")
        XCTAssert(od["5"] == "a", "Does not have expected value")
        XCTAssert(od.count == 5, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_removeAtIndex() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3", "4":"4"]
        
        od.remove(at: 2)
        
        XCTAssert(od.indexForKey("1") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("4") == 2, "Not in expected position")
        XCTAssert(od["1"] == "1", "Does not have expected value")
        XCTAssert(od["2"] == "2", "Does not have expected value")
        XCTAssert(od["4"] == "4", "Does not have expected value")
        XCTAssert(od.count == 3, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_removeAll() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3", "4":"4"]
        
        od.removeAll()
        
        XCTAssert(od.count == 0, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_removeAll_keepCapacity() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3", "4":"4"]
        
        od.removeAll(keepingCapacity: true)
        
        XCTAssert(od.count == 0, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_isEmpty() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3", "4":"4"]
        
        XCTAssert(od.isEmpty == false, "isEmpty not returning correct value")
        
        od.removeAll(keepingCapacity: true)
        
        XCTAssert(od.isEmpty == true, "isEmpty not returning correct value")
    }
    
    func testOrderedDictionary_AddUnique() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3"]
        let odnew:OrderedDictionary = ["4": "4", "5":"5"]
        
        od.add(orderedDictionary: odnew)
        
        XCTAssert(od.indexForKey("1") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 2, "Not in expected position")
        XCTAssert(od.indexForKey("4") == 3, "Not in expected position")
        XCTAssert(od.indexForKey("5") == 4, "Not in expected position")
        XCTAssert(od["1"] == "1", "Does not have expected value")
        XCTAssert(od["2"] == "2", "Does not have expected value")
        XCTAssert(od["3"] == "3", "Does not have expected value")
        XCTAssert(od["4"] == "4", "Does not have expected value")
        XCTAssert(od["5"] == "5", "Does not have expected value")
        XCTAssert(od.count == 5, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_AddDuplicateDict() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3"]
        let odnew:OrderedDictionary = ["2": "A", "4":"4"]
        
        od.add(orderedDictionary: odnew)
        
        XCTAssert(od.indexForKey("1") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 2, "Not in expected position")
        XCTAssert(od.indexForKey("4") == 3, "Not in expected position")
        XCTAssert(od["1"] == "1", "Does not have expected value")
        XCTAssert(od["2"] == "A", "Does not have expected value")
        XCTAssert(od["3"] == "3", "Does not have expected value")
        XCTAssert(od["4"] == "4", "Does not have expected value")
        XCTAssert(od.count == 4, "Does not have expected number of elements")
    }
    
    func testOrderedDictionary_AddNormalDict() {
        var od:OrderedDictionary = ["1": "1", "2":"2", "3":"3"]
        let dnew = ["4": "4", "5":"5"]
        
        od.add(dictionary: dnew)
        
        XCTAssert(od.indexForKey("1") == 0, "Not in expected position")
        XCTAssert(od.indexForKey("2") == 1, "Not in expected position")
        XCTAssert(od.indexForKey("3") == 2, "Not in expected position")
        // note: we are not guaranteed any order for adding a "normal" dictionary:
        XCTAssert(od.indexForKey("4") == 3 || od.indexForKey("4") == 4, "Not in expected position")
        XCTAssert(od.indexForKey("5") == 3 || od.indexForKey("5") == 4, "Not in expected position")
        
        XCTAssert(od["1"] == "1", "Does not have expected value")
        XCTAssert(od["2"] == "2", "Does not have expected value")
        XCTAssert(od["3"] == "3", "Does not have expected value")
        XCTAssert(od["4"] == "4", "Does not have expected value")
        XCTAssert(od["5"] == "5", "Does not have expected value")
        XCTAssert(od.count == 5, "Does not have expected number of elements")
    }
    
    // MARK: Ordered Dictionary - common functions
    
    func runTestsOnOrderedDict(orderedDict: inout StringStringOrderedDictionary) {
        
        XCTAssert(orderedDict.count == 4, "Count is not valid")
        
        XCTAssert(orderedDict[key: 0] == "1", "key subscript not working")
        XCTAssert(orderedDict[key: 1] == "2", "key subscript not working")
        XCTAssert(orderedDict[key: 2] == "3", "key subscript not working")
        XCTAssert(orderedDict[key: 3] == "4", "key subscript not working")
        XCTAssert(orderedDict[value: 0] == "1", "value subscript not working")
        XCTAssert(orderedDict[value: 1] == "2", "value subscript not working")
        XCTAssert(orderedDict[value: 2] == "3", "value subscript not working")
        XCTAssert(orderedDict[value: 3] == "4", "value subscript not working")
        
        XCTAssert(orderedDict.key(index: 0) == "1", "key not working")
        XCTAssert(orderedDict.key(index: 1) == "2", "key not working")
        XCTAssert(orderedDict.key(index: 2) == "3", "key not working")
        XCTAssert(orderedDict.key(index: 3) == "4", "key not working")
        XCTAssert(orderedDict.value(index: 0) == "1", "value not working")
        XCTAssert(orderedDict.value(index: 1) == "2", "value not working")
        XCTAssert(orderedDict.value(index: 2) == "3", "value not working")
        XCTAssert(orderedDict.value(index: 3) == "4", "value not working")
        
        // should be ordered in the order in which we declared elements
        var i = 1
        for pair in orderedDict {
            XCTAssert(pair.0 == "\(i)", "Order was not held")
            XCTAssert(pair.1 == "\(i)", "Order was not held")
            i += 1
        }
        
        // also test subscript access
        for i in 0...3 {
            XCTAssert(orderedDict[i].0 == "\(i+1)", "Order was not held")
            XCTAssert(orderedDict[i].1 == "\(i+1)", "Order was not held")
        }
        
        orderedDict["1"] = "4"
        orderedDict["4"] = "1"
        orderedDict["3"] = "2"
        orderedDict["2"] = "3"
        
        XCTAssert(orderedDict.count == 4, "Count is not valid")
        
        // should retain order even if we change the key's value, and if we change the keys value out of original order
        i = 1
        for pair in orderedDict {
            XCTAssert(pair.0 == "\(i)", "Order was not held")
            XCTAssert(pair.1 == "\(5 - i)", "Order was not held")
            i += 1
        }
        
        orderedDict[0].1 = "1"
        orderedDict[1].1 = "2"
        orderedDict[2].1 = "3"
        orderedDict[3].1 = "4"
        
        XCTAssert(orderedDict.count == 4, "Count is not valid")
        
        // should retain order when we change the key values via subscript
        i = 1
        for pair in orderedDict {
            XCTAssert(pair.0 == "\(i)", "Order was not held")
            XCTAssert(pair.1 == "\(i)", "Order was not held")
            i += 1
        }
        
        orderedDict[0].0 = "5"
        orderedDict[1].0 = "6"
        orderedDict[2].0 = "7"
        orderedDict[3].0 = "8"
        
        XCTAssert(orderedDict.count == 4, "Count is not valid")
        
        // key changes made via subscript should retain order
        i = 1
        for pair in orderedDict {
            XCTAssert(pair.0 == "\(i + 4)", "Order was not held")
            XCTAssert(pair.1 == "\(i)", "Order was not held")
            i += 1
        }
    }

}
