//
//  MenuItemCell.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/7/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit


class MenuItemCell : BaseCollectionViewCell {
    
    let itemLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    let itemIcon: UIImageView = {
       let icon = UIImageView()
        return icon
    }()
    override func setupCell() {
        addSubview(itemLabel)
        addSubview(itemIcon)
        addConstraintsWithFormat(format: "H:|[v0]-10-[v1(20)]", views: itemLabel, itemIcon)
        addConstraintsWithFormat(format: "V:|[v0]|", views: itemLabel)
        addConstraintsWithFormat(format: "V:|-10-[v0(20)]", views: itemIcon)
    }
    
    
}
