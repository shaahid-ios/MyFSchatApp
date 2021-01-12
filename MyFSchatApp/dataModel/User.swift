//
//  User.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/5/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit

class User : NSObject{
    
    var userID: String
    var firstName: String
    var lastName: String
    var email: String
    var profileImage:UIImage?
    
    init(userID:String, firstName:String, lastName:String, email:String){
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
