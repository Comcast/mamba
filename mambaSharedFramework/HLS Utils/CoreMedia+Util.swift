//
//  CoreMedia+Util.swift
//  mamba
//
//  Created by David Coufal on 10/25/16.
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

import CoreMedia

public extension CMTime {
    static func += (lhs: inout CMTime, rhs: CMTime) {
        lhs = lhs + rhs
    }
    
    static var defaultMambaPrecision: Int32 {
        return 5
    }
}

public extension CMTimeScale {
    // the default CMTime time scale for Mamba
    static var defaultMambaTimeScale:Int32 {
        return Int32(__exp10(Double(CMTime.defaultMambaPrecision)))
    }
}
