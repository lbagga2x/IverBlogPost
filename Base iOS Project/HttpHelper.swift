//
//  HttpHelper.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

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
    
    /// Add parameters to the form
    ///
    /// - Parameters:
    ///   - formData: Alamofire MultipartFormData object
    ///   - encodeParameters: The dictionary of parameters to encode
    static func multipartFormData(_ formData: MultipartFormData, encodeParameters parameters: [String : Any]) {
        for (key, value) in parameters {
            var data:Data?
            
            if let stringValue = value as? String {
                data = stringValue.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            } else if let boolValue = value as? Bool {
                let value = boolValue ? 1 : 0
                data = "\(value)".data(using: .utf8)!
            } else {
                let valueString = String(describing: value)
                data = valueString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            }
            
            if data != nil {
                formData.append(data!, withName: key)
            }
        }
    }
    
    /// Add an image object to the form
    ///
    /// - Parameters:
    ///   - formData: Alamofire MultipartFormData object
    ///   - encodeImage: The image object to encode
    static func multipartFormData(_ formData: MultipartFormData, encodeImage image: UIImage, imageName: String) {
        let resizedImage = image.resizeToWidth(1024.0)
        let imageData = resizedImage.jpegData(compressionQuality: 1)
        formData.append(imageData!, withName: imageName, fileName: "photo", mimeType: "image/jpg")
    }
}
