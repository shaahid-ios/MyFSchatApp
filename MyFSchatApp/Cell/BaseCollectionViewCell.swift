//
//  BaseCollectionViewCell.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/7/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit


class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    func setupCell (){
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
