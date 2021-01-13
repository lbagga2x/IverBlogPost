//
//  BaseViewController.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-25.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import AlamofireObjectMapper
import RxSwift

class BaseViewController: UIViewController {
    let dataModel:DataModel = DataModel.sharedModel()
    let settingModel:SettingModel = SettingModel.sharedModel()
    var showedSpinner = false
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshView()
    }

    func refreshView() {
        // overridden; called when view appears
    }
    
    func setupLoadingObserver(viewModel: BaseViewModel) {
        viewModel.isLoading.subscribe(onNext: { [weak self] (value) in

            value ? self?.showProgress() : self?.hideProgress()
            
        }).disposed(by: bag)
    }
    
    func setupErrorObserver(viewModel: BaseViewModel?) {
        viewModel?.isError.subscribe(onNext: { [weak self] (data, value) in
            self?.showResponseError(data, error: value)
        }).disposed(by: bag)
    }

    /// Add a back button icon instead of the text
    func addBackButton() {
        let icon = UIImage(named: "BackButtonIcon.png")
        let button = UIButton(type: .custom)
        button.setImage(icon, for: .normal)
        button.addTarget(self, action: #selector(self.onBackButton), for: .touchUpInside)
        button.frame = CGRect(origin: CGPoint.zero, size: icon!.size)
        let item = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = item
    }
    
    @objc func onBackButton() {
        if shouldGoBack() == true {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func shouldGoBack() -> Bool {
        // overridden
        return true
    }
    
    /// Present an alert with the title set to 'Error'
    ///
    /// - Parameter message: The main error message to display; title is nil in order to use the default error alert
    func showErrorMessage(_ message:String) {
        showAlertMessage(NSLocalizedString("error", comment: "Default error message title"), message: message)
    }
    
    /// Show an error alert with customized title and description
    ///
    /// - Parameters:
    ///   - title: The text to display as the alert title
    ///   - message: The text to display as the alert body
    func showAlertMessage(_ title:String, message:String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("ok", comment:"Dismiss error button label"), style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    /// Present a spinner object to cover the screen during network requests
    ///
    /// - Parameters:
    ///   - title: The text to display as part of the spinner
    ///   - firstTimeOnly: Choose whether subsequent calls to show the spinner will actually display it
    func showProgress(title:String? = nil, firstTimeOnly:Bool = true) {
        if firstTimeOnly == true && showedSpinner == true {
            return
        }
        
        if firstTimeOnly == true {
            showedSpinner = true
        }
        
        var progressTitle = title
        if title == nil {
            progressTitle = NSLocalizedString("loading", comment: "Loading screen default")
        }
        
        SwiftSpinner.show(progressTitle!)
    }
    
    /// Update the text on the spinner without hiding it first
    ///
    /// - Parameter title: The text to show as the status message
    func updateProgress(title:String) {
        SwiftSpinner.shared.title = title
    }
    
    /// Hide the spinner that is covering the screen
    ///
    /// - Parameter checkAll: Force hiding the spinner on the current controller rather than looking through the nav or tab bar controllers
    func hideProgress() {
        SwiftSpinner.hide()
    }
    
    func addDismissKeyboardToView(_ view: UIView) {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clearKeyboards))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    /// Override this method to clear the keyboard when clicking a view
    @objc func clearKeyboards() {
        // from http://stackoverflow.com/a/42352642/776617
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Display either the web request failure message or the response text from the returned data
    ///
    /// - Parameters:
    ///   - response: Alamofire response
    ///   - error: Alamofire error object
    func showResponseError(_ data: Data?, error: Error) {
        if let errorMessage = Constants.findErrorInResponse(data) {
            self.showErrorMessage(errorMessage)
            return
        }
        // only show the Alamofire message if message text was not found
        self.showErrorMessage(error.localizedDescription)
    }
    
    /// Add parameters to the form
    ///
    /// - Parameters:
    ///   - formData: Alamofire MultipartFormData object
    ///   - encodeParameters: The dictionary of parameters to encode
    func multipartFormData(_ formData: MultipartFormData, encodeParameters parameters: [String : Any]) {
        for (key, value) in parameters {
            var data:Data?
            
            if let stringValue = value as? String {
                data = stringValue.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            } else {
                let valueString = String(describing: value)
                data = valueString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            }
            
            if data != nil {
                formData.append(data!, withName: key)
            }
        }
    }
    
    /// Add an image object to the form
    ///
    /// - Parameters:
    ///   - formData: Alamofire MultipartFormData object
    ///   - encodeImage: The image object to encode
    func multipartFormData(_ formData: MultipartFormData, encodeImage image: UIImage, imageName: String) {
        let resizedImage = image.resizeToWidth(1024.0)
        let imageData = resizedImage.jpegData(compressionQuality: 1)
        formData.append(imageData!, withName: imageName, fileName: "photo", mimeType: "image/jpg")
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
}

/* 
 * from http://stackoverflow.com/a/27683614/776617
 * increases the hit area of a button to apple's guidelines
 */
private let minimumHitArea = CGSize(width: 44, height: 44)

extension UIButton {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        
        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
}

/* image resizing courtesy http://stackoverflow.com/a/29138120/776617 */
extension UIImage {
    func resize(_ scale:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    func resizeToWidth(_ width:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

/* bar button item badge from https://gist.github.com/freedom27/c709923b163e26405f62b799437243f4#gistcomment-1934825 */
extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        var badgeWidth = 8
        var numberOffset = 4
        
        if number > 9 {
            badgeWidth = 12
            numberOffset = 6
        }
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - CGFloat(numberOffset), y: offset.y), size: CGSize(width: badgeWidth, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}

extension String {
    // take the original string and highlight the string inside it if found
    func highlightText(_ string: String?, fontSize: CGFloat) -> NSAttributedString {
        let attrs:[NSAttributedString.Key : AnyObject] = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize)]
        if string == nil {
            return NSAttributedString(string: self)
        } else if self.lowercased().contains(string!.lowercased()) {
            let range = self.lowercased().range(of: string!.lowercased())
            let firstSection = self.substring(to: range!.lowerBound)
            let attributedString = NSMutableAttributedString(string: firstSection)
            
            let boldText = self.substring(with: range!)
            attributedString.append(NSAttributedString(string: boldText, attributes: attrs))
            
            let lastSection = self.substring(from: range!.upperBound)
            attributedString.append(NSAttributedString(string: lastSection))
            
            return attributedString
        } else {
            return NSAttributedString(string: self)
        }
    }
}

// from https://gist.github.com/yannickl/16f0ed38f0698d9a8ae7
extension UIColor {
    convenience init(hexString:String) {
        let hexString:String = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let scanner            = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: self, options: nil)![0] as! T
    }
}
