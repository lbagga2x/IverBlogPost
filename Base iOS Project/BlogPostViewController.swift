//
//  BlogPostViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-02-22.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class BlogPostViewController: BaseViewController, UIWebViewDelegate {
    var blogPost: BlogPost?
    var blogPostId: Int?
    @IBOutlet var webview: UIWebView?
    
    convenience init(blogPost b: BlogPost) {
        self.init()
        self.blogPost = b
    }
    
    convenience init(blogPostId b: Int) {
        self.init()
        self.blogPostId = b
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("blog_post_details", comment: "")
        addBackButton()
        
        // Do any additional setup after loading the view.
        if blogPost != nil {
            displayBlogPost()
        } else if blogPostId != nil {
            downloadBlogPost()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayBlogPost() {
        // construct an HTML page and insert the data from the blog post object
        if let filePath = Bundle.main.url(forResource: "blog_wrapper", withExtension: "html") {
            // show progress right away
            self.showProgress()
            
            var containerText:String
            do {
                containerText = try String(contentsOf: filePath, encoding: .utf8)
            } catch let error {
                self.hideProgress()
                Constants.debugPrint(error.localizedDescription)
                return
            }
            
            // build a dictionary of the values to replace
            var blogValues = [String : String]()
            
            blogValues["post_title"] = blogPost!.title!
            blogValues["post_content"] = blogPost!.content!
            blogValues["post_date"] = blogPost?.dateLabel(blogPost!.createdDate!, format: "MMM d, yyyy")
            
            if let authorName = blogPost?.author?.name {
                blogValues["post_author"] = authorName
            } else {
                blogValues["post_author"] = ""
            }
            
            if let headerUrl = blogPost?.image?.findLargeUrl() {
                Constants.debugPrint("found image \(headerUrl)")
                blogValues["header_image"] = String(format: "<img src=\"%@\" class=\"header\" >", headerUrl)
            } else {
                blogValues["header_image"] = ""
            }
            
            // colours
            blogValues["header_colour"] = Constants.accentColour.toHexString()
            
            // now replace the placeholders in the text with the values from the dictionary
            for (key,value) in blogValues {
                let placeholder = "+"+key+"+"
                containerText = containerText.replacingOccurrences(of: placeholder, with: value)
            }
            
            // load into the webview
            webview?.loadHTMLString(containerText, baseURL: nil)            
        }
    }
    
    func downloadBlogPost() {
        showProgress()
        Alamofire.request(SettingModel.APIRouter.getBlogPost(blogPostId: blogPostId!))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<BlogPost>) in
                switch response.result {
                case .success:
                    self.blogPost = response.result.value
                    self.displayBlogPost()
                    break
                case .failure(let error):
                    self.hideProgress()
                    self.showResponseError(response.data, error: error)
                    break
                }
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hideProgress()
        showErrorMessage(error.localizedDescription)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideProgress()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == .linkClicked {
            // open the link in Safari
            let controller = UIAlertController(title: NSLocalizedString("open_safari", comment: ""), message: request.url?.absoluteString, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment:"Dismiss error button label"), style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            let openAction = UIAlertAction(title: NSLocalizedString("open", comment:""), style: .default, handler: { (ACTION) -> Void in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(request.url!)
                }
            })
            controller.addAction(openAction)
            self.present(controller, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
