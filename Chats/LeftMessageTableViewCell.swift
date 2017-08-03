//
//  LeftMessageTableViewCell.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/2/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit

class LeftMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var messageLabel: RoundedPaddingLabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        messageLabel.setRoundedCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 10)
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if avatarImageView.image != nil {
            avatarImageView.image = nil
        }
    }
}
