//
//  HomeViewController.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/4/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


let usersCache = NSCache<NSString, NSArray>()
let currentUserCache = NSCache<NSString, User>()
class HomeViewController : UITableViewController, UISearchResultsUpdating {
    
    var delegate: ChatViewController?
    @objc func refreshFriend(){
        fetchUsers{self.users = $0}
        refreshControl?.endRefreshing()
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    func setupRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshFriend), for: .valueChanged)
        refreshControl?.tintColor = .primaryColor
        refreshControl?.attributedTitle = NSAttributedString(string: "refreshing", attributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryColor])
    }
    

    
    let ID = "Friend"
    var users: [User] = []
    var filteredUsers: [User] = []
    var userID:String?
    var currentUser:User?
    
    lazy var searchController: UISearchController  = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Friend"
        searchController.definesPresentationContext = true
        return searchController
    }()
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText != "" {
                let searchStringByFristorLastName = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                let searchStringByFullName = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                filteredUsers = users.filter({
                    let firstName =  $0.firstName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    let lastName = $0.lastName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    return firstName.contains(searchStringByFristorLastName) || lastName.contains(searchStringByFristorLastName) || (firstName + " " + lastName).contains(searchStringByFullName)})
            }
            else  {
                filteredUsers = users
            }
        }
        tableView.reloadData()
        
    }
    let loadingIndicator: UIActivityIndicatorView  = {
        let  indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    let loadingView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func deleteAccount(){
        
        let deletealertController = UIAlertController(title: "" , message: "", preferredStyle: .alert)
        let message = NSAttributedString(string: "Are you sure that you want to delete your account?", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16)])
        deletealertController.setValue(message, forKey: "attributedMessage")
        deletealertController.addAction(UIAlertAction(title: "No", style:.cancel, handler:  nil))
        deletealertController.addAction(UIAlertAction(title: "Yes", style:.destructive, handler:  { (action) in
            self.deleteCurrentUser()
        }))
        self.present(deletealertController, animated: true, completion: nil)
    }
    func deleteCurrentUser(){
        
        
        let progressWindow = ProgressWindow()
        progressWindow.showProgress()
        let user = Auth.auth().currentUser
        let userId = user?.uid
        
        
        
        let db = Firestore.firestore()
        
        user?.delete { error in
            if let err = error {
                let attributedString = NSAttributedString(string: "Delete Your Accouunt Failed!", attributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.red
                ])
                let alertController = UIAlertController(title: "" , message:                err.localizedDescription, preferredStyle: .alert)
                alertController.setValue(attributedString, forKey: "attributedTitle")
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
                progressWindow.dissmisProgress()
                self.present(alertController, animated: true, completion: nil)
            } else {
                
                
                // delete profile picture
                let desertRef = Storage.storage().reference().child("image/\(userId!).png")
                desertRef.delete { error in
                    if let err = error {
                        
                        let attributedString = NSAttributedString(string: "Delete Your Profile Image Failed!", attributes: [
                            NSAttributedString.Key.foregroundColor : UIColor.red
                        ])
                        let alertController = UIAlertController(title: "" , message:                err.localizedDescription, preferredStyle: .alert)
                        alertController.setValue(attributedString, forKey: "attributedTitle")
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
                        progressWindow.dissmisProgress()
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        
                        db.collection("users").document("\(userId!)").delete() { err in
                            if let err = err {
                                print(err)
                            } else {
                                let alertController = UIAlertController(title: "Deletion Success" , message: "Your acount has been successfully deleted, sorry to see you go! ", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Ok", style:.default, handler:  { (action) in
                                    let loginVC =  UINavigationController(rootViewController: LoginViewController())
                                    if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                                        window.rootViewController = loginVC
                                    }
                                }))
                                progressWindow.dissmisProgress()
                                self.present(alertController, animated: true, completion: nil)
                            }
                            
                            
                        }
                        
                    }
                }
                
            }
        }
    }
    
    private func fetchUserProfileImage (userID:String, completion: @escaping(UIImage)->Void){
        let ref = Storage.storage().reference()
        let pathref = ref.child("image/\(userID).png")
        pathref.getData(maxSize: .max) { (data, error) in
            if let error = error {
                print(error)
            } else {
                
                let image = UIImage(data: data!)?.withRenderingMode(.alwaysOriginal)
                completion(image!)
                self.tableView.reloadData()
                self.delegate?.tableView.reloadData()
            }}
    }
    
    @objc private func fetchUsers( completion: @escaping([User])->Void){
            let db = Firestore.firestore()
            db.collection("users").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var users:[User] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let user = User(userID: document.documentID, firstName: data["firstName"] as! String, lastName: data["lastName"] as! String, email: data["email"] as! String)
                        self.fetchUserProfileImage(userID: user.userID,completion:  {
                            (image) in
                            user.profileImage = image
                        }
                        )
                        if document.documentID != Auth.auth().currentUser?.uid  {
                            
                            users.append(user)
                        }
                        else{
                            self.currentUser = user
                            currentUserCache.setObject(user, forKey:"currentUser" as NSString)
                            self.navigationItem.leftBarButtonItem?.isEnabled = true
                            self.sideMenu.currentUser = self.currentUser
                            self.sideMenu.delegate = self
                            self.sideMenu.menu.collectionView.reloadData()
                        }
                    }
                    usersCache.setObject(users as NSArray, forKey: "users" as NSString)
                    self.delegate?.tableView.reloadData()
                    self.tableView.isUserInteractionEnabled = true
                    self.loadingView.isHidden = true
                    if self.searchController.isActive {
                        self.filteredUsers = users
                    }else{
                        self.users = users
                    }
                    self.tableView.reloadData()
                    completion(users)
                    
                }
            }
            
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.addBlurEffectToNavBar()
        tabBarController?.tabBar.isHidden = false
    }
    
    let sideMenu = SideMenu()
    @objc func displaySideMenu (){
        sideMenu.showSideMenu()
    }
    
    func logout(){
        do {
            try Auth.auth().signOut()
            let loginVC =  UINavigationController(rootViewController: LoginViewController())
            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                window.rootViewController = loginVC
            }
        }catch{
            print(error)
            return
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        navigationItem.searchController = searchController
        sideMenu.setup()
        view.backgroundColor = .white
        navigationItem.title = "Friends"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(displaySideMenu))
        navigationItem.leftBarButtonItem?.isEnabled = false
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(FriendCell.self, forCellReuseIdentifier: ID)
        setupLoadingView()
        tableView.isUserInteractionEnabled = false
        fetchUsers(completion: {
            self.users = $0
        })
        
        
    }
    
    
    private func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        loadingIndicator.heightAnchor.constraint(equalTo: loadingIndicator.widthAnchor).isActive = true
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredUsers.count
        }else{
            return users.count
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var user:User
        if searchController.isActive {
            user = filteredUsers[indexPath.row]
        }else{
            user = users[indexPath.row]
        }
        let chatlogvc =  ChatLogController()
        chatlogvc.firstName = user.firstName
        chatlogvc.lastName = user.lastName
        chatlogvc.userID  = user.userID
        chatlogvc.email = user.email
        chatlogvc.profileImage = user.profileImage
        navigationController?.pushViewController( chatlogvc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath) as! FriendCell
        var user:User
        if searchController.isActive {
            user = filteredUsers[indexPath.row]
        }else{
            user = users[indexPath.row]
        }
        cell.user = user
        return cell
    }
    
    
    
}


