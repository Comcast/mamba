//
//  HLSWriterImpl.swift
//  mamba
//
//  Created by David Coufal on 8/2/16.
//  Copyright © 2016 Comcast Corporation. This software and its contents are
//  Comcast confidential and proprietary. It cannot be used, disclosed, or
//  distributed without Comcast's prior written permission. Modification of this
//  software is only allowed at the direction of Comcast Corporation. All allowed
//  modifications must be provided to Comcast Corporation. All rights reserved.
//

import Foundation

class HLSWriterImpl: HLSWriter {
        
    /// Writes a `HLSManifest` object to a stream. Caller is assumed to be responsible for opening and closing this stream.
    func write(hlsManifest:HLSManifest, stream: OutputStream) throws {
        
        guard stream.hasSpaceAvailable else {
            throw HLSWriterError.couldNotWriteToStream(description: stream.streamError.debugDescription)
        }
        
        try write(string: HLS.headerHLSTag, toStream: stream)
        try write(string: "\n", toStream: stream)
        
        for index in 0..<hlsManifest.tags.count {
            try write(string: hlsManifest.tags[index].toString(), toStream: stream)
        }
    }
    
    /// Writes a `HLSManifest` object to a string. String could be very large.
    func write(hlsManifest:HLSManifest) throws -> String {
        
        var string = String()
        
        string = string + HLS.headerHLSTag
        string = string + "\n"
        
        for index in 0..<hlsManifest.tags.count {
            string = try string + hlsManifest.tags[index].toString()
        }
        
        return string
    }
    
    fileprivate func write(string: String, toStream stream: OutputStream) throws {
        guard let data: Data = string.data(using: String.Encoding.utf8) else {
            throw HLSWriterError.invalidData(description: "Could not stream string: \"\(string)\"")
        }
        let result = stream.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), maxLength: data.count)
        if result == 0 {
            throw HLSWriterError.couldNotWriteToStream(description: "Stream at capacity")
        }
        if result < 0 {
            throw HLSWriterError.couldNotWriteToStream(description: "Stream Error #\(result) desc:\"\(stream.streamError.debugDescription)\"")
        }
        assert(result == data.count)
    }
}
