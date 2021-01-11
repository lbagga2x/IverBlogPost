//
//  BlogPostTableViewCell.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-01-25.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import Kingfisher

class BlogPostTableViewCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var iconViewWidth: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.iconView?.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setBlogPost(_ object: BlogPost) {
        self.titleLabel?.text = object.title
        self.dateLabel?.text = object.dateOrLabel(object.updatedDate)
        
        if let urlString = object.image?.findThumbnailUrl() {
            let url = URL(string: urlString)
            self.iconView?.kf.indicatorType = .activity
            self.iconView?.kf.setImage(with: url)
            self.iconView?.isHidden = false
            self.iconViewWidth?.constant = 56
        } else {
            self.iconView?.isHidden = true
            //self.iconViewWidth?.constant = 0
        }
    }
}
