//
//  ViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-01-25.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var tableData:[BlogPost]?
    var response: BlogPostResponse?
    var listParameters: [String : Any]?
    @IBOutlet var table: UITableView?
    @IBOutlet var addBlogPostButton: UIButton!
    var refreshControl:UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("blog_posts", comment: "Blog post list details")
        
        // specify the parameters used in the default request, so that it can be overwritten by filters, for example
        listParameters = settingModel.defaultListParameters()
        listParameters!["orderby"] = "published_date"
        listParameters!["order"] = "desc"
        
        // table properties
        table?.register(UINib(nibName: "BlogPostTableViewCell", bundle: nil), forCellReuseIdentifier: "blogTableCell")
        table?.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        table?.rowHeight = 84
        self.setInfiniteScroll()
        
        // refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        table?.addSubview(refreshControl!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func refreshView() {
        // called when view appears
        refreshUserButton()
        refreshMessageButton()
        reloadData(0)
    }
    
    @IBAction func onAddBlogButtonPressed() {
        if let addBlogVC = storyboard?.instantiateViewController(withIdentifier: AddBlogPostViewController.Identifier) as? AddBlogPostViewController {
            navigationController?.pushViewController(addBlogVC, animated: true)
        }
    }
    
    func refreshMessageButton() {
        if settingModel.isLoggedIn() {
            let messageIcon = UIImage(named: "chat.png")
            let messageButton = UIBarButtonItem(image: messageIcon, style: .plain, target: self, action: #selector(onMessageButton))
            self.navigationItem.leftBarButtonItem = messageButton
            
            self.updateUnreadBadge()
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func updateUnreadBadge() {
        Alamofire.request(SettingModel.APIRouter.unreadThreads)
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<UnreadThreadsResponse>) in
                
                switch response.result {
                case .success:
                    if let unreadThreads = response.result.value!.unreadThreads, unreadThreads > 0 {
                        self.navigationItem.leftBarButtonItem?.addBadge(number: unreadThreads)
                    }
                    break
                case .failure(let error):
                    Constants.debugPrint(error.localizedDescription)
                    break
                }
        }
    }
    
    // depending on user account status, the top button should either be the login/register icon or account screen
    func refreshUserButton() {
        if settingModel.isLoggedIn() {
            let userAccountIcon = UIImage(named: "user_icon.png")
            let userAccountButton = UIBarButtonItem(image: userAccountIcon!, style: .plain, target: self, action: #selector(onUserAccountButton))
            self.navigationItem.rightBarButtonItem = userAccountButton
        } else {
            let userRegisterIcon = UIImage(named: "info_icon.png")
            let userRegisterButton = UIBarButtonItem(image: userRegisterIcon!, style: .plain, target: self, action: #selector(onUserRegisterButton))
            self.navigationItem.rightBarButtonItem = userRegisterButton
        }
    }
    
    @objc func onMessageButton() {
        let controller = MessageListViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func onUserAccountButton() {
        let controller = AccountEditViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func onUserRegisterButton() {
        let controller = LoginViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // when pulled to refresh, reload data by overriding the current content
    @objc func refresh() {
        reloadData(0)
    }

    // MARK: - Table view delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = 1
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.tableData?.count ?? 0
            
        if count == 0 {
            return 1
        } else {
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.tableData?.count ?? 0) == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableCell")
            cell.textLabel?.text = NSLocalizedString("no_data_found", comment: "")
            cell.selectionStyle = .none
            return cell
        } else {
            let cellObject = tableData![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "blogTableCell") as! BlogPostTableViewCell
            cell.setBlogPost(cellObject)

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (tableData?.count ?? 0) == 0 {
            return
        }
        
        if let blogPost = tableData?[indexPath.row] {
            let controller = BlogPostViewController(blogPost: blogPost)
            self.navigationController?.pushViewController(controller, animated: true)
        }
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
    
    /**
     Refresh the table by providing an offset
     */
    func reloadData(_ offset:Int = 0) {
        if offset == 0 {
            showProgress()
        }
        
        // update the list parameters with the new offset
        listParameters!["offset"] = offset
        Alamofire.request(SettingModel.APIRouter.blogPosts(parameters: listParameters!))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<BlogPostResponse>) in
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
}

