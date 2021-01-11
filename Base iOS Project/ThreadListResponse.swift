//
//  MessageListResponse.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-03-28.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class ThreadListResponse: LoadMoreResponse {
    var data: [MessageThread]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}
