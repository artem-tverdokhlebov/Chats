//
//  File.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

struct CustomTransform<T: RealmOptionalType>: TransformType {
    public typealias Object = RealmOptional<T>
    public typealias JSON = Array<Any>
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        return Object()
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return Array()
    }
}
