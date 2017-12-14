//
//  CollectionTypeTests.swift
//  mamba
//
//  Created by David Coufal on 7/14/16.
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

class CollectionTypeTests: XCTestCase {

    func testCollectionTypeSafe() {
        let array = ["a", "b"]
        
        XCTAssert(array[0] == "a", "0th element should be \"a\"")
        XCTAssert(array[safe: 0] == "a", "0th element should be \"a\"")
        XCTAssert(array[1] == "b", "1st element should be \"b\"")
        XCTAssert(array[safe: 1] == "b", "1st element should be \"b\"")
        XCTAssert(array[safe: 2] == nil, "2nd element should be nil since it does not exist")
        XCTAssert(array[safe: -1] == nil, "2nd element should be nil since it does not exist")
        // array[2] and array[-1] would both crash
    }
    
    func testCollectionTypeFindIndexAfterIndex() {
        
        let array = ["a", "b", "c", "a", "b", "c"]
        
        let first_b_index = array.index(where: { $0 == "b" })
        XCTAssert(first_b_index == 1, "Our b location should be accurate")
        
        let second_a_index = array.findIndexAfterIndex(index: first_b_index!, predicate: { $0 == "a" })
        XCTAssert(second_a_index == 3, "Our second a location should be accurate")
        
        let second_a_index2 = array.findIndexAfterIndex(index: 0, predicate: { $0 == "a" })
        XCTAssert(second_a_index2 == 3, "Our second a location should be accurate")
        
        let third_a_index = array.findIndexAfterIndex(index: 4, predicate: { $0 == "a" })
        XCTAssertNil(third_a_index, "There are no `a`s after index 4")
        
        let d_index = array.findIndexAfterIndex(index: 0, predicate: { $0 == "d" })
        XCTAssertNil(d_index, "There are no `d`s at all")
        
        let choose_next_index = array.findIndexAfterIndex(index: 1, predicate: { _ in true })
        XCTAssert(choose_next_index == 2, "Should just choose the next index")
        
        let last_index_should_be_nil = array.findIndexAfterIndex(index: array.count - 1, predicate: { _ in true })
        XCTAssertNil(last_index_should_be_nil, "Calling findIndexAfterIndex on the last index should always return nil, since there is nothing after the last index!")
    }
    
    func testCollectionTypeFindIndexAfterIndex_invalidInput() {
        
        let array = ["a", "b", "c", "a", "b", "c"]
        
        let negativeIndexResult = array.findIndexAfterIndex(index: -2, predicate: { _ in true })
        XCTAssertNil(negativeIndexResult, "Out of bounds should return nil")
        
        let negativeIndexResult2 = array.findIndexAfterIndex(index: -1, predicate: { _ in true })
        XCTAssertNil(negativeIndexResult2, "Out of bounds should return nil")
        
        let outOfBoundsIndexResult = array.findIndexAfterIndex(index: array.count, predicate: { _ in true })
        XCTAssertNil(outOfBoundsIndexResult, "Out of bounds should return nil")
        
        let outOfBoundsIndexResult2 = array.findIndexAfterIndex(index: array.count + 1, predicate: { _ in true })
        XCTAssertNil(outOfBoundsIndexResult2, "Out of bounds should return nil")
    }
    
    func testCollectionTypeFindIndexBeforeIndex() {
        
        let array = ["a", "b", "c", "a", "b", "c"]
        
        let first_c_index = array.index(where: { $0 == "c" })
        XCTAssert(first_c_index == 2, "Our c location should be accurate")
        
        let first_b_index = array.findIndexBeforeIndex(index: first_c_index!, predicate: { $0 == "b" })
        XCTAssert(first_b_index == 1, "Our first b location should be accurate")
        
        let second_a_index = array.findIndexBeforeIndex(index: 5, predicate: { $0 == "a" })
        XCTAssert(second_a_index == 3, "Our second a location should be accurate")
        
        let nil_c_index = array.findIndexBeforeIndex(index: 1, predicate: { $0 == "c" })
        XCTAssertNil(nil_c_index, "There are no `c`s before index 1")
        
        let d_index = array.findIndexBeforeIndex(index: array.count - 1, predicate: { $0 == "d" })
        XCTAssertNil(d_index, "There are no `d`s at all")
        
        let choose_previous_index = array.findIndexBeforeIndex(index: 2, predicate: { _ in true })
        XCTAssert(choose_previous_index == 1, "Should just choose the previous index")

        let last_index_should_be_nil = array.findIndexBeforeIndex(index: 0, predicate: { _ in true })
        XCTAssertNil(last_index_should_be_nil, "Calling findIndexAfterIndex on the first index should always return nil, since there is nothing before the first index!")
    }
    
    func testCollectionTypeFindIndexBeforeIndex_invalidInput() {
        
        let array = ["a", "b", "c", "a", "b", "c"]
        
        let negativeIndexResult = array.findIndexBeforeIndex(index: -2, predicate: { _ in true })
        XCTAssertNil(negativeIndexResult, "Out of bounds should return nil")
        
        let negativeIndexResult2 = array.findIndexBeforeIndex(index: -1, predicate: { _ in true })
        XCTAssertNil(negativeIndexResult2, "Out of bounds should return nil")
        
        let outOfBoundsIndexResult2 = array.findIndexBeforeIndex(index: array.count + 1, predicate: { _ in true })
        XCTAssertNil(outOfBoundsIndexResult2, "Out of bounds should return nil")
    }
    
}
