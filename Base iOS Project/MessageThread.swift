//
//  MessageThread.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-04-03.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class MessageThread: APIObject {
    var threadId: Int?
    var createdDate: Date?
    var updatedDate: Date?
    var users: [User]?
    var author: User?
    var messages: [CmsMessage]?
    var unread: Bool = false
    
    override func mapping(map: Map) {
        threadId <- map["id"]
        createdDate <- (map["created_at"], JsonDateTransform())
        updatedDate <- (map["updated_at"], JsonDateTransform())
        users <- map["participants"]
        author <- map["author"]
        messages <- map["messages"]
        unread <- map["unread"]
    }
    
    func otherUser() -> User? {
        let settingModel = SettingModel.sharedModel()
        if users != nil {
            for user in users! {
                if user.userId != settingModel.user?.userId {
                    return user
                }
            }
        }
        return nil
    }
}
