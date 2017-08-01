//
//  ChannelTableViewCell.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit
import AlamofireImage

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
            avatarImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
