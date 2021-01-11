//
//  MessageReceiverTableViewCell.swift
//  Base iOS Project
//
//  Created by Wes Goodhoofd on 2017-03-28.
//  Copyright © 2017 Iversoft Solutions Inc. All rights reserved.
//

import UIKit

class MessageReceiverTableViewCell: UITableViewCell {
    var messageThread: MessageThread?
    @IBOutlet var receiverLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadThread(_ m: MessageThread) {
        self.messageThread = m
        
        if let otherUser = self.messageThread?.otherUser() {
            receiverLabel?.text = otherUser.name
            dateLabel?.text = otherUser.dateTimeLabel(messageThread!.updatedDate!)
            markUnread(messageThread!.unread)
        }
    }
    
    func markUnread(_ unread: Bool) {
        if unread {
            self.backgroundColor = Constants.accentColour
            receiverLabel?.textColor = UIColor.white
            dateLabel?.textColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
            receiverLabel?.textColor = Constants.accentColour
            dateLabel?.textColor = UIColor.black
        }
    }
}
