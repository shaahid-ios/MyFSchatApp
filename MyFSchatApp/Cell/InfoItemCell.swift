//
//  InfoItemCell.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/7/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit
class InfoItemCell : BaseCollectionViewCell {
    
    let itemLabel: UILabel = {
       let label = UILabel()
        label.text = "harrychen19101995@gmail.com"
        label.textColor = .white
        return label
    }()
    override func setupCell() {
        addSubview(itemLabel)
        addConstraintsWithFormat(format: "H:|[v0]|", views: itemLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: itemLabel)
    }
    
    
}
