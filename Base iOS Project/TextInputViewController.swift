//
//  TextInputViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-02-14.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit

class TextInputViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // scroll view
    @IBOutlet var scroll: UIScrollView?
    
    // input views
    var inputTextFields: [UITextField] = [UITextField]()
    var inputTextViews: [UITextView] = [UITextView]()
    
    // picker containers
    var pickerContainer: UIView?
    var hidePicker: UIView?
    var datePicker: UIDatePicker?
    var standardPicker: UIPickerView?
    var pickerDoneButton: UIButton?
    var pickerData: [PickerEntry]?
    var pickerVisible: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDismissKeyboardToScrollView() {
        addDismissKeyboardToView(scroll!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Text validation
    func hasText(textField:UITextField) -> Bool {
        if textField.text!.isEmpty && textField.isEnabled == true {
            return false
        } else {
            return true
        }
    }
    
    func hasText(textView:UITextView) -> Bool {
        if textView.text!.isEmpty && textView.isEditable == true {
            return false
        } else {
            return true
        }
    }
    
    // from http://swiftdeveloperblog.com/email-address-validation-in-swift/
    func containsEmail(_ input:UITextField) -> Bool {
        var returnValue = true
        if let emailAddressString = input.text {
            let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
            
            do {
                let regex = try NSRegularExpression(pattern: emailRegEx)
                let nsString = emailAddressString as NSString
                let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
                
                if results.count == 0
                {
                    returnValue = false
                }
                
            } catch let error as NSError {
                Constants.debugPrint("invalid regex: \(error.localizedDescription)")
                returnValue = false
                }
        } else {
            returnValue = false
        }
        
        return  returnValue
    }
    
    func fieldsMatch(first: UITextField, second: UITextField) -> Bool {
        return first.text == second.text
    }
    
    func addBorderToInput(_ input:UIView, enabled:Bool = true) {
        if (enabled == true) {
            input.layer.borderColor = nil
            
        } else {
            input.layer.borderColor = Constants.disabledInputColor.cgColor
        }
    }
    
    func setInputBorder(_ view:UIView, valid: Bool) {
        if valid {
            markFieldValid(view)
        } else {
            markFieldInvalid(view)
        }
    }
    
    func markFieldInvalid(_ view:UIView) {
        view.layer.borderWidth = 2.0
        view.layer.borderColor = Constants.redColour.cgColor
        view.layer.cornerRadius = 5.0
    }
    
    func markFieldValid(_ view:UIView) {
        view.layer.borderWidth = 0.0
        view.layer.borderColor = nil
    }
    
    /// Take a list of text fields and mark them invalid or not
    ///
    /// - Parameter inputs: Array of UITextField elements
    func foundEmptyInputs(_ inputs: [UIView]) -> Bool {
        var hasInvalidInput = false
        for input in inputs {
            var valid = true
            if let field = input as? UITextField {
                valid = hasText(textField: field)
            } else if let textView = input as? UITextView {
                valid = hasText(textView: textView)
            }
            setInputBorder(input, valid: valid)
            
            if !valid {
                hasInvalidInput = true
            }
        }
        return hasInvalidInput
    }
    
    // MARK: - picker views
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let count = pickerData?.count ?? 0
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let selectedRow = pickerData?[row] {
            return selectedRow.label
        } else {
            return nil
        }
    }
    
    func togglePickerView(_ show:Bool, selectedIndex:Int = 0) {
        if show == true {
            standardPicker?.reloadComponent(0)
            standardPicker?.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        
        var endFrame:CGRect = pickerContainer!.frame;
        if show {
            endFrame.origin.y -= endFrame.size.height;
        } else {
            endFrame.origin.y += endFrame.size.height;
        }
        pickerVisible = show
        hidePicker?.isHidden = !show;
        
        UIView.beginAnimations("picker", context: nil)
        UIView.setAnimationCurve(UIView.AnimationCurve.easeInOut)
        UIView.setAnimationDuration(0.15)
        
        pickerContainer?.frame = endFrame;
        
        if show == true {
            hidePicker!.alpha = 0.5
        } else {
            hidePicker!.alpha = 0
        }
        
        UIView.commitAnimations()
    }
    
    @objc func hidePickerView() {
        togglePickerView(false)
    }
    
    func showDatePicker(_ show: Bool) {
        datePicker?.isHidden = !show
        standardPicker?.isHidden = show
    }
    
    func createPickerContainer() {
        hidePicker = UIView(frame: self.view.bounds)
        hidePicker?.backgroundColor = UIColor.black
        hidePicker?.alpha = 0.5
        hidePicker?.isHidden = true
        hidePicker?.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        hidePicker?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hidePickerView)))
        hidePicker?.isAccessibilityElement = true
        hidePicker?.accessibilityTraits = UIAccessibilityTraits.button
        hidePicker?.accessibilityHint = NSLocalizedString("dismiss_picker_hint", comment: "Dismiss picker button hint")
        self.view.addSubview(hidePicker!)
        
        let pickerViewHeight:CGFloat = 216 + 44.0
        pickerContainer = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: pickerViewHeight))
        pickerContainer?.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleTopMargin];
        pickerContainer?.backgroundColor = UIColor.white
        
        let pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: (pickerContainer?.frame.size.width)!, height: 44))
        pickerToolbar.tintColor = UIColor.black;
        pickerToolbar.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleTopMargin];
        standardPicker?.addSubview(pickerToolbar)
        
        let space = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.flexibleSpace, target:nil, action:nil);
        let pickerDoneButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.done, target:self, action:#selector(self.onPickerDone));
        pickerDoneButton.accessibilityHint = NSLocalizedString("done_button_hint", comment: "Done button hint")
        pickerToolbar.setItems([space, pickerDoneButton], animated: false)
        pickerContainer?.addSubview(pickerToolbar)
        
        standardPicker = UIPickerView(frame:CGRect(x: 0, y: pickerToolbar.frame.size.height, width: pickerContainer!.frame.size.width, height: 216));
        standardPicker?.delegate = self
        standardPicker?.dataSource = self
        standardPicker?.showsSelectionIndicator = true
        standardPicker?.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleTopMargin]
        standardPicker?.isHidden = true
        pickerContainer?.addSubview(standardPicker!)
        
        datePicker = UIDatePicker(frame:CGRect(x: 0, y: pickerToolbar.frame.size.height, width: pickerContainer!.frame.size.width, height: 216));
        datePicker?.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleTopMargin]
        datePicker?.isHidden = true
        datePicker?.datePickerMode = .date
        pickerContainer?.addSubview(datePicker!)
        
        self.view.addSubview(pickerContainer!)
    }
    
    @objc func onPickerDone() {
        // overridden
    }
    
    /// Find the index of a value from the data shown in the picker
    ///
    /// - Parameters:
    ///   - key: The data point to compare against
    ///   - data: The array of entries to look through
    /// - Returns: optional integer of index
    func indexOfPickerEntry(key: String, data: [PickerEntry]) -> Int? {
        let filtered = data.filter { $0.value == key }
        if filtered.count > 0 {
            if let filteredValue = filtered.first {
                return data.firstIndex(of: filteredValue)
            }
        }
        return nil
    }
    
    func pickerEntryByKey(_ key: String, data: [PickerEntry]) -> PickerEntry? {
        let filtered = data.filter { $0.value == key }
        if filtered.count > 0 {
            return filtered.first
        }
        return nil
    }
    
    @objc func onKeyboardShowNotification(_ notification:Notification) {
        // sanity checks
        assert((scroll != nil), "Scrollview not set")
        
        if let scrollView = scroll, let userInfo = notification.userInfo {
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            var contentInset: UIEdgeInsets = scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    @objc func onKeyboardHideNotification(_ notification: NSNotification) {
        if let scrollView = scroll {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
            keyboardHidden()
        }
    }
    
    func keyboardShown(_ keyboardFrame:CGRect) {
        // overridden
    }
    
    func keyboardHidden() {
        // overridden
    }
}
