//
//  HttpHelper.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class ApiCallback {
    var onFinish: (HttpDataResponse?) -> Void
    init(onFinish: @escaping (HttpDataResponse?) -> Void) {
        self.onFinish = onFinish
    }
}

struct HttpDataResponse {
    let data: Data?
    let baseMappable: BaseMappable?
    let error: Error?
}

class HttpHelper {
    /// To be used to decode Custom Objects
    /// - Returns: Json Decoder with key strategy of `convertFromSnakeCase`.
    static func getJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
