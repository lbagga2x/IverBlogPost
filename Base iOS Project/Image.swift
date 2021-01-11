//
//  Image.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-02-21.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class Image: APIObject, NSCoding {
    var imageId: Int?
    var createdDate: Date?
    var updatedDate: Date?
    var sizes: Dictionary<String, AnyObject>?
    var filename: String?
    
    override func mapping(map: Map) {
        createdDate <- (map["created_at"], JsonDateTransform())
        updatedDate <- (map["updated_at"], JsonDateTransform())
        imageId <- map["id"]
        filename <- map["file_location"]
        
        sizes <- map["file_sizes"]
    }
    
    func findThumbnailUrl() -> String? {
        return findUrlForSize("thumb")
    }
    
    func findLargeUrl() -> String? {
        return findUrlForSize("large")
    }
    
    func findMediumUrl() -> String? {
        return findUrlForSize("medium")
    }
    
    func findOriginalUrl() -> String? {
        return findUrlForSize("original")
    }
    
    func findUrlForSize(_ key: String) -> String? {
        if let fileSize = sizes![key] as? Dictionary<String,AnyObject> {
            if let url = fileSize["url"] as? String {
                return url
            }
            return nil
        } else {
            return nil
        }
    }
    
    required init?(coder decoder: NSCoder) {
        super.init()
        
        createdDate = decoder.decodeObject(forKey: "created_date") as? Date
        updatedDate = decoder.decodeObject(forKey: "updated_date") as? Date
        imageId = decoder.decodeInteger(forKey: "image_id")
        sizes = decoder.decodeObject(forKey: "sizes") as? Dictionary<String,AnyObject>
    }
    
    required init?(map: Map) {
        super.init()
        
        mapping(map: map)
    }
    
    func encode(with aCoder: NSCoder) {
        if createdDate != nil {
            aCoder.encode(createdDate!, forKey: "created_date")
        }
        if updatedDate != nil {
            aCoder.encode(updatedDate!, forKey: "updated_date")
        }
        aCoder.encode(imageId!, forKey: "image_id")
        aCoder.encode(sizes!, forKey: "sizes")
    }
}
