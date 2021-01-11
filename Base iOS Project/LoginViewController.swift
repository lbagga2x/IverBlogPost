//
//  LoginViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-01-25.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import FacebookLogin

class LoginViewController: TextInputViewController, UITextFieldDelegate, LoginButtonDelegate, GIDSignInUIDelegate {
    @IBOutlet var emailField: UITextField?
    @IBOutlet var passwordField: UITextField?
    @IBOutlet var loginButton: UIButton?
    @IBOutlet var inputList: [UITextField]?
    @IBOutlet var registerButton: UIButton?
    @IBOutlet var forgotButton:UIButton?
    var fbLoginButton: LoginButton?
    @IBOutlet var stackView: UIStackView?
    var googleLoginButton: GIDSignInButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("login", comment: "Login screen title")
        addBackButton()
        
        // create the Facebook button
        fbLoginButton = LoginButton(readPermissions: [.email, .publicProfile])
        fbLoginButton?.delegate = self
        stackView?.addArrangedSubview(fbLoginButton!)
        
        // handle the Google login
        GIDSignIn.sharedInstance().uiDelegate = self
        googleLoginButton = GIDSignInButton()
        stackView?.addArrangedSubview(googleLoginButton!)

        // Do any additional setup after loading the view.
        addDismissKeyboardToScrollView()
        
        loginButton?.layer.cornerRadius = 5.0
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
    
    @IBAction func onLoginButton() {
        if hasValidInputs() {
            clearKeyboards()
            
            // standard login, so use email/password
            let parameters = buildParameters()
            submitRequest(parameters)
        }
    }
    
    public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        // check for error, get a login token and log into the server
        switch result {
        case .success(_, _, let token):
            Constants.debugPrint("logging in with token \(token.authenticationToken)")
            submitRequest(["facebook_access_token" : token.authenticationToken])
            break
        case .failed(let error):
            self.showErrorMessage(error.localizedDescription)
            break
        case .cancelled:
            Constants.debugPrint("Cancelled login")
            break
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: LoginButton) {
        let loginManager: LoginManager = LoginManager()
        loginManager.logOut()
        settingModel.logUserOut()
    }
    
    public func handleGoogleLogin(_ token: String) {
        submitRequest(["google_auth_code" : token])
    }
    
    func submitRequest(_ parameters: [String : Any]) {
        showProgress()
        
        // add the device token if the user has agreed to notifications
        var authParameters = parameters
//        if let deviceToken = settingModel.deviceToken {
//            let deviceSettings = settingModel.deviceData(deviceToken)
//            authParameters["device"] = deviceSettings
//        }
        
        Alamofire.request(SettingModel.APIRouter.authenticate(parameters: authParameters))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<LoginResponse>) in
                self.hideProgress()
                switch response.result {
                case .success:
                    let userResponse = response.result.value
                    self.settingModel.logUserIn(userResponse!.user!)
                    self.settingModel.setAuthTokenValues(token: userResponse?.token, expiryDate: userResponse?.expiryDate)
                    
                    if let device = userResponse?.device {
                        self.settingModel.saveDevice(device)
                    }
                    
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
        
        params["email"] = emailField!.text!
        params["password"] = passwordField!.text!
        
        return params
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
            passwordField!.becomeFirstResponder()
            return false
        } else if textField == passwordField {
            onLoginButton()
            return true
        } else {
            return true
        }
    }
    
    @IBAction func onForgotButton() {
        let controller = ForgotAccountViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onRegisterButton() {
        let controller = RegisterViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
