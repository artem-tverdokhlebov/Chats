//
//  Message.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm

class Message: Object, Mappable {
    dynamic var text: String?
    dynamic var sender: User?
    dynamic var create_date: Date?
    dynamic var is_read: Bool = false
    
    var channel_id = RealmOptional<Int>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        text <- map["text"]
        sender <- map["sender"]
        create_date <- (map["create_date"], ISO8601ExtendedDateTransform())
        is_read <- map["is_read"]
    }
}
