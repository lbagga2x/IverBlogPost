//
//  HttpClient.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class HttpClient {
    private func sendRequest<T: BaseMappable>(apiRoute: SettingModel.APIRouter,  type: T.Type, callback: ApiCallback?) {
        Alamofire.request(apiRoute)
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<T>) in
                var dataResponse: HttpDataResponse?
                switch response.result {
                case .success:
                    dataResponse = HttpDataResponse(data: response.data, baseMappable: response.result.value, error: nil)
                case .failure(let error):
                    dataResponse = HttpDataResponse(data: response.data, baseMappable: nil, error: error)
                }
                callback?.onFinish(dataResponse)
            }
    }
    
    func createBlogPost<T: BaseMappable>(_ apiRoute: SettingModel.APIRouter, type: T.Type, _ callback: ApiCallback) {
        sendRequest(apiRoute: apiRoute, type: type, callback: callback)
    }
}
