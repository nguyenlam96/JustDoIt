//
//  ChangePasswordViewController.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/5/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    var currentUser = FirebaseUser.currentUser
    
    // MARK: - IBOutlet
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var verifyTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = ""
        dismissKeyboardWhenTappingAround()
        
    }
    deinit {
        print("\(#file) is deinitialized")
    }
    // MARK: - IBAction
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if validateFields(){ // all fields filled
            self.messageLabel.text = ""
            ProgressHUD.show("Wait...")
            
            let credential = EmailAuthProvider.credential(withEmail: currentUser!.email, password: currentPasswordTextField.text!)
            
            Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { [unowned self](result, error) in
                
                if error != nil {
                    ProgressHUD.dismiss()
                    self.messageLabel.textColor = UIColor.orange
                    self.messageLabel.text = "Incorrect current password"
                } else {
                    
                    Auth.auth().currentUser?.updatePassword(to: self.newPasswordTextField.text!, completion: { [unowned self](error) in
                        
                        if error != nil {
                            ProgressHUD.dismiss()
                            self.messageLabel.textColor = UIColor.orange
                            self.messageLabel.text = "Fail to update password"
                            print("\(error!.localizedDescription)")
                        } else {
                            ProgressHUD.dismiss()
                            self.messageLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            self.messageLabel.text = "Update password successfully"
                            // reset userdefaul
                        }
                    })
                }
                
            })
            
        }
    }
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Helper Functions
    func validateFields() -> Bool{
        
        if currentPasswordTextField.text == "" {
            currentPasswordTextField.becomeFirstResponder()
        } else if newPasswordTextField.text == "" {
            newPasswordTextField.becomeFirstResponder()
        } else if (newPasswordTextField.text!.count < 6) {
            ProgressHUD.dismiss()
            self.messageLabel.textColor = UIColor.orange
            self.messageLabel.text = "Password have to be >= 6 characters"
            newPasswordTextField.becomeFirstResponder()
        } else if verifyTextField.text == "" {
            verifyTextField.becomeFirstResponder()
        } else if (verifyTextField.text != newPasswordTextField.text){
            ProgressHUD.dismiss()
            self.messageLabel.textColor = UIColor.orange
            self.messageLabel.text = "Verify is not match"
            verifyTextField.becomeFirstResponder()
        }else {
            return true
        }
        return false
    }
    
    func dismissKeyboardWhenTappingAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
