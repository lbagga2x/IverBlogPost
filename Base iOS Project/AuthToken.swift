//
//  AuthToken.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-25.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class AuthToken: APIObject, NSCoding {
    var expiryDate:Date?
    var token:String?
    
    required init(coder decoder: NSCoder) {
        super.init()
        
        expiryDate = decoder.decodeObject(forKey: "expiry_date") as? Date
        token = decoder.decodeObject(forKey: "token") as? String
    }
    
    init(token t: String, expiryDate ed: Date) {
        super.init()
        self.expiryDate = ed
        self.token = t
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(expiryDate, forKey: "expiry_date")
        aCoder.encode(token, forKey: "token")
    }
    
    func hasExpired() -> Bool {
        let now = Date()
        if expiryDate == nil {
            return true
        }
        return (now > expiryDate!)
    }
}
