//
//  MessagePhotoViewController.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-04-13.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit

class MessagePhotoViewController: BaseViewController {
    var image: Image?
    @IBOutlet var scroll: UIScrollView?
    @IBOutlet var imageView: UIImageView?
    
    convenience init(image i: Image) {
        self.init()
        self.image = i
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let urlString = image?.findOriginalUrl() {
            imageView?.kf.setImage(with: URL(string: urlString), completionHandler: {
                (image, error, cacheType, imageUrl) in
                
                if let downloadedImage = image {
                    //self.scroll?.contentSize = downloadedImage.size
                    
                    // change the zoom
                    self.scroll?.zoomScale = self.getImageZoomScale(downloadedImage)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getImageZoomScale(_ scaledImage: UIImage) -> CGFloat {
        let widthScale = scroll!.frame.size.width / scaledImage.size.width
        let heightScale = scroll!.frame.size.height / scaledImage.size.height
        
        let zoom = min(1, min(widthScale, heightScale))
        return zoom
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
