//
//  MessegesResponse.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

class MessagesResponse: Mappable {
    var messages: [Message]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        messages <- map["messages"]
    }
}
