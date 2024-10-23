//
//  String+DateParsing.swift
//  mamba
//
//  Created by David Coufal on 8/3/16.
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

extension String {
    
    struct DateFormatter {
        static let iso8601MS: Foundation.DateFormatter = {
            let formatter = Foundation.DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.autoupdatingCurrent
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
            return formatter
        }()
        static let iso8601: Foundation.DateFormatter = {
            let formatter = Foundation.DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.autoupdatingCurrent
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
            return formatter
        }()
    }
    
    /// parse this string as a ISO8601 date if possible, return nil if impossible   
    public func parseISO8601Date() -> Date? {
        if let date = DateFormatter.iso8601MS.date(from: self) {
            return date
        }
        return DateFormatter.iso8601.date(from: self)
    }
}
