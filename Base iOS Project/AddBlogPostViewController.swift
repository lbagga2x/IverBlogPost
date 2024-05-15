//
//  AddBlogPostViewController.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import RxSwift
import DKImagePickerController

class AddBlogPostViewController: TextInputViewController {
    
    class var Identifier: String {
        return "AddBlogPostViewController"
    }
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var blogContentField: UITextView!
    @IBOutlet var saveButton: UIButton?
    @IBOutlet var switchButton: UISwitch!
    @IBOutlet var inputList: [UIView]?
    @IBOutlet var blogImageView: UIImageView!
    @IBOutlet var addPictureButton: UIButton!
    let viewModel = AddBlogPostViewModel()
    let disposeBag = DisposeBag()
    let pickerController = DKImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViews()
        titleField.delegate = self
    }
    
    func setupView() {
        //Config Picker
        pickerController.sourceType = .photo
        pickerController.singleSelect = true
        pickerController.autoCloseOnSingleSelect = true
        pickerController.assetType = .allPhotos
        pickerController.maxSelectableCount = 1
        
        //Draw border for blog content field
        blogContentField.layer.borderWidth = 0.5
        blogContentField.layer.borderColor = UIColor.black.cgColor
        blogContentField.layer.cornerRadius = 6
        
        titleField.returnKeyType = .next
    }
    
    func bindViews() {
        setupLoadingObserver(viewModel: viewModel)
        setupErrorObserver(viewModel: viewModel)
        
        _ = viewModel.blogCreationWatcher.bind(onNext: { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        _ = viewModel.imageWatcher.bind(onNext: { [weak self](image) in
            guard let self = self else {return}
            if let image = image {
                self.blogImageView.image = image
                self.addPictureButton.setTitle(NSLocalizedString("change_picture", comment: "Change the Picture"), for: .normal)
            }
            
        }).disposed(by: disposeBag)
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            self.viewModel.onImageSelected(assets: assets)
        }
    }
    
    //MARK: Actions
    @IBAction func onPostButtonPressed() {
        if foundEmptyInputs(inputList!) {
            showErrorMessage(NSLocalizedString("invalid_inputs", comment: "Invalid text inputs"))
            return
        }
        viewModel.onPostButtonPressed(blogTitle: titleField?.text, blogContent: blogContentField?.text, shouldPublish: switchButton.isOn)
    }
    
    @IBAction func onAddPicturePressed() {
        pickerController.deselectAll()
        present(pickerController, animated: true, completion: nil)
    }
}

extension AddBlogPostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            blogContentField.becomeFirstResponder()
        }
        return true
    }
}
