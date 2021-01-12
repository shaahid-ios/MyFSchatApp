//
//  MessageCell.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/10/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit
import AVFoundation

class IncomingMessageCell: BaseTableCell {
    var delegate: ChatLogController!
    var indexPath: IndexPath!
    let messageLabel: UILabel =  {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryColor
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let profileimageView : UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .secondaryColor
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    @objc func enableDeletion(){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        delegate.deleteIncomingMessage(indexPath: indexPath)
     }
    override func setupCell() {
        super.setupCell()
        addSubview(bubbleView)
        addSubview(messageLabel)
        addSubview(profileimageView)
        selectionStyle = .none
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(enableDeletion))
        longPressGesture.minimumPressDuration = 0.6
        bubbleView.addGestureRecognizer(longPressGesture)
        let constraints = [
            
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20+30),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -13),
            bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -13),
            bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 13),
            bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 13),
            
            
            profileimageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            profileimageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileimageView.widthAnchor.constraint(equalToConstant: 20),
            profileimageView.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    
}
