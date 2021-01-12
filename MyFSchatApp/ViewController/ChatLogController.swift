//
//  ProfileViewController.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/5/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
class ChatLogController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    
    var firstName: String?
    var lastName: String?
    var userID: String?
    var email: String?
    var profileImage:UIImage?
    var chatMessage = [[Message]]()
    var tableView: UITableView  = {
        let tableview = UITableView(frame: .zero, style: .grouped)
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.backgroundColor = .white
        return tableview
    }()
    
    
    
    
    func fetchMessage(){
        let currentUserID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        db.collection("messages").document("\(currentUserID!)")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                if let data = document.data() {
                    if let fetchMessages = data["\(self.userID!)"] as? [[String:Any]] {
                        self.chatMessage = [[Message]]()
                        let cal = Calendar.current
                        let serverMessage = fetchMessages.map({Message(text: $0["text"] as! String, isIncoming: $0["isIncoming"] as! Bool, date: Date.convertToDate(string: $0["date"] as! String) )
                        })
                        let dictMessage = Dictionary(grouping: serverMessage, by: {
                            (element) in
                            return cal.date(from: cal.dateComponents([.year, .month, .day, .hour, .minute], from: element.date))
                            
                        })
                        let sortKeys = dictMessage.keys.sorted(by: {
                            $0?.compare($1 ?? Date()) ==  .orderedAscending
                        })
                        sortKeys.forEach({
                            (key) in
                            self.chatMessage.append(dictMessage[key] ?? [])
                        })
                        self.tableView.reloadData()
                        if self.chatMessage.count != 0 {
                            let indexPath = IndexPath(item: self.chatMessage[self.chatMessage.count-1].count-1, section: self.chatMessage.count-1)
                            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                        
                        
                        
                    }
                }
                
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.addBlurEffectToNavBar()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        navigationItem.title = firstName! + " " +  lastName!
        tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        setupTextInputView()
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardChanged), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardChanged), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        fetchMessage()
        
    }
    
    @objc func dismissKeyboard(){
        textInputView.textView.resignFirstResponder()
    }
    
    @objc func handleKeyBoardChanged(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            let keyboardFrame  = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            textInputBottomConstraint?.constant = isKeboardShowing ? -(keyboardFrame?.height ?? 0) : 0
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: {
                (completed) in
                if isKeboardShowing {
                    if self.chatMessage.count != 0 {
                        let indexPath = IndexPath(row: self.chatMessage[self.chatMessage.count-1].count-1, section: self.chatMessage.count-1)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            })
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessage.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatMessage[section].count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textAlignment = .center
        label.text = Date.convertDateToString(date:chatMessage[section].first?.date ?? Date())
        label.font = UIFont.boldSystemFont(ofSize:15)
        label.backgroundColor = .white
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = chatMessage[indexPath.section][indexPath.row]
        if message.isIncoming {
            let cell = tableView.dequeueReusableCell(withIdentifier: incomingid, for: indexPath) as! IncomingMessageCell
            
            cell.messageLabel.text = message.text
            cell.profileimageView.image = profileImage
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! MessageCell
            
            cell.messageLabel.text = message.text
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
        
        
    }
    
    let incomingid = "messageCell"
    let id = "id"
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor .constraint(equalTo: textInputView.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(IncomingMessageCell.self, forCellReuseIdentifier: incomingid)
        tableView.register(MessageCell.self, forCellReuseIdentifier: id)
        
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textInputView.frame.size.width
        let size = CGSize(width: fixedWidth, height: CGFloat.infinity)
        let fitSize = textInputView.textView.sizeThatFits(size)
        
        textInputHeightConstraint?.constant = fitSize.height + 12
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.text += "\n"
        }
        
        return true
        
    }
    
    
    
    
    func uploadMessage(text:String, date:Date) {
        let currentUserID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let message:[String:Any] = [
            "text": text,
            "isIncoming": false,
            "date": Date.convertToString(date: date)
        ]
        
        let incomingMessage:[String:Any] = [
            "text": text,
            "isIncoming": true,
            "date": Date.convertToString(date: date)
        ]
        
        let senderRef = db.collection("messages").document("\(currentUserID!)")
        let ReceiverRef = db.collection("messages").document("\(userID!)")
        
        senderRef.getDocument(completion:
            {
                (document, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    if let document = document, document.exists {
                        senderRef.updateData(["\(self.userID!)" : FieldValue.arrayUnion([message])])
                    }else {
                        senderRef.setData(
                            ["\(self.userID!)" : [message]]
                        )
                    }
                }
        })
        
        
        ReceiverRef.getDocument(completion:
            {
                (document, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    if let document = document, document.exists {
                        ReceiverRef.updateData(["\(currentUserID!)" : FieldValue.arrayUnion([incomingMessage])])
                    }else {
                        ReceiverRef.setData(
                            ["\(currentUserID!)" : [incomingMessage]]
                        )
                    }
                }
        })
        
        
        
        
        
    }
    
    
    @objc func sendMessage(){
        if textInputView.textView.text != "" {
            uploadMessage(text: textInputView.textView.text, date: Date())
            textInputHeightConstraint?.constant = 50
            textInputView.textView.text = ""
            if chatMessage.count != 0 {
                let indexPath = IndexPath(row: chatMessage[chatMessage.count-1].count-1, section: chatMessage.count-1)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
        }
    }
    
    lazy var textInputView: TextInputView  = {
        let textinputview = TextInputView()
        textinputview.textView.delegate = self
        textinputview.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        textinputview.translatesAutoresizingMaskIntoConstraints = false
        return textinputview
    }()
    
    var textInputBottomConstraint: NSLayoutConstraint?
    var textInputHeightConstraint: NSLayoutConstraint?
    func setupTextInputView(){
        view.addSubview(textInputView)
        
        textInputView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        textInputBottomConstraint = textInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        textInputBottomConstraint?.isActive = true
        textInputHeightConstraint = textInputView.heightAnchor.constraint(equalToConstant: 46)
        textInputHeightConstraint?.isActive = true
    }
    
    
    func  deleteIncomingMessage(indexPath:IndexPath) {
        
        let sendedMessage: [String:Any] = [
            
            "date": Date.convertToString(date: chatMessage[indexPath.section][indexPath.row].date),
            "isIncoming": false,
            "text": chatMessage[indexPath.section][indexPath.row].text
        ]
        
        let receivedMessage:[String:Any] = [
            
            "date": Date.convertToString(date: chatMessage[indexPath.section][indexPath.row].date),
            "isIncoming": true,
            "text": chatMessage[indexPath.section][indexPath.row].text
        ]
        
        let currentUserID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let senderRef = db.collection("messages").document("\(currentUserID!)")
        let ReceiverRef = db.collection("messages").document("\(self.userID!)")
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:.actionSheet)
        alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
            (action) in
            
            senderRef.updateData(
                 [
                     "\(self.userID!)" : FieldValue.arrayRemove([receivedMessage])
             ])
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Remove for Everyone", style: .destructive, handler: {
            (action) in
            
            senderRef.updateData(
                [
                    "\(self.userID!)" : FieldValue.arrayRemove([receivedMessage])
            ])
            
            ReceiverRef.getDocument(completion: {
                (document, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    if let document = document, document.exists {
                        if let data = document.data() , data["\(currentUserID!)"] != nil {
                            ReceiverRef.updateData(
                                [
                                    "\(currentUserID!)": FieldValue.arrayRemove([sendedMessage])
                            ])
                        }
                    }
                }
                
            })
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController,animated: true)
        
    }
    
    
    func  deleteMessage(indexPath:IndexPath) {
        
        let sendedMessage: [String:Any] = [
            
            "date": Date.convertToString(date: chatMessage[indexPath.section][indexPath.row].date),
            "isIncoming": false,
            "text": chatMessage[indexPath.section][indexPath.row].text
        ]
        
        let receivedMessage:[String:Any] = [
            
            "date": Date.convertToString(date: chatMessage[indexPath.section][indexPath.row].date),
            "isIncoming": true,
            "text": chatMessage[indexPath.section][indexPath.row].text
        ]
        
        let currentUserID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let senderRef = db.collection("messages").document("\(currentUserID!)")
        let ReceiverRef = db.collection("messages").document("\(self.userID!)")
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:.actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
            (action) in
            
            senderRef.updateData(
                 [
                     "\(self.userID!)" : FieldValue.arrayRemove([sendedMessage])
             ])
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Remove for Everyone", style: .destructive, handler: {
            (action) in
            
            senderRef.updateData(
                [
                    "\(self.userID!)" : FieldValue.arrayRemove([sendedMessage])
            ])
            
            ReceiverRef.getDocument(completion: {
                (document, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    if let document = document, document.exists {
                        if let data = document.data() , data["\(currentUserID!)"] != nil {
                            ReceiverRef.updateData(
                                [
                                    "\(currentUserID!)": FieldValue.arrayRemove([receivedMessage])
                            ])
                        }
                    }
                }
                
            })
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController,animated: true)
        
    }
    
}


extension Date {
    static func convertDateToString(date:Date)->String{
        var text:String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let elapseTimeInSeconds = Date().timeIntervalSince(date)
        let secondsInDay: TimeInterval = 60*60*24
        if elapseTimeInSeconds > 7*secondsInDay {
            dateFormatter.dateFormat = "MM/dd/yy"
        }else if elapseTimeInSeconds > secondsInDay {
            
            dateFormatter.dateFormat = "EEE"
        }
        text = dateFormatter.string(from: date)
        return text
    }
    
    
    static func convertToString(date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
        
    }
    
    
    static func convertToDate(string:String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: string)!
        
    }
}
