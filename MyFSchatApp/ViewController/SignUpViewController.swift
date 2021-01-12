//
//  SignUpViewController.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/3/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class SignUpViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    lazy var profileImage : UIImageView  = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "placeholder")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadPhoto(_:))))
        return imageView
    }()
    let selectLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select Profile Picture"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    @objc func uploadPhoto (_ sender: UITapGestureRecognizer){
        email.resignFirstResponder()
        password.resignFirstResponder()
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage]  as? UIImage{
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
        
        
    }
    
    lazy var  email: UITextField =  {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Email"
        textfield.delegate = self
        return textfield
    }()
    
    lazy var firstName: UITextField =  {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "First Name"
        textfield.delegate = self
        return textfield
    }()
    lazy var LastName: UITextField =  {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Last Name"
        textfield.delegate = self
        return textfield
    }()
    
    lazy var password: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Password"
        textfield.isSecureTextEntry = true
        textfield.delegate = self
        return textfield
    }()
    
    lazy var  confirmPassword: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Confirm Password"
        textfield.isSecureTextEntry = true
        textfield.delegate = self
        return textfield
    }()
    lazy var signupButton : UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .primaryColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func createAccount(){
        
        view.endEditing(true)
        if firstName.text == "" || LastName.text == "" {
            let  alertTitle = "Incomplete Credentials"
            var alertMessage = ""
            if firstName.text == "" && LastName.text != "" {
                alertMessage = "Please enter your first name"
                
            }
            else if  firstName.text != "" && LastName.text == ""{
                
                alertMessage = "Please enter your last name"
                
            }
            else{
                alertMessage = "Please enter your first and last name"
            }
            let alertController = UIAlertController(title: alertTitle , message:  alertMessage, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
        else if password.text != confirmPassword.text{
            let alertController = UIAlertController(title: "Password Misatched" , message: "Please veriy your passwords", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
        else {
            let progressWindow = ProgressWindow()
            progressWindow.showProgress()
            Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: {
                
                (auth, err) in
                if err != nil {
                    let attributedString = NSAttributedString(string: "Sign Up Failed !", attributes: [
                        NSAttributedString.Key.foregroundColor : UIColor.red
                    ])
                    let alertController = UIAlertController(title: "" , message:                err!.localizedDescription, preferredStyle: .alert)
                    alertController.setValue(attributedString, forKey: "attributedTitle")
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.email.text = ""
                        self.password.text = ""
                        self.confirmPassword.text = ""
                        self.firstName.text = ""
                        self.LastName.text = ""
                    }))
                    progressWindow.dissmisProgress()
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    
                    let storageRef = Storage.storage().reference()
                    let userImageRef = storageRef.child("image/\(auth!.user.uid).png")
                    
                    if let data = self.profileImage.image!.pngData() {
                        
                        userImageRef.putData(data, metadata: nil){
                            (metadata ,error) in
                            guard let metadata = metadata else {
                                return
                            }
                            if error != nil {
                                
                                
                                let attributedString = NSAttributedString(string: "Can Not upload Profile Image !", attributes: [
                                    NSAttributedString.Key.foregroundColor : UIColor.red
                                ])
                                let alertController = UIAlertController(title: "" , message:                err!.localizedDescription, preferredStyle: .alert)
                                alertController.setValue(attributedString, forKey: "attributedTitle")
                                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                    
                                    self.profileImage.image = UIImage(named: "placeholder")
                                }))
                                progressWindow.dissmisProgress()
                                self.present(alertController, animated: true, completion: nil)
                                
                            }else {
                                
                                
                                let db = Firestore.firestore()
                                db.collection("users").document("\(auth!.user.uid)") .setData(
                                    
                                    [
                                        "email": self.email.text!,
                                        "firstName":  self.firstName.text!,
                                        "lastName": self.LastName.text!
                                        
                                    ]
                                ){ err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    }
                                }
                                
                                
                                auth?.user.sendEmailVerification(completion: {
                                    (result) in
                                    let alertController = UIAlertController(title: "Verification Email Sent" , message: "Please verify your email account to log in", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "Ok", style:.default, handler:  { (action) in
                                        self.navigationController?.popViewController(animated: true)
                                    }))
                                    progressWindow.dissmisProgress()
                                    self.present(alertController, animated: true, completion: nil)
                                })
                                
                                
                                
                            }
                        }
                    }
                    
                    
                    
                    
                }
                
                
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Create Your Account"
        navigationController?.navigationBar.titleTextAttributes  = [NSAttributedString.Key.foregroundColor:UIColor.primaryColor]
        navigationController?.navigationBar.addBlurEffectToNavBar()
        tabBarController?.tabBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSignUpPage()
    }
    
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    private func setupSignUpPage(){
        
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height+150)
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        scrollView.addSubview(profileImage)
        scrollView.addSubview(selectLabel)
        scrollView.addSubview(email)
        scrollView.addSubview(firstName)
        scrollView.addSubview(LastName)
        scrollView.addSubview(password)
        scrollView.addSubview(confirmPassword)
        scrollView.addSubview(signupButton)
        let constraints = [
            profileImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            profileImage.centerYAnchor.constraint(equalTo: scrollView.topAnchor, constant:  100),
            profileImage.widthAnchor.constraint(equalToConstant: 100),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            selectLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            selectLabel.centerYAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 15),
            
            email.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            email.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor, constant: 150),
            email.heightAnchor.constraint(equalToConstant: 40),
            email.widthAnchor.constraint(equalToConstant: 300),
            
            firstName.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            firstName.centerYAnchor.constraint(equalTo: email.centerYAnchor, constant:70),
            firstName.heightAnchor.constraint(equalToConstant: 40),
            firstName.widthAnchor.constraint(equalToConstant: 300),
            
            
            LastName.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            LastName.centerYAnchor.constraint(equalTo: firstName.centerYAnchor, constant:70),
            LastName.heightAnchor.constraint(equalToConstant: 40),
            LastName.widthAnchor.constraint(equalToConstant: 300),
            
            password.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            password.centerYAnchor.constraint(equalTo: LastName.centerYAnchor, constant: 70),
            password.heightAnchor.constraint(equalToConstant: 40),
            password.widthAnchor.constraint(equalToConstant: 300),
            
            confirmPassword.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            confirmPassword.centerYAnchor.constraint(equalTo: password.centerYAnchor, constant: 70),
            confirmPassword.heightAnchor.constraint(equalToConstant: 40),
            confirmPassword.widthAnchor.constraint(equalToConstant: 300),
            
            signupButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            signupButton.centerYAnchor.constraint(equalTo: confirmPassword.centerYAnchor, constant: 70),
            signupButton.heightAnchor.constraint(equalToConstant: 30),
            signupButton.widthAnchor.constraint(equalToConstant:  90)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        // toDo : validate input
    }
    
}




extension UINavigationBar {
    func addBlurEffectToNavBar(){
        
        isTranslucent = true
        setBackgroundImage(UIImage(), for: .default)
        let visualEffectView  = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        var bound = bounds
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            if let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height {
                bound.size.height += statusBarHeight
                bound.origin.y -= statusBarHeight
            }
        }
        visualEffectView.frame = bound
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(visualEffectView)
        visualEffectView.layer.zPosition = -1
        visualEffectView.isUserInteractionEnabled = false
    }
    
}
