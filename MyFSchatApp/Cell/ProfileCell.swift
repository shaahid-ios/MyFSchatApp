//
//  ProfileCell.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/7/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit


class ProfileCell: BaseCollectionViewCell {
       let imageProfile: UIImageView = {
       let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    override func setupCell() {
        super.setupCell()
        addSubview(imageProfile)
        imageProfile.translatesAutoresizingMaskIntoConstraints = false
        imageProfile.centerXAnchor.constraint(equalTo: imageProfile.centerXAnchor).isActive = true
        imageProfile.centerYAnchor.constraint(equalTo: imageProfile.centerYAnchor).isActive = true
        imageProfile.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageProfile.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        
        
    }
}
