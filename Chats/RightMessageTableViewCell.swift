//
//  RightMessageTableViewCell.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/2/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit

class RightMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: RoundedPaddingLabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        messageLabel.setRoundedCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }    
}
