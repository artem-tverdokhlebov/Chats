//
//  File.swift
//  Chats
//
//  Created by Artem Tverdokhlebov on 8/1/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import Foundation
import ObjectMapper

/// ISO 8601 extended date format transform which contains milliseconds.
class ISO8601ExtendedDateTransform: DateFormatterTransform {
    
    init() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        super.init(dateFormatter: formatter)
    }
    
}
