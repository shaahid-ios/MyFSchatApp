//
//  CustomTabViewController.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/5/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let homeViewVC = HomeViewController()
        let chatViewVC = ChatViewController()
        homeViewVC.delegate = chatViewVC
        
        let homevc = UINavigationController(rootViewController: homeViewVC)
        homevc.tabBarItem.title = "Friends"
        homevc.tabBarItem.image =  UIImage(named: "groups")

        
        let chatvc = UINavigationController(rootViewController: chatViewVC)
        chatvc.tabBarItem.title = "Recent Chats"
        chatvc.tabBarItem.image =  UIImage(named: "recent")?.withRenderingMode(.alwaysTemplate)
        
        
        viewControllers = [
            homevc,
            chatvc
        ]
        
    }
    
    
}
