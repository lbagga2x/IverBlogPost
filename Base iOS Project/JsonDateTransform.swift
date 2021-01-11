//
//  JsonDateTransform.swift
//  Xpeeria
//
//  Created by Wes Goodhoofd on 2016-04-28.
//  Copyright © 2016 Iversoft. All rights reserved.
//

import UIKit
import ObjectMapper

class JsonDateTransform: NSObject,TransformType {
    internal typealias Object = Date
    internal typealias JSON = String
    
    override init() {
    }
    
    func transformFromJSON(_ value: Any?) -> Date? {
        if let dateString = value as? String {
            // formatter
            let formatter = DateFormatter()
            
            // timezone
            let timezone = TimeZone(secondsFromGMT: 0)
            formatter.timeZone = timezone
            
            // build formats to try
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                "yyyy-MM-dd HH:mm:ssZZZZZ",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd HH:mm ZZZZ",
                "yyyy-MM-dd"
            ]
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            return nil
        } else {
            return nil
        }
    }
    
    func transformToJSON(_ value: Date?) -> JsonDateTransform.JSON? {
        if value != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
            
            // timezone
            let timezone = TimeZone(secondsFromGMT: 0)
            formatter.timeZone = timezone
            
            return formatter.string(from: value!)
        } else {
            return nil
        }
    }
}
