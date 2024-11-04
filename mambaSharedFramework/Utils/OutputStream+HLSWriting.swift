//
//  OutputStream+HLSWriting.swift
//  mamba
//
//  Created by Andrew Morrow on 2/9/17.
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

#if SWIFT_PACKAGE
import HLSObjectiveC
#endif

public enum OutputStreamError: Error {
    case couldNotWriteToStream(NSError?)
    case invalidData(description: String?)
}

extension OutputStream {
    func write(stringRef: MambaStringRef) throws {
        guard self.hasSpaceAvailable else {
            throw OutputStreamError.couldNotWriteToStream(self.streamError as NSError?)
        }
        
        let length = Int(stringRef.length)
        try stringRef.utf8Bytes().withMemoryRebound(to: UInt8.self, capacity: length) { castBytes in
            guard self.write(castBytes, maxLength: length) == length else {
                throw OutputStreamError.couldNotWriteToStream(self.streamError as NSError?)
            }
        }
    }
    
    func write(data: Data) throws {
        guard self.hasSpaceAvailable else {
            throw OutputStreamError.couldNotWriteToStream(self.streamError as NSError?)
        }
        
        let written = try data.withUnsafeBytes{ (unsafeRawBufferPointer: UnsafeRawBufferPointer) -> Int in
            let bufferPointer = unsafeRawBufferPointer.bindMemory(to: UInt8.self)
            guard let baseAddress = bufferPointer.baseAddress else {
                throw OutputStreamError.invalidData(description: "Cannot find baseAddress for buffer pointer")
            }
            return self.write(baseAddress, maxLength: data.count)
        }
        
        guard written == data.count else {
            throw OutputStreamError.couldNotWriteToStream(self.streamError as NSError?)
        }
    }
    
    /// The string must be UTF-8 encodable.
    func write(string: String) throws {
        // The utf8CString is null-terminated. We do not want to write the null byte.
        guard string.utf8CString.count > 1 else {
            return
        }
        
        guard self.hasSpaceAvailable else {
            throw OutputStreamError.couldNotWriteToStream(self.streamError as NSError?)
        }
        
        let written = string.utf8CString.withUnsafeBytes { buffer -> Int in
            return self.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self), maxLength: buffer.count - 1)
        }
        
        guard written == string.utf8CString.count - 1 else {
            throw OutputStreamError.couldNotWriteToStream(self.streamError as NSError?)
        }
    }
    
    /// The character to be written must be representable as ASCII (values 0-127).
    func write(unicodeScalar: UnicodeScalar) throws {
        guard unicodeScalar.isASCII else {
            throw OutputStreamError.invalidData(description: "Unicode scalar \(unicodeScalar) cannot be represented as ASCII")
        }
        
        guard self.hasSpaceAvailable else {
            throw OutputStreamError.couldNotWriteToStream(self.streamError as NSError?)
        }
        
        var value = UInt8(ascii: unicodeScalar)
        guard self.write(&value, maxLength: 1) == 1 else {
            throw OutputStreamError.couldNotWriteToStream(self.streamError as NSError?)
        }
    }
}
