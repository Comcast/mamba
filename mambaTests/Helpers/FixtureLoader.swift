//
//  FixtureLoader.swift
//  mamba
//
//  Created by David Coufal on 6/8/16.
//  Copyright © 2016 David Coufal. All rights reserved.
//

import Foundation


@objc public class FixtureLoader: NSObject {
    
    public class func load(fixtureName: NSString) -> NSData? {
        let bundle = Bundle(for: FixtureLoader.self)
        let fixturePath = bundle.path(forResource: fixtureName.deletingPathExtension, ofType: fixtureName.pathExtension)
        if let fixturePath = fixturePath {
            return NSData(contentsOfFile: fixturePath)
        }
        return nil
    }
    
    public class func loadAsString(fixtureName: NSString) -> String? {
        let data = self.load(fixtureName: fixtureName)
        if let data = data {
            return String(data: data as Data, encoding: String.Encoding.utf8)
        }
        return nil
    }
}
