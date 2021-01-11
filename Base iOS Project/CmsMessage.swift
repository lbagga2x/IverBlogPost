//
//  Message.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-03-28.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class CmsMessage: APIObject {
    var messageId: Int?
    var createdDate: Date?
    var updatedDate: Date?
    var userId: Int?
    var content: String?
    var image: Image?
    var read: Bool = true
    
    override func mapping(map: Map) {
        messageId <- map["id"]
        createdDate <- (map["created_at"], JsonDateTransform())
        updatedDate <- (map["updated_at"], JsonDateTransform())
        content <- map["body"]
        userId <- map["user_id"]
        image <- map["photo"]
        read <- map["read"]
    }
}
