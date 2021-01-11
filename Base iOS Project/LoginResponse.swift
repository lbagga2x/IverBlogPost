//
//  LoginResponse.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-02-16.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class LoginResponse: APIObject {
    var token: String?
    var expiryDate: Date?
    var user: User?
    var device: Device?
    
    override func mapping(map: Map) {
        token <- map["token"]
        user <- map["user"]
        expiryDate <- (map["expires"], JsonDateTransform())
        device <- map["user_device"]
    }
}
