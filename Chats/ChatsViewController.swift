//
//  ViewController.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import AlamofireImage
import SwipeCellKit

class ChatsViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var serverAPI: ServerAPI = ServerAPI()
    
    let realm = try! Realm()
    lazy var channels: Results<Channel> = { self.realm.objects(Channel.self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "channelCell")
        
        serverAPI.updateChannels { [weak self] (result) in
            self?.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChatsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChannelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as! ChannelTableViewCell
        
        cell.delegate = self
        
        let channel = self.channels[indexPath.row]
        
        if let userPhoto = channel.last_message?.sender?.photo, let userPhotoURL = URL(string: userPhoto) {
            cell.avatarImageView.af_setImage(withURL: userPhotoURL)
        }
        
        cell.userNameLabel.text = channel.last_message?.sender?.fullName()
        cell.messageTextLabel.text = channel.last_message?.text
        
        if let date = channel.last_message?.create_date {
            let dateFormatter = DateFormatter()
            
            if Calendar.current.isDateInToday(date) {
                dateFormatter.dateFormat = "H:mm"
            } else if Calendar.current.isDateInYesterday(date) {
                dateFormatter.dateFormat = "Yesterday, H:mm"
            } else {
                dateFormatter.dateFormat = "d MMM, H:mm"
            }
            
            cell.dateTimeLabel.text = dateFormatter.string(from: date)
        }
        
        if channel.unread_messages_count > 0 {
            cell.unreadMessagesCountLabel.isHidden = false
            cell.unreadMessagesCountLabel.text = String(channel.unread_messages_count)
        } else {
            cell.unreadMessagesCountLabel.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

extension ChatsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: "Remove") { action, indexPath in
            // handle action by updating model with deletion
        }
        
        deleteAction.backgroundColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        
        return [deleteAction]
    }
}
