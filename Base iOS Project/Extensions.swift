//
//  Extensions.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import Foundation

extension Data {
    func decodeValue<T: Decodable>(type: T.Type) -> T? {
        do {
            return try HttpHelper.getJSONDecoder().decode(T.self, from: self)
        } catch {
            return nil
        }
    }
}
