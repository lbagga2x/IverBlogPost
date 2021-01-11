//
//  APIObject.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-25.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class APIObject: NSObject, Mappable {
    required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    override init() {}
    
    func mapping(map: Map) {
        // overridden
    }
    
    func monthLabel(_ date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: date)
    }
    
    func dateLabel(_ date:Date, format:String? = "YYYY-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        // when the hour, minute and offset are all 0, we don't want local time because generally that indicates a date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .timeZone], from: date)
        if components.hour == 0 && components.minute == 0 && components.timeZone?.secondsFromGMT() == 0 {
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return dateFormatter.string(from: date)
    }
    
    func dateTimeLabel(_ date: Date) -> String {
        return dateLabel(date, format: "MMM d, Y h:mm a")
    }
    
    func mysqlDateFromDate(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        return formatter.string(from: date)
    }
    
    func timeOnly(_ date:Date) -> String {        
        let formatter = DateFormatter()
        
        let timezone = TimeZone(secondsFromGMT: 0)
        formatter.timeZone = timezone
        
        formatter.dateFormat = "h:mm a ZZZ"
        return formatter.string(from: date)
    }
    
    func dateFromUTCDateTime(string:String?) -> Date? {
        if string == nil {
            return nil
        }
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
            "yyyy-MM-dd HH:mm ZZZZ"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string!) {
                return date
            }
        }
        return nil
    }
    
    func dateOrLabel(_ providedDate: Date?) -> String {
        if let date = providedDate {
            return dateLabel(date)
        } else {
            return NSLocalizedString("no_date", comment: "Cannot determine date")
        }
    }
    
    func shortDateOrLabel(_ providedDate: Date?) -> String {
        // a smarter label for displaying a date only
        if let date = providedDate {
            // determine the format by comparing the year
            let calendar = Calendar.current
            let now = Date()
            let nowYear = calendar.component(.year, from: now)
            let dateYear = calendar.component(.year, from: date)
            
            if nowYear != dateYear {
                return dateLabel(date, format: "MMM d, YYYY")
            } else {
                return dateLabel(date, format: "MMM d")
            }
        } else {
            return NSLocalizedString("no_date", comment: "Cannot determine date")
        }
    }
}
