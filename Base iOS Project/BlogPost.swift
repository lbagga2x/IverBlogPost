//
//  BlogPost.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-01-25.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class BlogPost: APIObject {
    var blogPostId: Int?
    var title: String?
    var createdDate: Date?
    var updatedDate: Date?
    var content: String?
    var published: Bool = false
    var image: Image?
    var author: User?

    override func mapping(map: Map) {
        blogPostId <- map["id"]
        title <- map["title"]
        createdDate <- (map["created_at"], JsonDateTransform())
        updatedDate <- (map["updated_at"], JsonDateTransform())
        content <- map["content"]
        published <- map["published"]
        image <- map["image"]
        author <- map["author_user"]
    }
}
