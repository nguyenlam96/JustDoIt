//
//  List.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

struct List {
    // MARK: - Properties
    var listId: String
    var createdAt: Date
    
    var name: String
    var priority: String
    var userId: String
    
    // MARK: - Init
    init(listId: String, createAt: Date, name: String, priority: String, userId: String) {
        
        self.listId = listId
        self.createdAt = createAt
        self.name = name
        self.priority = priority
        self.userId = userId
        
    }
    
    init(from dict: [String:Any] ) {
        
        self.listId = dict[kLIST_ID] as! String
        
        if let createdAt = dict[kCREATE_AT] as? String {
            self.createdAt = (createdAt.count != 14) ? Date() : dateFormatter().date(from: createdAt)!
        } else {
            self.createdAt = Date()
        }
        
        if let name = dict[kLIST_NAME] as? String {
            self.name = name
        } else {
            self.name = ""
        }
        if let priority = dict[kPRIORITY] as? String {
            self.priority = priority
        } else {
            self.priority = ""
        }
        if let userId = dict[kUSER_ID] as? String {
            self.userId = userId
        } else {
            self.userId = ""
        }
    }
    
    static func getListDict(from list: List) -> [String:Any] {
        
        let createdAtString = dateFormatter().string(from: list.createdAt)
        
        let listDict = [kLIST_ID: list.listId,
                        kCREATE_AT: createdAtString,
                        kLIST_NAME: list.name,
                        kPRIORITY: list.priority,
                        kUSER_ID: list.userId]
        return listDict
        
    }
    
    // MARK: - CRUD
    static func saveListInBackground(list: List, completion: @escaping (_ error: Error?) -> Void ) {
        
//        let ref = reference(.List).document()
//        var listDict = getListDict(from: list)
//        listDict[kLIST_ID] = ref.documentID
//        ref.setData(listDict)
          let listDict = getListDict(from: list)
        reference(.List).document(list.listId).setData(listDict) { (error) in
            completion(error)
        }
        
    }
    
    static func deleteItemBackground(list: List, completion: @escaping (_ error: Error?) -> Void ) {
        
        let ref = reference(.List).document(list.listId)
        ref.delete { (error) in
            completion(error)
        }
        
    }
    
    static func updateItemInBackground(list: List, completion: @escaping (_ error: Error?) -> Void ) {
        
        let ref = reference(.List).document(list.listId)
        ref.setData(getListDict(from: list)) { (error) in
            completion(error)
        }
        
    }
    
}
