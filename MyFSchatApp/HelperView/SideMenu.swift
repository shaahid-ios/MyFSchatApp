//
//  SideMenu.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/6/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit
extension UIColor {
    static var secondaryColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    
}

struct Item {
    var setting:String
    var icon: UIImage
}
class Menu : UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let id = "menuCell"
    let profileid = "profile"
    let infoid = "info"
    var deletgate:SideMenu?
    var menuItem:[Item] = [
        Item(setting:"Delete Your Account", icon: UIImage(named: "trash")!),
        Item(setting:"Logout", icon: UIImage(named: "exit")!),
        Item(setting:"Cancel", icon: UIImage(named: "cancel")!)
        
    ]
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: profileid, for: indexPath) as! ProfileCell
            cell.imageProfile.image = deletgate?.currentUser?.profileImage
            return cell
        }
        else if indexPath.item == 1 {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: infoid, for: indexPath) as! InfoItemCell
            cell.itemLabel.text = deletgate!.currentUser!.firstName + " " + deletgate!.currentUser!.lastName
            return cell
        }
        else if indexPath.item == 2 {
            
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: infoid, for: indexPath) as! InfoItemCell
            cell.itemLabel.text = deletgate!.currentUser!.email
            return cell
            
        }
        else{
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! MenuItemCell
            cell.itemLabel.text = menuItem[indexPath.item-3].setting
            cell.itemIcon.image = menuItem[indexPath.item-3].icon
            return cell
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 3{
            deletgate?.dismissSideMenu()
            deletgate?.delegate?.deleteAccount()
        }
        else if indexPath.item == 4{
            deletgate?.dismissSideMenu()
            deletgate?.delegate?.logout()
        }
        else if indexPath.item == 5 {
            deletgate?.dismissSideMenu()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size:CGSize
        if indexPath.item == 0 {
            size = CGSize(width: collectionView.frame.size.width, height: 60)
        }
        else{
            
            size = CGSize(width: collectionView.frame.width, height: 40)
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero
            , collectionViewLayout: UICollectionViewFlowLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondaryColor
        setupCollectionView()
        
    }
    let topbottomPadding = 30
    let leftrightPadding = 20
    var collectionViewWidthConstraint: NSLayoutConstraint?
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        
        
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(topbottomPadding)).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CGFloat(topbottomPadding)).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        collectionViewWidthConstraint = collectionView.widthAnchor.constraint(equalTo: widthAnchor)
        collectionViewWidthConstraint?.isActive = true
        
        collectionView.register(MenuItemCell.self, forCellWithReuseIdentifier: id)
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: profileid)
        collectionView.register(InfoItemCell.self, forCellWithReuseIdentifier: infoid)
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
class SideMenu {
    var currentUser: User?
    var delegate:HomeViewController?
    lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSideMenu)))
        return view
    }()
    
    var trailingConstraining: NSLayoutConstraint?
    let menuWidth:CGFloat = 300
    func setup(){
        
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            window.addSubview(blackView)
            window.addSubview(menu)
            blackView.translatesAutoresizingMaskIntoConstraints = false
            blackView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            blackView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
            blackView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            blackView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
            
            menu.translatesAutoresizingMaskIntoConstraints = false
            menu.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            menu.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
            menu.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            trailingConstraining =  menu.trailingAnchor.constraint(equalTo: window.leadingAnchor)
            trailingConstraining?.isActive = true
        }
    }
    
    lazy var menu: Menu = {
        let menu = Menu()
        menu.deletgate = self
        return menu
    }()
    func showSideMenu(){
        self.trailingConstraining?.constant = self.menuWidth
        menu.collectionViewWidthConstraint?.constant -= CGFloat(2*menu.leftrightPadding)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:
            {
                
                self.blackView.alpha = 1
                if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                    window.layoutIfNeeded()
                }
                
        }
            , completion: nil)
    }
    
    
    
    
    @objc func dismissSideMenu() {
        trailingConstraining?.constant = 0
        menu.collectionViewWidthConstraint?.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:
            {
                self.blackView.alpha = 0
                if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                    window.layoutIfNeeded()
                }
                
                
        }
            , completion: nil)
        
    }
    
    
    
}

