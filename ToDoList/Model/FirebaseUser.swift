//
//  FirebaseUser.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import MBProgressHUD
import FirebaseFirestore
import FirebaseAuth

struct FirebaseUser {
    
    var userId: String
    var createdAt: Date
    
    var email: String
    var firstName: String
    var lastName: String
    var fullname: String {
        return firstName + " " + lastName
    }
    
    
    // MARK: - Init
    init(userId: String, createdAt: Date, email: String, firstName: String, lastName: String ) {
        self.userId = userId
        self.createdAt = createdAt
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
    
    init(from dict: [String:Any] ) {
        
        self.userId = dict[kUSER_ID] as! String
        
        if let createdAt = dict[kCREATE_AT] as? String {
            self.createdAt = (createdAt.count != 14) ? Date() : dateFormatter().date(from: createdAt)!
        } else {
            self.createdAt = Date()
        }
        
        if let email = dict[kUSER_EMAIL] as? String {
            self.email = email
        } else {
            self.email = ""
        }
        if let firstName = dict[kUSER_FIRST_NAME] as? String {
            self.firstName = firstName
        } else {
            self.firstName = ""
        }
        if let lastName = dict[kUSER_LAST_NAME] as? String {
            self.lastName = lastName
        } else {
            self.lastName = ""
        }
    }
    
    static func getUserDict(from user: FirebaseUser) -> [String:Any] {
        
        let createAtString = dateFormatter().string(from: user.createdAt)
        
        let userDict = [kUSER_ID: user.userId,
                        kCREATE_AT: createAtString,
                        kUSER_EMAIL: user.email,
                        kUSER_FIRST_NAME: user.firstName,
                        kUSER_LAST_NAME: user.lastName] as [String:Any]
        return userDict
        
    }
    
    // MARK: - get current User
    static var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: FirebaseUser? {
        if Auth.auth().currentUser != nil {
            if let userDict = UserDefaults.standard.object(forKey: kCURRENT_USER) as? [String:Any] {
                return FirebaseUser(from: userDict)
            } else {
                print("UserDefault currentUser is nil")
            }
        } else {
            print("auth().currentUser is nil")
        }
        return nil
    }
    
    // MARK: - Login/Logout funcs
    static func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void ) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                completion(error)
                return
            } else {
                self.fetchUserFromFireStroreAndSaveToLocal(userId: Auth.auth().currentUser!.uid )
                completion(error)
            }
        }
        
    }
    
    static func fetchUserFromFireStroreAndSaveToLocal(userId: String) {
        
        reference(.User).document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            if snapshot.exists {
                let userDict = snapshot.data()! as [String:Any]
                UserDefaults.standard.setValue(userDict, forKey: kCURRENT_USER)
            }
        }
    }
    static func logoutCurrentUser(completion: @escaping (_ success: Bool) -> Void ) {
        // remove from UserDefault
        UserDefaults.standard.removeObject(forKey: kCURRENT_USER)
        // Signout from firebase Auth
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            completion(false)
            print(error.localizedDescription)
        }
    }
    // MARK: - Fetch User
    
    
//    static func fetchCurrentUserFromFirestore(userId: String, completion: @escaping (_ user: FirebaseUser?) -> Void) {
//
//        reference(.User).document(userId).getDocument { (snapshot, error) in
//
//            guard let snapshot = snapshot else {  return }
//
//            if snapshot.exists {
//                let userDict = snapshot.data()! as [String:Any]
//                let user = FirebaseUser(from: userDict)
//                completion(user)
//            } else {
//                completion(nil)
//            }
//
//        }
//    }
    // MARK: - Register funcs
    static func registerUserWith(email: String, password: String, firstName: String, lastName: String, completion: @escaping (_ error: Error?) -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                completion(error)
            } else {
                let user = FirebaseUser(userId: Auth.auth().currentUser!.uid, // if createUser success, the user is authed automatically
                                        createdAt: Date(),
                                        email: email,
                                        firstName: firstName,
                                        lastName: lastName)
                
                saveUserLocally(user: user)
                saveUserToFirestore(user: user)
                completion(error)
            }
        }
    }
    
    // MARK: - Delete User
    static func deleteCurrentUser(completion: @escaping (_ error: Error?) -> Void ) {
        Auth.auth().currentUser?.delete(completion: { (error) in
            completion(error)
        })
    }
    // MARK: - Update User

    // MARK: - Saving User
    
    static func saveUserLocally(user: FirebaseUser) {
        
        let userDict = getUserDict(from: user)
        UserDefaults.standard.setValue(userDict, forKey: kCURRENT_USER)
        
    }
    static func saveUserToFirestore(user: FirebaseUser) {
        
        let userDict = getUserDict(from: user)
        reference(.User).document(user.userId).setData(userDict) { (error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
        
    }
    
}
