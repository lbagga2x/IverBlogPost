//
//  Device.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-25.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class Device: APIObject, NSCoding {
    var token:String?
    var deviceId:Int?
    var platform:String?
    var createdDate:Date?
    var production:Int?
    
    override func mapping(map: Map) {
        deviceId <- map["id"]
        token <- map["device_token"]
        platform <- map["platform"]
        createdDate <- (map["created_at"], JsonDateTransform())
        production <- map["production"]
    }
    
    required init?(map: Map) {
        super.init()
        
        mapping(map: map)
    }
    
    required init(coder decoder: NSCoder) {
        super.init()
        
        createdDate = decoder.decodeObject(forKey: "created_at") as? Date
        deviceId = decoder.decodeInteger(forKey: "device_id")
        token = decoder.decodeObject(forKey: "device_token") as? String
        platform = decoder.decodeObject(forKey: "platform") as? String
        production = decoder.decodeInteger(forKey: "production")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(createdDate!, forKey: "created_at")
        aCoder.encode(token!, forKey: "device_token")
        aCoder.encode(deviceId!, forKey: "device_id")
        aCoder.encode(platform!, forKey: "platform")
        aCoder.encode(production!, forKey: "production")
    }
    
    func logoutParameters() -> [String : Any] {
        return ["device_token" : token!, "production" : production!]
    }
}
