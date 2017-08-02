//
//  Channel.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm

class Channel: Object, Mappable {
    dynamic var id = -1
    var users: List<User>? = List<User>()
    dynamic var last_message: Message?
    dynamic var unread_messages_count = 0
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        users <- (map["users"], ListTransform<User>())
        last_message <- map["last_message"] 
        unread_messages_count <- map["unread_messages_count"]
    }
}
