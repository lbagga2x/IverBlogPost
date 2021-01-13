//
//  AddBlogPostViewController.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import RxSwift

class AddBlogPostViewController: TextInputViewController {
    
    class var Identifier: String {
        return "AddBlogPostViewController"
    }
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var blogContentField: UITextView!
    @IBOutlet var saveButton: UIButton?
    @IBOutlet var inputList: [UIView]?
    let viewModel = AddBlogPostViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        blogContentField.layer.borderWidth = 0.5
        blogContentField.layer.borderColor = UIColor.black.cgColor
        blogContentField.layer.cornerRadius = 6
        bindViews()
    }
    
    func bindViews() {
        setupLoadingObserver(viewModel: viewModel)
        setupErrorObserver(viewModel: viewModel)
        
        _ = viewModel.blogCreationWatcher.bind(onNext: { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
    
    //MARK: Actions
    @IBAction func onPostButtonPressed() {
        if foundEmptyInputs(inputList!) {
            showErrorMessage(NSLocalizedString("invalid_inputs", comment: "Invalid text inputs"))
            return
        }
        viewModel.onPostButtonPressed(blogTitle: titleField?.text, blogContent: blogContentField?.text, shouldPublish: true)
    }
}
