//
//  File.swift
//  Chatctron
//
//  Created by Hanlin Chen on 8/3/20.
//  Copyright © 2020 Hanlin Chen. All rights reserved.
//

import UIKit
import Firebase
extension UIColor {
    
    static let primaryColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
}

class LoginViewController : UIViewController , UITextFieldDelegate{
    
    let logView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
        
    }()
    lazy var email: UITextField =  {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Email"
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
    lazy var loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .primaryColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        return button
    }()
    
    @objc func login(){
        view.endEditing(true)
        if email.text == "" || password.text == "" {
            
            let alertTitle = "Incomplete Credential"
            var alertMessage = ""
            if email.text == "" && password.text != "" {
                alertMessage = "Please enter your email"
            }
            else if email.text != "" && password.text == "" {
                alertMessage = "Please enter your password"
            }
            else{
                alertMessage = "Please enter your email and password"
            }
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        else {
            let progressWindow = ProgressWindow()
            progressWindow.showProgress()
            Auth.auth().signIn(withEmail: email.text!, password: password.text!, completion: {
                (auth, err) in
                progressWindow.dissmisProgress()
                if err != nil {
                    
                    let attributedString = NSAttributedString(string: "Login Failed !", attributes: [NSAttributedString.Key.foregroundColor:UIColor.red])
                    let alertController = UIAlertController(title: "", message: err?.localizedDescription, preferredStyle: .alert)
                    alertController.setValue(attributedString, forKey: "attributedTitle")
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                        self.email.text = ""
                        self.password.text = ""
                    }))
                    self.present(alertController, animated: true, completion: nil)
                    
                }else{
                    
                    if !auth!.user.isEmailVerified {
                        
                        let attributedString = NSAttributedString(string: "Email Verfication Required", attributes: [NSAttributedString.Key.foregroundColor:UIColor.red])
                        let alertController = UIAlertController(title: "", message: "Please verify your email and try agian !", preferredStyle: .alert)
                        alertController.setValue(attributedString, forKey: "attributedTitle")
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else{
                        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                        let tabbarCV = CustomTabBarController()
                            window.rootViewController = tabbarCV
                        }
                    }
                    
                }
                
            })
        }
        
        
    }
    
    lazy var signupButton : UIButton = {
        let button = UIButton()
        button.setTitle("SignUp", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.primaryColor, for: .normal)
        button.addTarget(self, action: #selector(goToSignupPage), for: .touchUpInside)
        return button
    }()
    
    @objc func goToSignupPage(){
        
        view.endEditing(true)
        navigationController?.pushViewController(SignUpViewController(), animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
  
        setupLoginPage()
        
        
    }
    
    private func setupLoginPage(){
        view.addSubview(logView)
        view.addSubview(email)
        view.addSubview(password)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        let constraints = [
            
            logView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logView.centerYAnchor.constraint(equalTo:
                email.centerYAnchor, constant: -90),
            logView.widthAnchor.constraint(equalToConstant: 100),
            logView.heightAnchor.constraint(equalToConstant: 100),
            
            
            email.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            email.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant:-50),
            email.heightAnchor.constraint(equalToConstant: 40),
            email.widthAnchor.constraint(equalToConstant: 300),
            password.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            password.centerYAnchor.constraint(equalTo: email.centerYAnchor, constant: 70),
            password.heightAnchor.constraint(equalToConstant: 40),
            password.widthAnchor.constraint(equalToConstant: 300),
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: password.centerYAnchor, constant: 70),
            loginButton.heightAnchor.constraint(equalToConstant: 30),
            loginButton.widthAnchor.constraint(equalToConstant:  70),
            signupButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            signupButton.centerYAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 50),
            signupButton.heightAnchor.constraint(equalToConstant: 30),
            signupButton.widthAnchor.constraint(equalToConstant:  70),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewDict = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDict[key] = view
            
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewDict))
    }
}
