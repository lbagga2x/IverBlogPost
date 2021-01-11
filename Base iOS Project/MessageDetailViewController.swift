//
//  MessageDetailViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-03-28.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import Photos
import SwiftSpinner

class MessageDetailViewController: TextInputViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageViewDelegate {
    @IBOutlet var table: UITableView?
    var thread: MessageThread?
    var tableData: [CmsMessage]?
    var listParameters: [String : Any]?
    var response: MessageThreadResponse?
    @IBOutlet var toFieldContainer: UIView?
    @IBOutlet var toField: UITextField?
    @IBOutlet var toFieldContainerConstaint: NSLayoutConstraint?
    var recipientTable: UITableView?
    var userSearchTableData: [User]?
    var toUser: User?
    
    // infinite scrolling upward
    var topScrollActivityContainer: UIView?
    var topScrollActivityIndicator: UIActivityIndicatorView?
    var topScrollIsLoading = false
    var canLoadInfiniteScrollTop = true
    
    // create keyboard input view
    @IBOutlet var messageTextContainer: UIView?
    @IBOutlet var messageTextView: UITextView?
    @IBOutlet var sendButton: UIButton?
    @IBOutlet var photoButton: UIButton?
    @IBOutlet var keyboardHeightConstraint: NSLayoutConstraint?
    @IBOutlet var messageTextContainerHeightConstraint: NSLayoutConstraint?
    
    convenience init(thread t: MessageThread) {
        self.init()
        self.thread = t
        self.toUser = t.otherUser()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.thread != nil {
            self.title = toUser?.name
        } else {
            self.title = NSLocalizedString("new_message", comment: "")
        }
        
        addBackButton()
        
        // force the scrollview to use the table instead
        scroll = table
        
        // additional table properties
        table?.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "messageTableViewCell")
        table?.register(UINib(nibName: "MessageImageTableViewCell", bundle: nil), forCellReuseIdentifier: "messageImageTableViewCell")
        table?.rowHeight = UITableView.automaticDimension
        table?.estimatedRowHeight = 64
        
        // message sending
        textViewDidChange(messageTextView!)
        
        // parameters
        listParameters = settingModel.defaultListParameters()
        listParameters!["orderby"] = "created_at"
        listParameters!["order"] = "desc"
        
        // present the TO field if the user has not been selected
        if thread == nil {
            toggleToFieldContainer(true)
            table?.isHidden = true
            toField?.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            toggleTextContainer(false)
            createUserSearchTable()
        } else {
            toggleToFieldContainer(false)
            table?.isHidden = false
            toggleTextContainer(true)
            
            // mark the thread as read
            markThreadRead()
        }
        
        sendButton?.layer.cornerRadius = 5.0
        photoButton?.layer.cornerRadius = 5.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func keyboardShown(_ keyboardFrame: CGRect) {
        keyboardHeightConstraint?.constant = keyboardFrame.size.height
    }
    
    override func keyboardHidden() {
        keyboardHeightConstraint?.constant = 0
    }
    
    func toggleTextContainer(_ show: Bool) {
        messageTextContainer?.isHidden = !show
        messageTextContainerHeightConstraint?.constant = (show) ? 36 : 0
    }
    
    func toggleToFieldContainer(_ show: Bool) {
        toFieldContainer?.isHidden = !show
        toFieldContainerConstaint?.constant = (show) ? 42 : 0
    }
    
    @IBAction func onPhotoButton() {
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
        picker.dismiss(animated: true, completion: nil)
        
        // upload the image
        sendData(nil, image: image)
    }

    
    @IBAction func onSendButton() {
        if let content = messageTextView?.text {
            if thread != nil {
                let parameters = ["reply_content" : content]
                sendData(parameters, image: nil)
            } else {
                createThread(self.toUser!, message: content)
            }
        }
    }
    
