//
//  ServerAPI.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class ServerAPI {
    private let baseURL = "https://iostest.db2dev.com"
    
    private let basicAuthToken = "iostest:iostest2k17!".data(using: .utf8)!.base64EncodedString()
    
    func getChannels(completion: @escaping () -> Void) {
        let URL = "\(baseURL)/api/chat/channels/"
        Alamofire.request(URL, headers: ["Authorization": "Basic \(basicAuthToken)"]).responseObject { (response: DataResponse<ChannelsResponse>) in
            
            let channelsResponse = response.result.value
            
            print(channelsResponse ?? "")
            
            completion()
        }
    }
    
    func getMessages(inChannel channel: Channel, completion: @escaping () -> Void) {
        if let channelID = channel.id.value {
            let URL = "\(baseURL)/api/chat/channels/\(channelID)/messages"
            Alamofire.request(URL, headers: ["Authorization": "Basic \(basicAuthToken)"]).responseObject { (response: DataResponse<MessagesResponse>) in
                
                let messagesResponse = response.result.value
                
                print(messagesResponse ?? "")
                
                completion()
            }
        }
    }
}
