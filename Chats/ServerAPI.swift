//
//  ServerAPI.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireObjectMapper

class ServerAPI {
    private let baseURL = "https://iostest.db2dev.com"
    
    private let basicAuthToken = "iostest:iostest2k17!".data(using: .utf8)!.base64EncodedString()
    
    lazy var realm = try! Realm()
    
    func updateChannels(completion: @escaping (Result<[Channel]>) -> Void) {
        let URL = "\(baseURL)/api/chat/channels/"
        Alamofire.request(URL, headers: ["Authorization": "Basic \(basicAuthToken)"]).responseObject { (response: DataResponse<ChannelsResponse>) in
            
            if case .failure(let error) = response.result {
                completion(.failure(error))
                return
            }
            
            if case .success(let channelsResponse) = response.result {
                if let channels = channelsResponse.channels {
                    try! self.realm.write {
                        for channel in channels {
                            self.realm.add(channel, update: true)
                        }
                    }
                    
                    completion(.success(channels))
                }
            }
        }
    }
    
    func updateMessages(inChannel channel: Channel, completion: @escaping (Result<[Message]>) -> Void) {
        let URL = "\(baseURL)/api/chat/channels/\(channel.id)/messages"
        Alamofire.request(URL, headers: ["Authorization": "Basic \(basicAuthToken)"]).responseObject { (response: DataResponse<MessagesResponse>) in
            
            if case .failure(let error) = response.result {
                completion(.failure(error))
                return
            }
            
            if case .success(let messagesResponse) = response.result {
                if let messages = messagesResponse.messages {
                    try! self.realm.write {
                        for message in messages {
                            message.channel_id.value = channel.id
                            self.realm.add(message, update: true)
                        }
                    }
                    
                    completion(.success(messages))
                }
            }
        }
    }
}
