//
//  User.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-25.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class User: APIObject, NSCoding {
    var createdDate:Date?
    var name:String?
    var email:String?
    var userId:Int?
    var dateOfBirth: Date?
    var gender: String?
    var profilePicture:Image?
    var biography:String?
    
    // profile picture
    var profilePictureImage:UIImage?
    
    override func mapping(map: Map) {
        userId <- map["id"]
        createdDate <- (map["created_at"], JsonDateTransform())
        name <- map["name"]
        email <- map["email"]
        gender <- map["gender"]
        dateOfBirth <- (map["date_of_birth"], JsonDateTransform())
        profilePicture <- map["profile_picture"]
        biography <- map["biography"]
    }
    
    required init?(map: Map) {
        super.init()
        
        mapping(map: map)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init()
        
        createdDate = decoder.decodeObject(forKey: "created_date") as? Date
        userId = decoder.decodeInteger(forKey: "user_id")
        name = decoder.decodeObject(forKey: "name") as? String
        email = decoder.decodeObject(forKey: "email") as? String
        profilePicture = decoder.decodeObject(forKey: "profile_picture") as? Image
        biography = decoder.decodeObject(forKey: "biography") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        if createdDate != nil {
            aCoder.encode(createdDate!, forKey: "created_date")
        }
        aCoder.encode(userId!, forKey: "user_id")
        aCoder.encode(email!, forKey: "email")
        aCoder.encode(name!, forKey: "name")
        if profilePicture != nil {
            aCoder.encode(profilePicture!, forKey: "profile_picture")
        }
        if biography != nil {
            aCoder.encode(biography!, forKey: "biography")
        }
    }
    
    func searchName() -> String {
        var components = Array<String>()
        if let userName = name {
            components.append(userName)
        }
        if let userEmail = email {
            components.append(userEmail)
        }
        return components.joined(separator: " - ")        
    }
}
