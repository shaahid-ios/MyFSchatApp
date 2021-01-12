//
//  ChatViewController.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/5/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
struct LatestChat {
    var user:User?
    var text:String
    var date:Date
}
class ChatViewController : UITableViewController {
    let id = "recent"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title =  "Recent Chats"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        navigationController?.navigationBar.addBlurEffectToNavBar()
        tabBarController?.tabBar.isHidden = false
    }
    
    func fetchUserFromCache(byId:String)->User?{
        if let users = usersCache.object(forKey: "users") as? [User], users.count != 0 {
            return users.filter({$0.userID == byId}).first
        }
        
        return nil
    }
    
    
    func fetchLatestChats(){
        let currentUserID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        db.collection("messages").document("\(currentUserID!)")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                if let data = document.data() as? [String:[[String:Any]]] {
                    self.latestChats.removeAll()
                    for userID in data.keys {
                        let user = self.fetchUserFromCache(byId: userID)
                        if let chatHistory = data[userID], chatHistory.count != 0 {
                            let latestMessage = chatHistory.max(by:  {Date.convertToDate(string: $0["date"] as! String) < Date.convertToDate(string: $1["date"] as! String)})!
                            let text = latestMessage["text"] as! String
                            let date = Date.convertToDate(string: latestMessage["date"] as! String)
                            self.latestChats.append(LatestChat(user: user, text: text, date: date))
                        }
                    }
                    self.latestChats.sort(by: {$0.date > $1.date})
                    self.tableView.reloadData()
                }
                
        }
    }
    
    
    var latestChats:[LatestChat] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.register(RecentChatCell.self, forCellReuseIdentifier: id)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        fetchLatestChats()
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestChats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! RecentChatCell
        
        cell.latestChat = latestChats[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = latestChats[indexPath.row].user
        let chatlogvc =  ChatLogController()
               chatlogvc.firstName = user?.firstName
               chatlogvc.lastName = user?.lastName
               chatlogvc.userID  = user?.userID
               chatlogvc.email = user?.email
               chatlogvc.profileImage = user?.profileImage
               navigationController?.pushViewController( chatlogvc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "delete") {  (contextualAction, sourceView, Completion) in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
                (action) in
                let db = Firestore.firestore()
                let currentUserID = Auth.auth().currentUser?.uid
                db.collection("messages").document("\(currentUserID!)").updateData(
                    [  "\((self.latestChats[indexPath.row].user?.userID)!)" : FieldValue.delete()]
                )
                Completion(true)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action) in
                Completion(false)
            }))
            self.present(alertController,animated: true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        return swipeActions
    }
    
}
