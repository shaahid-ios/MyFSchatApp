//
//  RecentChatCell.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/20/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit

class RecentChatCell:BaseTableCell {
    
    var latestChat: LatestChat?{
        didSet{
            profileImageView.image = latestChat?.user?.profileImage
            
            if let firstname = latestChat?.user?.firstName, let lastName = latestChat?.user?.lastName{
            userName.backgroundColor = .clear
            userName.text = firstname + " " + lastName
            }
            message.backgroundColor = .clear
            message.text = latestChat?.text
            
            timeLabel.backgroundColor = .clear
            timeLabel.text =  Date.convertDateToString(date: latestChat!.date) 
        }
    }
    
    
    let profileImageView: UIImageView = {
         let imageView = UIImageView()
         imageView.layer.cornerRadius = 25
         imageView.layer.masksToBounds = true
         imageView.backgroundColor = .primaryColor
         return imageView
     }()
    
    
    
    let userName : UILabel = {
        let label = UILabel()
        label.textColor = .primaryColor
        label.backgroundColor = .primaryColor
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let timeLabel : UILabel = {
          let label = UILabel()
          label.textColor = .black
          label.backgroundColor = .primaryColor
          label.font = UIFont.boldSystemFont(ofSize: 13)
          return label
      }()
    
    
    let message : UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.backgroundColor = .primaryColor
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let seperator: UIView = {
        let seperator = UIView()
        seperator.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return seperator
    }()
    
    
    override func setupCell() {
        super.setupCell()
        addSubview(profileImageView)
        addSubview(userName)
        addSubview(timeLabel)
        addSubview(seperator)
        addSubview(message)
        addConstraintsWithFormat(format: "H:|-20-[v0(50)]-200-[v1(80)]", views: profileImageView, timeLabel)
        addConstraintsWithFormat(format: "H:|-90-[v0(200)]", views: userName)
        addConstraintsWithFormat(format: "V:|-10-[v0(20)]", views: timeLabel)
        addConstraintsWithFormat(format: "V:|-20-[v0(50)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:|-35-[v0(20)]-5-[v1(20)]", views: userName, message)
        addConstraintsWithFormat(format: "H:|-90-[v0]-20-|", views: message)
        addConstraintsWithFormat(format: "H:|-90-[v0]|", views: seperator)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: seperator)
    }
}
