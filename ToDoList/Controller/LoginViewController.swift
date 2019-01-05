//
//  LoginViewController.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import ProgressHUD
class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firstSetup()

    }
    deinit {
        print("\(#file) is deinitialized")
    }
    // MARK: - Setup
    func firstSetup() {
        self.messageLabel.text = ""
        dismissKeyboardWhenTappingAround()
        
    }
    // MARK: - IBAction
    @IBAction func goButtonPressed(_ sender: UIButton) {
        
        self.messageLabel.text = ""
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if email == "" {
            emailTextField.becomeFirstResponder()
        } else if password == "" {
            passwordTextField.becomeFirstResponder()
        } else if (password.count < 6) {
            ProgressHUD.dismiss()
            self.messageLabel.textColor = .orange
            self.messageLabel.text = "Password have to be >= 6 characters"
        } else {
            // all fields filled, start login
            ProgressHUD.show("Login...")
            FirebaseUser.loginUserWith(email: email, password: password) { (error) in
                if (error != nil) {
                    ProgressHUD.dismiss()
                    self.messageLabel.textColor = .orange
                    self.messageLabel.text = "Incorrect email or password"
                    print(error!.localizedDescription)
                } else {
                    // login success
                    self.dismissKeyboard()
                    let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView") as! UITabBarController
                    mainVC.selectedIndex = 0
                    self.present(mainVC, animated: true, completion: nil)
                }
            }
            
        }
        
    }
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        let signUpVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpView") as! SignUpViewController
        
        self.present(signUpVC, animated: true, completion: nil)
        
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        
        if emailTextField.text == "" {
            emailTextField.becomeFirstResponder()
        } else {
            ProgressHUD.show("Sending email to reset password")
            FirebaseUser.resetUserPassword(email: emailTextField.text!)
        }
        
    }
    
    
    // MARK: - Helper Functions
    
    // MARK: - DismissKeyboard
    func dismissKeyboardWhenTappingAround() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
        
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}
