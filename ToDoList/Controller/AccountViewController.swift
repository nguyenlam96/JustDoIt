//
//  AccountViewController.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase
class AccountViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - ViewLifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        firstSetup()
//        let currentUser = UserDefaults.standard.object(forKey: kCURRENT_USER) as! [String:Any]
//        print(currentUser)
        
    }
    deinit {
        print("\(#file) is deinitialized")
    }
    
    // MARK: - Setup
    func firstSetup() {
        let currentUser = FirebaseUser.currentUser
        nameLabel.text = currentUser?.fullname
    }
    // MARK: - IBAction

    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        
        FirebaseUser.logoutCurrentUser { (success) in
            
            if success {
                print("CurrentUser did logout")
            } else {
                ProgressHUD.showError("Fail to logout user")
            }
            
        }
        
        
        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        self.dismiss(animated: true, completion: nil)
        present(loginVC, animated: true)
    }
    
}
