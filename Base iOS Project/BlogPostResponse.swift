//
//  BlogPostResponse.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-01-25.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class BlogPostResponse: LoadMoreResponse {
    var data:[BlogPost]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}
