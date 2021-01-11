//
//  AccountEditViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-01-25.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import Photos
import FBSDKLoginKit
import FacebookLogin

class AccountEditViewController: TextInputViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    @IBOutlet var nameField: UITextField?
    @IBOutlet var emailField: UITextField?
    @IBOutlet var passwordField: UITextField?
    @IBOutlet var verifyPasswordField: UITextField?
    @IBOutlet var dobButton: UIButton?
    @IBOutlet var genderButton: UIButton?
    @IBOutlet var profilePictureButton: UIButton?
    @IBOutlet var bioField: UITextView?
    @IBOutlet var saveButton: UIButton?
    @IBOutlet var inputList: [UIView]?
    var user: User?
    var hasChanges:Bool = false
    
    // picker options
    let genderOptions = [
        PickerEntry(label: NSLocalizedString("male", comment: ""), value: "male"),
        PickerEntry(label: NSLocalizedString("female", comment: ""), value: "female"),
        PickerEntry(label: NSLocalizedString("other", comment: ""), value: "other")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("account_edit", comment: "Account properties screen title")
        user = self.settingModel.user
        addDismissKeyboardToScrollView()
        addBackButton()
        
        // Do any additional setup after loading the view.
        nameField?.text = user?.name
        emailField?.text = user?.email
        bioField?.text = user?.biography
        setButtonTitles()
        
        // manually set the textview border
        //addBorderToInput(bioField!)
        
        // set the profile picture url if available
        profilePictureButton?.imageView?.contentMode = .scaleAspectFill
        if let profilePictureUrl = user?.profilePicture?.findMediumUrl() {
            profilePictureButton?.kf.setImage(with: URL(string:profilePictureUrl), for: .normal)
            Constants.debugPrint("loading picture \(profilePictureUrl)")
        }
        
        // create the logout button
        let logoutButtonIcon = UIImage(named: "logout.png")
        let logoutButton = UIBarButtonItem(image: logoutButtonIcon!, style: .plain, target: self, action: #selector(onLogoutButton))
        self.navigationItem.rightBarButtonItem = logoutButton
        
        bioField?.layer.cornerRadius = 5.0
        bioField?.layer.borderColor = UIColor.lightGray.cgColor
        bioField?.layer.borderWidth = 0.5
        saveButton?.layer.cornerRadius = 5.0
        
        // mark the inputs to track changes
        nameField?.addTarget(self, action: #selector(textInputDidChange), for: .valueChanged)
        emailField?.addTarget(self, action: #selector(textInputDidChange), for: .valueChanged)
        passwordField?.addTarget(self, action: #selector(textInputDidChange), for: .valueChanged)
        verifyPasswordField?.addTarget(self, action: #selector(textInputDidChange), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onSaveButton() {
        if hasValidInputs() {
            clearKeyboards()
            submitRequest()
        }
    }
    
    @objc func onLogoutButton() {
        let controller = UIAlertController(title: NSLocalizedString("log_out", comment: ""), message: NSLocalizedString("are_you_sure_logout", comment: ""), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment:"Dismiss error button label"), style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        let logoutAction = UIAlertAction(title: NSLocalizedString("log_out", comment:""), style: .default, handler: { (ACTION) -> Void in
            self.sendLogoutRequest()
        })
        controller.addAction(logoutAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func sendLogoutRequest() {
        // check if there's actually a device to logout
        if let currentDevice = settingModel.device {
            showProgress()
            Alamofire.request(SettingModel.APIRouter.logout(device: currentDevice))
                .validate(statusCode: 200..<300)
                .responseObject { (response: DataResponse<Device>) in
                    self.hideProgress()
                    switch response.result {
                    case .success:
                        self.settingModel.logUserOut()
                        LoginManager().logOut()
                        GIDSignIn.sharedInstance().signOut()
                        _ = self.navigationController?.popToRootViewController(animated: true)
                        break
                    case .failure(let error):
                        self.showResponseError(response.data, error: error)
                        break
                    }
            }
        } else {
            self.settingModel.logUserOut()
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func submitRequest() {
        showProgress()
        let parameters = buildParameters()
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            // properties
            self.multipartFormData(multipartFormData, encodeParameters: parameters)
            
            // photo
            if let userPhoto = self.user?.profilePictureImage {
                self.multipartFormData(multipartFormData, encodeImage: userPhoto, imageName: "profile_picture")
            }
        }, with: SettingModel.APIRouter.uploadProfileProperties(userId: settingModel.user!.userId!), encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.validate(statusCode: 200..<300)
                upload.responseObject { (response: DataResponse<User>) in
                    self.hideProgress()
                    
                    switch (response.result) {
                    case .success:
                        let user = response.result.value!
                        self.settingModel.logUserIn(user)
                        _ = self.navigationController?.popToRootViewController(animated: true)
                        break
                    case .failure(let error):
                        self.showResponseError(response.data, error: error)
                    }
                }
                break
            
            case .failure(let encodingError):
                print(encodingError)
                self.hideProgress()
                self.showErrorMessage(encodingError.localizedDescription)
                break
            }
        })
    }
    
    
    func buildParameters() -> [String : Any] {
        // build the required data based on the input fields
        var params = [String : Any]()
        
        params["email"] = emailField!.text!
        params["password"] = passwordField!.text!
        params["name"] = nameField!.text!
        params["biography"] = bioField!.text!
        if let dateOfBirth = user?.dateOfBirth {
            params["date_of_birth"] = user!.dateLabel(dateOfBirth)
        }
        if let gender = user?.gender {
            params["gender"] = gender
        }
        
        return params
    }
    
    func hasValidInputs() -> Bool {
        // check the different inputs for valid inputs
        if foundEmptyInputs(inputList!) {
            showErrorMessage(NSLocalizedString("invalid_inputs", comment: "Invalid text inputs"))
            return false
        }
        
        // validate the password fields because they are different
        if passwordField?.text != nil && verifyPasswordField?.text != nil && !passwordField!.text!.isEmpty && verifyPasswordField!.text!.isEmpty {
            markFieldInvalid(verifyPasswordField!)
            showErrorMessage(NSLocalizedString("invalid_inputs", comment: "Invalid text inputs"))
            return false
        } else {
            markFieldValid(verifyPasswordField!)
        }
        
        // check specific inputs for valid formats
        if !containsEmail(emailField!) {
            showErrorMessage(NSLocalizedString("invalid_email", comment: "Invalid email input"))
            return false
        }
        
        // passwords match so no one updates it unintentionally
        if !fieldsMatch(first: passwordField!, second: verifyPasswordField!) {
            showErrorMessage(NSLocalizedString("password_mismatch", comment: "Passwords don't match"))
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // due to the different settings like whether the input is required or not, it's easier to manually set this instead of using an array
        switch textField {
        case nameField!:
            emailField?.becomeFirstResponder()
            return false
        case emailField!:
            passwordField?.becomeFirstResponder()
            return false
        case passwordField!:
            verifyPasswordField?.becomeFirstResponder()
            return false
        case verifyPasswordField!:
            bioField?.becomeFirstResponder()
            return false
        case bioField!:
            return false
        default:
            return true
        }
    }
    
    @IBAction func onGenderButton() {
        clearKeyboards()
        
        // open the picker view and select from available options
        if pickerContainer == nil {
            createPickerContainer()
        }
        
        var index = 0
        if let gender = user?.gender {
            if let foundIndex = indexOfPickerEntry(key: gender, data: genderOptions) {
                index = foundIndex
            }
        }
        
        pickerData = genderOptions
        showDatePicker(false)
        togglePickerView(true, selectedIndex: index)
    }
    
    @IBAction func onDobButton() {
        clearKeyboards()
        
        // open the date picker view and select from  it
        if pickerContainer == nil {
            createPickerContainer()
        }
        
        if let dob = user?.dateOfBirth {
            datePicker?.setDate(dob, animated: false)
        } else {
            datePicker?.setDate(Date(), animated: false)
        }
        
        showDatePicker(true)
        togglePickerView(true)
    }
    
    override func onPickerDone() {
        // showing the date picker or data picker?
        if datePicker?.isHidden == false {
            user?.dateOfBirth = datePicker?.date
        } else if standardPicker?.isHidden == false {
            let gender = genderOptions[standardPicker!.selectedRow(inComponent: 0)]
            user?.gender = gender.value
        }
        
        hasChanges = true
        
        setButtonTitles()
        hidePickerView()
    }
    
    func setButtonTitles() {
        if let gender = user?.gender {
            if let pickerEntry = pickerEntryByKey(gender, data: genderOptions) {
                genderButton?.setTitle(pickerEntry.label, for: .normal)
            }
        }
        
        if let dob = user?.dateOfBirth {
            dobButton?.setTitle(user!.dateLabel(dob), for: .normal)
        }
    }

    @IBAction func onProfilePictureButton() {
        // present the photo picker
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.denied
        {
            showAlertMessage(NSLocalizedString("photo_library_access_denied_title", comment: ""), message: NSLocalizedString("photo_library_access_denied", comment: ""))
            return
        }
        
        // choose the source for the photos
        let controller = UIAlertController(title: NSLocalizedString("photo_source", comment: ""), message: NSLocalizedString("photo_source_message", comment: ""), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment:"Dismiss error button label"), style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: NSLocalizedString("camera", comment:""), style: .default, handler: { (ACTION) -> Void in
                self.presentPhotoPicker(.camera)
            })
            controller.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryAction = UIAlertAction(title: NSLocalizedString("photo_library", comment:""), style: .default, handler: { (ACTION) -> Void in
                self.presentPhotoPicker(.photoLibrary)
            })
            controller.addAction(libraryAction)
        }
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func presentPhotoPicker(_ type: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = type
        self.present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // cancelled
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // picked a photo, now add to the photo
        let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
        profilePictureButton?.setImage(image, for: .normal)
        
        user?.profilePictureImage = image
        
        picker.dismiss(animated: true, completion: nil)
        
        hasChanges = true
    }
    
    @objc func textInputDidChange() {
        // track changes to the user input for dismissing
        hasChanges = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        hasChanges = true
    }
    
    override func shouldGoBack() -> Bool {
        // check for changes and prompt if there are
        if hasChanges {
            let controller = UIAlertController(title: NSLocalizedString("unsaved_changes", comment: ""), message: NSLocalizedString("are_you_sure_go_back", comment: ""), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment:"Dismiss error button label"), style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            let goBackAction = UIAlertAction(title: NSLocalizedString("go_back", comment:""), style: .default, handler: { (ACTION) -> Void in
                _ = self.navigationController?.popViewController(animated: true)
            })
            controller.addAction(goBackAction)
            self.present(controller, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
}
