//
//  AddBlogPostViewController.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import UIKit

class AddBlogPostViewController: TextInputViewController {
    
    class var Identifier: String {
        return "AddBlogPostViewController"
    }
    
    @IBOutlet var titleField: UITextField?
    @IBOutlet var contentField: UITextView?
    @IBOutlet var saveButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPostButtonPressed() {
        
    }
}
