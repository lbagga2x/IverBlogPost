//
//  MessageImageTableViewCell.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-03-30.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit

protocol ImageViewDelegate {
    func didTapImage(_ image: Image)
}

class MessageImageTableViewCell: UITableViewCell {
    var message: CmsMessage?
    @IBOutlet var fromImageView: UIImageView?
    @IBOutlet var fromMessageDateLabel: UILabel?
    @IBOutlet var toImageView: UIImageView?
    @IBOutlet var toMessageDateLabel: UILabel?
    var imageDelegate: ImageViewDelegate?
    var fromImageRatioConstaint: NSLayoutConstraint? {
        willSet {
            
            if((fromImageRatioConstaint) != nil) {
                self.fromImageView?.removeConstraint(self.fromImageRatioConstaint!)
            }
            
            if (toImageRatioConstraint != nil) {
                self.toImageView?.removeConstraint(self.toImageRatioConstraint!)
            }
        }
        
        didSet {
            
            if(fromImageRatioConstaint != nil) {
                self.fromImageView?.addConstraint(self.fromImageRatioConstaint!)
            }
            
        }
    }
    var toImageRatioConstraint: NSLayoutConstraint? {
        willSet {
            
            if((toImageRatioConstraint) != nil) {
                self.toImageView?.removeConstraint(self.toImageRatioConstraint!)
            }
            
            if((fromImageRatioConstaint) != nil) {
                self.fromImageView?.removeConstraint(self.fromImageRatioConstaint!)
            }
        }
        
        didSet {
            
            if(toImageRatioConstraint != nil) {
                self.toImageView?.addConstraint(self.toImageRatioConstraint!)
            }
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fromImageView?.layer.cornerRadius = 5.0
        toImageView?.layer.cornerRadius = 5.0
        
        let fromTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapPhoto))
        fromImageView?.addGestureRecognizer(fromTapGesture)
        let toTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapPhoto))
        toImageView?.addGestureRecognizer(toTapGesture)
    }
    
    @objc func onTapPhoto() {
        // open the photo in a viewer
        if let image = message?.image {
            imageDelegate?.didTapImage(image)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadMessage(_ m: CmsMessage, currentUser: User) {
        message = m
        
        if message?.userId != currentUser.userId {
            setFromMessage(message?.image?.findLargeUrl(), date: m.createdDate!)
        } else {
            setToMessage(message?.image?.findLargeUrl(), date: m.createdDate!)
        }
    }
    
    func setFromMessage(_ imageData: Any?, date: Date) {
        // set the imageview depending on what parameter was sent
        if let imageUrlString = imageData as? String {
            fromImageView?.kf.setImage(with: URL(string: imageUrlString), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let constraint = self.imageViewRatioConstraint(self.fromImageView!) {
                    self.fromImageRatioConstaint = constraint
                }
                self.setNeedsUpdateConstraints()
            })
        } else if let imageUrl = imageData as? URL {
            fromImageView?.kf.setImage(with: imageUrl, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let constraint = self.imageViewRatioConstraint(self.fromImageView!) {
                    self.fromImageRatioConstaint = constraint
                }
                self.setNeedsUpdateConstraints()
            })
        } else if let image = imageData as? UIImage {
            fromImageView?.image = image
            
            if let constraint = imageViewRatioConstraint(fromImageView!) {
                self.fromImageRatioConstaint = constraint
                self.setNeedsUpdateConstraints()
            }
        }
        fromImageView?.isHidden = false
        fromMessageDateLabel?.text = message?.dateTimeLabel(date)
        fromMessageDateLabel?.isHidden = false
        
        toImageView?.image = nil
        toImageView?.isHidden = true
        toMessageDateLabel?.isHidden = true
    }
    
    func setToMessage(_ imageData: Any?, date: Date) {
        if let imageUrlString = imageData as? String {
            toImageView?.kf.setImage(with: URL(string: imageUrlString), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let constraint = self.imageViewRatioConstraint(self.toImageView!) {
                    self.toImageRatioConstraint = constraint
                }
                self.setNeedsUpdateConstraints()
            })
        } else if let imageUrl = imageData as? URL {
            toImageView?.kf.setImage(with: imageUrl, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let constraint = self.imageViewRatioConstraint(self.toImageView!) {
                    self.toImageRatioConstraint = constraint
                }
                self.setNeedsUpdateConstraints()
            })
        } else if let image = imageData as? UIImage {
            toImageView?.image = image
            
            if let constraint = imageViewRatioConstraint(toImageView!) {
                self.toImageRatioConstraint = constraint
                self.setNeedsUpdateConstraints()
            }
        }
        toImageView?.isHidden = false
        toMessageDateLabel?.text = message?.dateTimeLabel(date)
        toMessageDateLabel?.isHidden = false
        
        fromImageView?.image = nil
        fromImageView?.isHidden = true
        fromMessageDateLabel?.isHidden = true
    }
    
    // inspired by http://stackoverflow.com/a/34025197/776617
    func imageViewRatioConstraint(_ imageView: UIImageView) -> NSLayoutConstraint? {
        if let imageSize = imageView.image?.size, imageSize.height != 0
        {
            let aspectRatio = imageSize.width / imageSize.height
            let c = NSLayoutConstraint(item: imageView, attribute: .width,
                                   relatedBy: .equal,
                                   toItem: imageView, attribute: .height,
                                   multiplier: aspectRatio, constant: 0)
            return c
        } else {
            return nil
        }
    }
}
