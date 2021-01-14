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
import SwiftyJSON

class HttpClient {
    
    /// Use this for Normal API request
    /// - Parameters:
    ///   - apiRoute: URLRequestConvertible routes
    ///   - type: Type of response
    ///   - callback: To be called once response is received
    private func sendRequest<T: BaseMappable>(apiRoute: SettingModel.APIRouter, type: T.Type, callback: ApiCallback?) {
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
    
    /// Use this to upload images
    /// - Parameters:
    ///   - apiRoute: URLRequestConvertible routes
    ///   - image: Image to upload
    ///   - params: Parameters to send with this request
    ///   - type: Type of response
    ///   - callback: To be called once response is received
    private func uploadWithMultiForm<T: BaseMappable>(apiRoute: SettingModel.APIRouter, image: UIImage?, params: [String : Any]?, type: T.Type, callback: ApiCallback?) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            // properties
            if let params = params {
                HttpHelper.multipartFormData(multipartFormData, encodeParameters: params)
            }
            
            // photo
            if let photo = image { // Picture cannot be uploaded bec API is producing error
                //HttpHelper.multipartFormData(multipartFormData, encodeImage: photo, imageName: "picture")
            }
        }, with: apiRoute, encodingCompletion: { encodingResult in
            var dataResponse: HttpDataResponse?
            switch encodingResult {
            case .success(let upload, _, _):
                upload.validate(statusCode: 200..<300)
                upload.responseObject { (response: DataResponse<T>) in
                   
                    switch response.result {
                    case .success:
                        dataResponse = HttpDataResponse(data: response.data, baseMappable: response.result.value, error: nil)
                    case .failure(let error):
                        dataResponse = HttpDataResponse(data: response.data, baseMappable: nil, error: error)
                    }
                    callback?.onFinish(dataResponse)
                }
            case .failure(let encodingError):
                dataResponse = HttpDataResponse(data: nil, baseMappable: nil, error: encodingError)
                callback?.onFinish(dataResponse)
            }
        })
    }
    
    func createBlogPost<T: BaseMappable>(_ apiRoute: SettingModel.APIRouter, image: UIImage?, params: [String : Any], type: T.Type, _ callback: ApiCallback) {
        uploadWithMultiForm(apiRoute: apiRoute, image: image, params: params, type: BlogPost.self, callback: callback)
    }
}
