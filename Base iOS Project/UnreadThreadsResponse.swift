//
//  UnreadThreadsResponse.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-04-07.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class UnreadThreadsResponse: APIObject {
    var unreadThreads: Int?
    
    override func mapping(map: Map) {
        unreadThreads <- map["unread_threads"]
    }
}
