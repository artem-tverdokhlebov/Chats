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
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    lazy var serverAPI: ServerAPI = ServerAPI()
    
    var channelID: Int = 0
    
    let realm = try! Realm()
    lazy var channel: Channel? = { self.realm.objects(Channel.self).filter("id == \(self.channelID)").first }()
    lazy var messages: Results<Message> = {
        self.realm.objects(Message.self).filter("channel_id == \(self.channelID)").sorted(byKeyPath: "create_date", ascending: true)
    }()
    
    var messagesGroupedByDays = [[Message]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = channel?.users.first?.fullName()
        
        let blockBarButtonItem = UIBarButtonItem(title: "Block", style: .plain, target: nil, action: nil)
        blockBarButtonItem.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItem = blockBarButtonItem
        
        
        self.tableView.register(UINib(nibName: "RightMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "rightMessageCell")
        
        self.tableView.register(UINib(nibName: "LeftMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "leftMessageCell")
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0 // set to whatever your "average" cell height is
        
        self.messagesGroupedByDays = self.groupMessagesByDays(messages: self.messages.map { $0 }).reversed()
        
        if let channel = channel {
            serverAPI.updateMessages(inChannel: channel) { [weak self] (result) in
                self?.messagesGroupedByDays = self!.groupMessagesByDays(messages: (self?.messages.map { $0 })!).reversed()
                
                self?.tableView.reloadData()
            }
        }
     
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.bottomLayoutConstraint.constant = keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.bottomLayoutConstraint.constant = 0
        }
    }
    
    func groupMessagesByDays(messages: [Message]) -> [[Message]]{
        var lastDate = messages.first?.create_date
        let calendar = NSCalendar.current
        var lastGroup = [Message]()
        var groups = [[Message]]()
        
        for element in messages {
            let currentDate = element.create_date
            let unitFlags : Set<Calendar.Component> = [.day, .month, .year]
            let difference = calendar.dateComponents(unitFlags, from: lastDate!, to: currentDate!)
            if difference.year! > 0 || difference.month! > 0 || difference.day! > 0 {
                lastDate = currentDate
                groups.append(lastGroup)
                lastGroup = [element]
            } else {
                lastGroup.append(element)
            }
        }
        
        groups.append(lastGroup)
        
        return groups
    }
}

extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message: Message = self.messagesGroupedByDays[indexPath.section][indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let messageSender = message.sender?.id, let channelUser = channel?.users.last?.id, messageSender == channelUser {
            let cell: RightMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "rightMessageCell", for: indexPath) as! RightMessageTableViewCell
            
            cell.transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi))
            
            cell.messageLabel.text = message.text
            
            if let date = message.create_date {
                cell.timeLabel.text = dateFormatter.string(from: date)
            }
            
            return cell
        } else {
            let cell: LeftMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "leftMessageCell", for: indexPath) as! LeftMessageTableViewCell
            
            cell.transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi))
            
            cell.messageLabel.text = message.text
            
            if let date = message.create_date {
                cell.timeLabel.text = dateFormatter.string(from: date)
            }
            
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
        return self.messagesGroupedByDays[section].count
    }
}

extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.messagesGroupedByDays.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        label.textColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0)
        label.textAlignment = .center
        
        if let date = self.messagesGroupedByDays[section].first?.create_date {
            let dateFormatter = DateFormatter()
            
            if Calendar.current.isDateInToday(date) {
                dateFormatter.dateFormat = "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                dateFormatter.dateFormat = "Yesterday"
            } else {
                dateFormatter.dateFormat = "d MMM"
            }
            
            label.text = dateFormatter.string(from: date)
        }
        
        label.transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi))
        
        return label
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}
