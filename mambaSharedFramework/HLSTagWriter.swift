//
//  HLSTagWriter.swift
//  mamba
//
//  Created by David Coufal on 7/12/16.
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

/// Describes an object that can serialize individual HLSTag objects
public protocol HLSTagWriter {
    
    /**
     Writes the data of the tag to the provided OutputStream.
     Does not need to write newlines (handled by the caller).
     
     - parameter tag: The HLSTag to write to the stream
     
     - parameter toStream: An open `OutputStream` to recieve data.
     
     - throws: Error if there is an issue writing to the stream
     */
    func write(tag: HLSTag, toStream: OutputStream) throws
}

internal struct HLSTagWritingSeparators {
    static let hash = UnicodeScalar("#")
    static let colon = UnicodeScalar(":")
    static let newline = UnicodeScalar("\n")
}
