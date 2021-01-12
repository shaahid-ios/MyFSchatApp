//
//  Message.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/10/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import Foundation


class Message:NSObject {
    
    var text:String
    var isIncoming:Bool
    var date: Date
    init(text:String, isIncoming:Bool, date:Date) {
        self.text = text
        self.isIncoming = isIncoming
        self.date = date
    }
    
    
}
