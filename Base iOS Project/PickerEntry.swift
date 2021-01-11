//
//  PickerEntry.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-03-09.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit

class PickerEntry: NSObject {
    var label: String?
    var value: String?
    
    init(label l: String, value v: String) {
        self.label = l
        self.value = v
    }
}
