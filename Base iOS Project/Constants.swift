//
//  Constants.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-26.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import UIKit

class Constants {
    static let accentColour = UIColor.init(red: 24/255.0, green: 178/255.0, blue: 141/255.0, alpha: 1.0)
    static let blueColour = UIColor.init(red: 19/255.0, green: 89/255.0, blue: 153/255.0, alpha: 1.0)
    static let redColour = UIColor.init(red: 242/255.0, green: 38/255.0, blue: 19/255.0, alpha: 1.0)
    static let greenColour = UIColor.init(red: 39/255.0, green: 132/255.0, blue: 19/255.0, alpha: 1.0)
    static let grayColour = UIColor.init(white: 215/255.0, alpha: 1.0)
    static let disabledInputColor = UIColor(white: 195/255.0, alpha: 1.0)
    static let enabledInputColor = UIColor.lightGray
    static let mainFontName = "Lato"
    static let boldFontName = "Lato Bold"
    static let italicFontName = "Lato Italic"
    static let resultLimit = 20
    static let sectionTitleHeight:CGFloat = 36.0
    
    static func chooseLanguageString(en:String, fr:String?) -> String {
        let languageCode = Locale.current.languageCode
        if languageCode == "fr" && fr != nil {
            return fr!
        } else {
            return en
        }
    }
    
    static func dateLabel(_ date:Date, format:String? = "MMMM d, YYYY") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    /* Use these helper methods to print debugging information only when developing */
    static func debugPrint(_ value:Any) {
        #if DEBUG
            Swift.debugPrint(value)
        #endif
    }
    
    static func debugPrintFormat(_ string:String, values: Any...) {
        #if DEBUG
            Swift.debugPrint(String.init(format: string, values))
        #endif
    }
    
    static func findErrorInResponse(_ data:Data?) -> String? {
        if let responseData = data {
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: []) {
                if let jsonDict = json as? Dictionary<String, Any> {
                    for key in jsonDict.keys {
                        if let messageArray = jsonDict[key] as? Array<String> {
                            if let messageString = messageArray.first {
                                return messageString
                            }
                        } else if let messageString = jsonDict[key] as? String {
                            return messageString
                        }
                    }
                }
            }
        }
        return nil
    }
}
