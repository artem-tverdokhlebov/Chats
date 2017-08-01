//
//  User.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm

class User: Object, Mappable {
    var id = -1
    dynamic var photo: String?
    dynamic var first_name: String?
    dynamic var last_name: String?
    dynamic var username: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        photo <- map["photo"]
        first_name <- map["first_name"]
        last_name <- map["last_name"]
        username <- map["username"]
    }

    func fullName() -> String {
        if let first_name = first_name, let last_name = last_name {
            return first_name + " " + last_name
        } else if let first_name = first_name {
            return first_name
        } else {
            return ""
        }
    }
}
