//
//  MessagesViewController.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/2/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit
import RealmSwift

class MessagesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var serverAPI: ServerAPI = ServerAPI()
    
    var channelID: Int = 0
    
    let realm = try! Realm()
    lazy var channel: Channel? = { self.realm.objects(Channel.self).filter("id == \(self.channelID)").first }()
    lazy var messages: Results<Message> = { self.realm.objects(Message.self).filter("channel_id == \(self.channelID)") }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "RightMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "rightMessageCell")
        
        self.tableView.register(UINib(nibName: "LeftMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "leftMessageCell")
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0 // set to whatever your "average" cell height is
        
        if let channel = channel {
            serverAPI.updateMessages(inChannel: channel) { [weak self] (result) in
                self?.tableView.reloadData()
            }
        }
    }
    
}

extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message: Message = self.messages[indexPath.row]
        
        if let messageSender = message.sender?.id, let channelUser = channel?.users.last?.id, messageSender == channelUser {
            let cell: RightMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "rightMessageCell", for: indexPath) as! RightMessageTableViewCell
            
            cell.transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi))
            
            cell.messageLabel.text = message.text
            cell.timeLabel.text = "09:32"
            
            return cell
        } else {
            let cell: LeftMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "leftMessageCell", for: indexPath) as! LeftMessageTableViewCell
            
            cell.transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi))
            
            cell.messageLabel.text = message.text
            cell.timeLabel.text = "09:32"
            
            if let imagePath = message.sender?.photo, let imageURL = URL(string: imagePath) {
                cell.avatarImageView.af_setImage(withURL: imageURL) { response in
                    if response.response != nil {
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
}

extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        label.textColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0)
        label.textAlignment = .center
        label.text = "Yesterday"
        
        label.transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi))
        
        return label
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}
