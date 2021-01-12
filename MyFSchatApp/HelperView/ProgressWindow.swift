//
//  ProgressWindow.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/3/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit


class  ProgressWindow : NSObject {
    let blackView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    
    let activityIndicator: UIActivityIndicatorView =  {
        let indicator  = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .large
        indicator.color = .white
        indicator.startAnimating()
        return indicator
    }()
    
    func setupBlackView (){
        blackView.addSubview(activityIndicator)
        let constraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: blackView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: blackView.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    func showProgress(){
        
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            blackView.frame = window.frame
            setupBlackView()
            window.addSubview(blackView)
        }
        
    }
    
    func dissmisProgress() {
        blackView.alpha = 0
        activityIndicator.stopAnimating()
    }
}
