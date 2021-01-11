//
//  ForgotAccountViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-01-25.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class ForgotAccountViewController: TextInputViewController, UITextFieldDelegate {
    @IBOutlet var emailField: UITextField?
    @IBOutlet var submitButton: UIButton?
    @IBOutlet var inputList: [UIView]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("forgot_account", comment: "Forgot account details screen title")
        addBackButton()

        // Do any additional setup after loading the view.
        addDismissKeyboardToScrollView()
        
        submitButton?.layer.cornerRadius = 5.0
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
    
    @IBAction func onSubmitButton() {
        if hasValidInputs() {
            clearKeyboards()
            submitRequest(emailField!.text!)
        }
    }
    
    func submitRequest(_ email: String) {
        showProgress()
        Alamofire.request(SettingModel.APIRouter.forgotPassword(email: email))
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                self.hideProgress()
                switch response.result {
                case .success:
                    let jsonData = response.result.value
                    if let jsonDict = jsonData as? [String : Any] {
                        if let successMessage = jsonDict["success"] as? String {
                            self.showAlertMessage(NSLocalizedString("email_reset", comment: "Email reset alert title"), message: successMessage)
                        } else {
                            // show an alert
                            self.showAlertMessage(NSLocalizedString("email_reset", comment: "Email reset alert title"), message: NSLocalizedString("email_reset_error", comment: ""))
                        }
                    }
                    break
                case .failure(let error):
                    self.showResponseError(response.data, error: error)
                    break
                }
        }
    }
    
    func hasValidInputs() -> Bool {
        // the input list for blank values
        if foundEmptyInputs(inputList!) {
            showErrorMessage(NSLocalizedString("invalid_inputs", comment: "Invalid text inputs"))
            return false
        }
        
        // check specific inputs for valid formats
        if !containsEmail(emailField!) {
            showErrorMessage(NSLocalizedString("invalid_email", comment: "Invalid email input"))
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            onSubmitButton()
        }
        return true
    }
}
