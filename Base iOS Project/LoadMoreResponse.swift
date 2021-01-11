//
//  LoadMoreResponse.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-26.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class LoadMoreResponse: APIObject {
    var remaining:Int?
    var limit:Int?
    var offset:Int?
    var total:Int?
    
    override func mapping(map: Map) {
        remaining <- map["remaining"]
        limit <- map["limit"]
        offset <- map["offset"]
        total <- map["total"]
    }
    
    func nextPageParameters() -> [String : Any] {
        offset! += limit!
        return ["limit" : limit ?? 0, "offset" : offset ?? 0]
    }
    
    func nextPageWithParameters(parameters: [String : Any]) -> [String : Any] {
        var nextPageParameters : [String : Any] = ["limit" : limit!, "offset" : offset! + limit!]
        
        if let order = parameters["order"] as? String {
            nextPageParameters["order"] = order
        }
        
        if let orderBy = parameters["orderby"] as? String {
            nextPageParameters["orderby"] = orderBy
        }
        
        return nextPageParameters
    }
    
    func canLoadMore() -> Bool {
        return (remaining ?? 0) > 0
    }
}
