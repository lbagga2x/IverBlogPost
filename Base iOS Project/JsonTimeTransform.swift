//
//  JsonDateTransform.swift
//  Xpeeria
//
//  Created by Wes Goodhoofd on 2016-04-28.
//  Copyright © 2016 Iversoft. All rights reserved.
//

import UIKit
import ObjectMapper

class JsonTimeTransform: NSObject,TransformType {
    internal typealias Object = Date
    internal typealias JSON = String
    
    func transformFromJSON(_ value: Any?) -> Date? {
        if let dateString = value as? String {
            // formatter
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            
            // timezone
            let timezone = TimeZone(secondsFromGMT: 0)
            formatter.timeZone = timezone
            
            return formatter.date(from: dateString)
        } else {
            return nil
        }
    }
    
    func transformToJSON(_ value: Date?) -> JsonDateTransform.JSON? {
        if value != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            
            // timezone
            let timezone = TimeZone(secondsFromGMT: 0)
            formatter.timeZone = timezone
            
            return formatter.string(from: value!)
        } else {
            return nil
        }
    }
}
