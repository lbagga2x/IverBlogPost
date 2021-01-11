//
//  MessageListViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-03-28.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class MessageListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var table: UITableView?
    var search: UISearchBar?
    var newButton: UIBarButtonItem?
    var tableData: [MessageThread]?
    var listParameters: [String : Any]?
    var refreshControl: UIRefreshControl?
    var response: ThreadListResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("messages", comment: "")
        
        addBackButton()
        
        // additional table properties
        table?.register(UINib(nibName: "MessageReceiverTableViewCell", bundle: nil), forCellReuseIdentifier: "messageReceiverTableViewCell")
        table?.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        table?.rowHeight = 64
        self.setInfiniteScroll()
        
        // refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        table?.addSubview(refreshControl!)
        
        // search bar
        search = UISearchBar()
        
        // parameters
        listParameters = settingModel.defaultListParameters()
        listParameters!["order"] = "desc"
        listParameters!["orderby"] = "updated_at"
        
        // add buttons
        newButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(onNewButton))
        self.navigationItem.rightBarButtonItem = newButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        table?.tableHeaderView = search!
    }
    
    /**
     This must be added to each view with infinite scroll to properly trigger the reload
     */
    func setInfiniteScroll() {
        table?.addInfiniteScroll(handler: { (tableView) in
            self.reloadData(self.response!.offset! + self.response!.limit!)
        })
        table?.setShouldShowInfiniteScrollHandler { _ -> Bool in
            return (self.response?.remaining ?? 0) > 0
        }
    }
    
    override func refreshView() {
        super.refreshView()
        
        reloadData()
    }
    
    @objc func refresh() {
        reloadData()
    }
    
    @objc func onNewButton() {
        let controller = MessageDetailViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func reloadData(_ offset: Int = 0) {
        if offset == 0 {
            showProgress()
        }
        
        // update the list parameters with the new offset
        listParameters!["offset"] = offset
        Alamofire.request(SettingModel.APIRouter.getInboxThreads(parameters: listParameters!))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<ThreadListResponse>) in
                self.hideProgress()
                self.refreshControl?.endRefreshing()
                self.table?.finishInfiniteScroll()
                
                switch response.result {
                case .success:
                    self.response = response.result.value
                    if offset == 0 {
                        self.tableData = self.response!.data!
                    } else {
                        self.tableData! += self.response!.data!
                    }
                    self.table?.reloadData()
                    break
                case .failure(let error):
                    self.showResponseError(response.data, error: error)
                    break
                }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = tableData?.count ?? 0
        return max(count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.tableData?.count ?? 0) == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableCell")
            cell.textLabel?.text = NSLocalizedString("no_data_found", comment: "")
            cell.selectionStyle = .none
            return cell
        } else {
            let cellObject = tableData![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageReceiverTableViewCell") as! MessageReceiverTableViewCell
            cell.loadThread(cellObject)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (self.tableData?.count ?? 0) > 0 {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // send a row to the trash
            sendMessageToTrash(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let count = tableData?.count ?? 0
        if count > 0 {
            let selectedObject = tableData![indexPath.row]
            let controller = MessageDetailViewController(thread: selectedObject)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func sendMessageToTrash(_ indexPath: IndexPath) {
        let cellObject = tableData![indexPath.row]
        Alamofire.request(SettingModel.APIRouter.deleteThread(threadId: cellObject.threadId!))
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                self.hideProgress()
                switch response.result {
                case .success:
                    self.tableData!.remove(at: indexPath.row)
                    self.table?.deleteRows(at: [indexPath], with: .automatic)
                    break
                case .failure(let error):
                    self.showErrorMessage(error.localizedDescription)
                    break
                }
        }
    }
}
