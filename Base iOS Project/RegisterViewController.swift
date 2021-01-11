//
//  RegisterViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-01-25.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class RegisterViewController: TextInputViewController, UITextFieldDelegate {
    @IBOutlet var nameField: UITextField?
    @IBOutlet var emailField: UITextField?
    @IBOutlet var passwordField: UITextField?
    @IBOutlet var verifyPasswordField: UITextField?
    @IBOutlet var registerButton: UIButton?
    @IBOutlet var inputList: [UIView]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("register", comment: "Register account screen title")
        addBackButton()

        // Do any additional setup after loading the view.
        addDismissKeyboardToScrollView()
        
        registerButton?.layer.cornerRadius = 5.0
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
    
    @IBAction func onRegisterButton() {
        // check for valid content and send registration request
        if hasValidInputs() {
            sendRegistration()
        }
    }
    
    func sendRegistration() {
        // actually send the registration request        
        showProgress()
        
        let parameters = buildParameters()
        Alamofire.request(SettingModel.APIRouter.registerUser(parameters: parameters))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<LoginResponse>) in
                self.hideProgress()
                switch response.result {
                case .success:
                    let userResponse = response.result.value
                    self.settingModel.logUserIn(userResponse!.user!)
                    self.settingModel.setAuthTokenValues(token: userResponse!.token, expiryDate: userResponse!.expiryDate)
                    _ = self.navigationController?.popToRootViewController(animated: true)
                    break
                case .failure(let error):
                    self.showResponseError(response.data, error: error)
                    break
            }
        }
    }

    func buildParameters() -> [String : Any] {
        // build the required data based on the input fields
        var params = [String : Any]()
        
        params["name"] = nameField!.text!
        params["email"] = emailField!.text!
        params["password"] = passwordField!.text!
        
        return params
    }
    
    func hasValidInputs() -> Bool {
        // check the different inputs for valid inputs -- list will highlight all invalid inputs
        if foundEmptyInputs(inputList!) {
            showErrorMessage(NSLocalizedString("invalid_inputs", comment: "Invalid text inputs"))
            return false
        }
        
        if !containsEmail(emailField!) {
            showErrorMessage(NSLocalizedString("invalid_email", comment: "Invalid email input"))
            return false
        }
        
        if !fieldsMatch(first: passwordField!, second: verifyPasswordField!) {
            showErrorMessage(NSLocalizedString("passwords_dont_match", comment: "Invalid password matching input"))
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
            onRegisterButton()
            return true
        default:
            return true
        }
    }

}
