//
//  MessageTableViewCell.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-03-28.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit
import QuartzCore

class MessageTableViewCell: UITableViewCell {
    var message: CmsMessage?
    @IBOutlet var fromMessageLabel: UITextView?
    @IBOutlet var fromMessageDateLabel: UILabel?
    @IBOutlet var toMessageLabel: UITextView?
    @IBOutlet var toMessageDateLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fromMessageLabel?.layer.cornerRadius = 5.0
        toMessageLabel?.layer.cornerRadius = 5.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadMessage(_ m: CmsMessage, currentUser: User) {
        message = m
        
        if message?.userId != currentUser.userId {
            setFromMessage(message?.content, date: m.createdDate!)
        } else {
            setToMessage(message?.content, date: m.createdDate!)
        }
    }
    
    func setFromMessage(_ text: String?, date: Date) {
        fromMessageLabel?.text = text
        fromMessageLabel?.isHidden = false
        fromMessageDateLabel?.text = message?.dateTimeLabel(date)
        fromMessageDateLabel?.isHidden = false
        
        toMessageLabel?.text = nil
        toMessageLabel?.isHidden = true
        toMessageDateLabel?.isHidden = true
    }
    
    func setToMessage(_ text: String?, date: Date) {
        toMessageLabel?.text = text
        toMessageLabel?.isHidden = false
        toMessageDateLabel?.text = message?.dateTimeLabel(date)
        toMessageDateLabel?.isHidden = false
        
        fromMessageLabel?.text = nil
        fromMessageLabel?.isHidden = true
        fromMessageDateLabel?.isHidden = true
    }
    
}
