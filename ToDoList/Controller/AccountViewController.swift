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

class AccountViewController: UITableViewController {

    // MARK: - Properties
    
    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    // MARK: - ViewLifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        firstSetup()
        
    }
    deinit {
        print("\(#file) is deinitialized")
    }
    
    // MARK: - Setup
    func firstSetup() {
        
        let currentUser = FirebaseUser.currentUser
        nameLabel.text = currentUser?.fullname
        avatarImageView.image = UIImage(named: "avatar")
        
        self.tableView.tableFooterView = UIView()
        
        
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
        self.dismiss(animated: true, completion: nil)
        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        self.present(loginVC, animated: true)
        
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        let changePasswordVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordView") as! ChangePasswordViewController
        present(changePasswordVC, animated: true)
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }

}

