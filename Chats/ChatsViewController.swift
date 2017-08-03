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

class ChatsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControlContainerView: UIView!
    
    lazy var serverAPI: ServerAPI = ServerAPI()
    
    var firstCell = SPSegmentedControlCell(layout: .textWithBadge) {
        didSet {
            firstCell.label.text = "Chat"
            firstCell.label.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
            firstCell.badgeLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightThin)
        }
    }
    
    var secondCell = SPSegmentedControlCell(layout: .textWithBadge) {
        didSet {
            secondCell.label.text = "Live Chat"
            secondCell.label.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
            secondCell.badgeLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightThin)
        }
    }
    
    let realm = try! Realm()
    lazy var channelsWithUnread: Results<Channel> = { self.realm.objects(Channel.self).filter("unread_messages_count > 0") }()
    lazy var channelsWithRead: Results<Channel> = { self.realm.objects(Channel.self).filter("unread_messages_count = 0") }()
    
    private func setupNavigationBar() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let statusBarView = UIView(frame: CGRect(x: 0.0, y: -statusBarHeight, width: UIScreen.main.bounds.size.width, height: statusBarHeight))
        
        statusBarView.backgroundColor = UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)
        statusBarView.alpha = 0.1
    
        self.navigationController?.navigationBar.addSubview(statusBarView)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setupSegmentedControl() {
        let control = SPSegmentedControl(frame: CGRect.zero)
        control.styleDelegate = self
        
        control.backgroundColor = UIColor(red: 7/255, green: 7/255, blue: 7/255, alpha: 0.2)
        
        firstCell.label.text = "Chat"
        firstCell.label.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        firstCell.badgeLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightThin)
        
        secondCell.label.text = "Live Chat"
        secondCell.label.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        secondCell.badgeLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightThin)
        
        control.add(cells: [
            firstCell, secondCell
        ])
        
        control.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            NSLayoutConstraint(item: control, attribute: .left, relatedBy: .equal, toItem: self.segmentedControlContainerView, attribute: .left, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: control, attribute: .right, relatedBy: .equal, toItem: self.segmentedControlContainerView, attribute: .right, multiplier: 1.0, constant: -16),
            
            NSLayoutConstraint(item: control, attribute: .top, relatedBy: .equal, toItem: self.segmentedControlContainerView, attribute: .top, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: control, attribute: .bottom, relatedBy: .equal, toItem: self.segmentedControlContainerView, attribute: .bottom, multiplier: 1.0, constant: -10)
        ]
        
        self.segmentedControlContainerView.addSubview(control)
        
        self.segmentedControlContainerView.addConstraints(constraints)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSegmentedControl()
        
        self.tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "channelCell")
        
        serverAPI.updateChannels { [weak self] (result) in
            let unreadMessagesCount = self?.channelsWithUnread.map { $0.unread_messages_count }.reduce(0, +)
            if let unreadMessagesCount = unreadMessagesCount, unreadMessagesCount > 0 {
                self?.firstCell.badgeLabel.text = String(unreadMessagesCount)
                self?.firstCell.badgeLabel.sizeToFit()
                self?.firstCell.isBadgeLabelHidden = false
            } else {
                self?.firstCell.isBadgeLabelHidden = true
            }
            
            self?.tableView.reloadData()
        }
    }
}

extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messagesViewController: MessagesViewController = storyboard.instantiateViewController(withIdentifier: "messagesVC") as! MessagesViewController
        
        if indexPath.section == 0 {
            messagesViewController.channelID = self.channelsWithUnread[indexPath.row].id
        } else {
            messagesViewController.channelID = self.channelsWithRead[indexPath.row].id
        }
        
        self.navigationController?.pushViewController(messagesViewController, animated: true)
    }
}

extension ChatsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.channelsWithUnread.count > 0 && self.channelsWithRead.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.channelsWithUnread.count > 0 {
            if section == 0 {
                return self.channelsWithUnread.count
            } else {
                return self.channelsWithRead.count
            }
        } else {
            return self.channelsWithRead.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChannelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as! ChannelTableViewCell
        
        cell.delegate = self
        
        var channel: Channel?
        
        if self.channelsWithUnread.count > 0 {
            if indexPath.section == 0 {
                channel = self.channelsWithUnread[indexPath.row]
            } else {
                channel = self.channelsWithRead[indexPath.row]
            }
        } else {
            channel = self.channelsWithRead[indexPath.row]
        }
        
        if let channel = channel {
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
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

extension ChatsViewController: SPSegmentControlCellStyleDelegate {
    func normalState(segmentControlCell: SPSegmentedControlCell, forIndex index: Int) {
        segmentControlCell.label.textColor = UIColor.white.withAlphaComponent(0.2)
        segmentControlCell.badgeLabel.backgroundColor = UIColor(red: 80/255, green: 195/255, blue: 227/255, alpha: 1)
    }
    
    func selectedState(segmentControlCell: SPSegmentedControlCell, forIndex index: Int) {
        segmentControlCell.label.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    }
}