    func markThreadRead() {
        Alamofire.request(SettingModel.APIRouter.markThreadRead(threadId: self.thread!.threadId!))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<MessageThread>) in
                switch response.result {
                case .success:
                    // nothing required
                    break
                case .failure(let error):
                    self.showResponseError(response.data, error: error)
                    break
                }
        }
    }
    
    func sendData(_ p: [String : Any]?, image: UIImage?) {
        if let threadId = self.thread?.threadId {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                // properties
                if let parameters = p {
                    self.multipartFormData(multipartFormData, encodeParameters: parameters)
                }
                
                // photo
                if let photo = image {
                    self.multipartFormData(multipartFormData, encodeImage: photo, imageName: "photo")
                }
            }, with: SettingModel.APIRouter.sendMessage(threadId: threadId), encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (progress) in
                        if image != nil {
                            SwiftSpinner.show(progress: progress.fractionCompleted, title: NSLocalizedString("uploading_spinner", comment: ""))
                        }
                    })
                    upload.validate(statusCode: 200..<300)
                    upload.responseObject { (response: DataResponse<CmsMessage>) in
                        SwiftSpinner.hide()
                        
                        switch (response.result) {
                        case .success:
                            let message = response.result.value!
                            self.addMessage(message)
                            break
                        case .failure(let error):
                            self.showResponseError(response.data, error: error)
                        }
                    }
                    break
                    
                case .failure(let encodingError):
                    print(encodingError)
                    self.showErrorMessage(encodingError.localizedDescription)
                    break
                }
            })
        }
    }
    
    func createThread(_ user: User, message: String) {
        Alamofire.request(SettingModel.APIRouter.createThread(parameters: ["to_user" : user.userId!, "content" : message]))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<MessageThread>) in
                switch response.result {
                case .success:
                    // nothing required
                    self.thread = response.result.value
                    self.tableData = self.thread?.messages
                    self.messageTextView?.text = nil
                    self.table?.reloadData()
                    break
                case .failure(let error):
                    self.showResponseError(response.data, error: error)
                    break
                }
        }
    }
    
    func onCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func refreshView() {
        super.refreshView()
        
        if thread != nil {
            reloadData()
        }
    }
    
    func addMessage(_ message: CmsMessage) {
        if tableData == nil {
            self.tableData = [CmsMessage]()
        }
        self.tableData?.append(message)
        
        messageTextView?.text = nil
        
        // insert a cell
        let indexPath = IndexPath(row: self.tableData!.count - 1, section: 0)
        self.table?.insertRows(at: [indexPath], with: .automatic)
        
        // scroll to bottom
        self.scrollToRow(self.tableData!.count-1)
    }
    
    func scrollToRow(_ row: Int) {
        self.table?.scrollToRow(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
    }
    
    func reloadData(_ offset: Int = 0) {
        if offset == 0 {
            showProgress()
        }
        
        // update the list parameters with the new offset
        listParameters!["offset"] = offset
        Alamofire.request(SettingModel.APIRouter.threadMessages(threadId: self.thread!.threadId!, parameters: listParameters!))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<MessageThreadResponse>) in
                self.hideProgress()
                self.stopTopInfiniteScrollUpdate()
                
                switch response.result {
                case .success:
                    self.response = response.result.value
                    if offset == 0 {
                        self.tableData = self.response!.data!.reversed()
                        self.table?.reloadData()
                        self.scrollToRow(self.tableData!.count-1)
                    } else {
                        self.tableData!.insert(contentsOf: self.response!.data!.reversed(), at: 0)
                        self.table?.reloadData()
                        self.scrollToRow(self.response?.data?.count ?? 0)
                    }
                    break
                case .failure(let error):
                    self.showResponseError(response.data, error: error)
                    break
                }
        }
    }
    
    func setSearchResult(_ data: User, toCell: UITableViewCell) {
        // match the attributed string
        let attributedText = data.searchName().highlightText(toField?.text, fontSize: toCell.textLabel!.font.pointSize)
        toCell.textLabel?.attributedText = attributedText
    }
    
    func textViewDidChange(_ textView: UITextView) {
        sendButton?.isEnabled = !textView.text.isEmpty
    }
    
    // MARK: Table methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recipientTable {
            let count = userSearchTableData?.count ?? 0
            return count
        } else {
            let count = tableData?.count ?? 0
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recipientTable {
            let cellObject = userSearchTableData![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
            self.setSearchResult(cellObject, toCell: cell!)
            return cell!
        } else {
            let cellObject = tableData![indexPath.row]
            
            if cellObject.image != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageImageTableViewCell") as! MessageImageTableViewCell
                cell.loadMessage(cellObject, currentUser: settingModel.user!)
                cell.imageDelegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableViewCell") as! MessageTableViewCell
                cell.loadMessage(cellObject, currentUser: settingModel.user!)
                return cell
            }
        }
    }
    
    func didTapImage(_ image: Image) {
        let controller = MessagePhotoViewController(image: image)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == recipientTable {
            // change the page title
            if let selectedObject = userSearchTableData?[indexPath.row] {
                toggleToFieldContainer(false)
                hideUserSearchTable()
                toggleTextContainer(true)
                table?.isHidden = false
                userSearchTableData?.removeAll()
                self.messageTextView?.becomeFirstResponder()
                self.toUser = selectedObject
                self.title = self.toUser!.name
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == table {
            if (tableData?.count ?? 0) > 0 && indexPath.row == 0 && self.response?.canLoadMore() == true && topScrollIsLoading == false && canLoadInfiniteScrollTop == true {
                startTopInfiniteScrollUpdate()
            } else if canLoadInfiniteScrollTop == false && indexPath.row > 0 {
                canLoadInfiniteScrollTop = true
            }
        }
    }

    @objc func textFieldChanged(_ field: UITextField) {
        if (field.text?.count ?? 0) > 2 {
            searchForUser(field.text)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == toField {
            scroll = table
            hideUserSearchTable()
        }
    }
    
    func createUserSearchTable() {
        if recipientTable == nil {
            recipientTable = UITableView(frame: CGRect(x: 0, y: toFieldContainer!.frame.maxY, width: table!.frame.size.width, height: self.view.frame.size.height - toFieldContainer!.frame.maxY), style: .plain)
            recipientTable?.delegate = self
            recipientTable?.dataSource = self
            recipientTable?.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
            self.view.addSubview(recipientTable!)
        }
        recipientTable?.isHidden = true
        scroll = recipientTable
    }
    
    func hideUserSearchTable() {
        recipientTable?.removeFromSuperview()
        recipientTable = nil
        
        scroll = table
    }
    
    func searchForUser(_ term: String?) {
        if term == nil {
            return
        }
        
        let parameters = ["search" : term!, "exclude" : String(self.settingModel.user!.userId!)]
        Alamofire.request(SettingModel.APIRouter.userList(parameters: parameters))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<UserListResponse>) in
                
                switch response.result {
                case .success:
                    let userListResponse = response.result.value
                    self.userSearchTableData = userListResponse?.data
                    self.recipientTable?.isHidden = false
                    self.recipientTable?.reloadData()
                    break
                case .failure(let error):
                    self.showResponseError(response.data, error: error)
                    break
                }
        }
    }
    
    // MARK: Top infinite scroll methods
    func startTopInfiniteScrollUpdate() {
        topScrollIsLoading = true
        canLoadInfiniteScrollTop = false
        
        // create the animation container
        topScrollActivityContainer = UIView(frame: CGRect(x: 0, y: 0, width: table!.frame.size.width, height: 30))
        topScrollActivityContainer?.backgroundColor = UIColor.white
        
        topScrollActivityIndicator = UIActivityIndicatorView(style: .gray)
        topScrollActivityIndicator?.center = CGPoint(x: topScrollActivityContainer!.frame.size.width/2, y: topScrollActivityContainer!.frame.size.height/2)
        topScrollActivityContainer?.addSubview(topScrollActivityIndicator!)
        
        self.table?.tableHeaderView = topScrollActivityContainer
        
        if (self.response?.remaining ?? 0) > 0 && self.response?.data?.count != 0 {
            self.reloadData(self.response!.offset! + self.response!.limit!)
        }
    }
    
    func stopTopInfiniteScrollUpdate() {
        topScrollIsLoading = false
        table?.tableHeaderView = nil
    }
}
