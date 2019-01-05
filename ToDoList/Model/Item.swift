//
//  Item.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import Firebase
import ProgressHUD
struct Item {
    // MARK: - Properties
    var itemId: String
    var createdAt: Date
    
    var content: String
    var isDone: Bool
    var listId: String
    var priority: String
    var userId: String
    // MARK: - Initialization
    init(itemId: String, createdAt: Date, content: String, isDone: Bool, listId: String, priority: String, userId: String ){
        
        self.itemId = itemId
        self.createdAt = createdAt
        
        self.content = content
        self.isDone = isDone
        self.listId = listId
        self.priority = priority
        self.userId = userId
        
    }
    
    
    init(from dict: [String:Any] ) {
        
        self.itemId = dict[kITEM_ID] as! String
        //
        if let createdAt = dict[kCREATE_AT] as? String {
            self.createdAt = (createdAt.count != 14) ? Date() : dateFormatter().date(from: createdAt)!
        } else {
            self.createdAt = Date()
        }
        //
        if let content = dict[kITEM_CONTENT] as? String {
            self.content = content
        } else {
            self.content = ""
        }
        //
        if let isDone = dict[kIS_DONE] as? Bool {
            self.isDone = isDone
        } else {
            self.isDone = false
        }
        //
        if let listId = dict[kLIST_ID] as? String {
            self.listId = listId
        } else {
            self.listId = ""
        }
        //
        if let priority = dict[kPRIORITY] as? String {
            self.priority = priority
        } else {
            self.priority = getPriority(.Low)
        }
        //
        if let userId = dict[kUSER_ID] as? String {
            self.userId = userId
        } else {
            self.userId = ""
        }
    }
    
    static func getItemDict(from item: Item) -> [String:Any] {
        
        let createdAtString = dateFormatter().string(from: item.createdAt)
        
        let itemDict = [kITEM_ID: item.itemId,
                        kCREATE_AT: createdAtString,
                        kITEM_CONTENT: item.content,
                        kIS_DONE: item.isDone,
                        kLIST_ID: item.listId,
                        kPRIORITY: item.priority,
                        kUSER_ID: item.userId] as [String : Any]
        return itemDict
        
    }
    
    // MARK: - CRUD
    static func saveItemInBackground(item: Item, completion: @escaping (_ error: Error?) -> Void ) {
        
        let itemDict = getItemDict(from: item)
        reference(.Item).document(item.itemId).setData(itemDict) { (error) in
            completion(error)
        }

    }
    
    static func deleteItemBackground(item: Item, completion: @escaping (_ error: Error?) -> Void ) {
        
        let ref = reference(.Item).document(item.itemId)
        ref.delete { (error) in
            completion(error)
        }
        
    }
    
    static func updateItemInBackground(item: Item, completion: @escaping (_ error: Error?) -> Void ) {
        
        let ref = reference(.Item).document(item.itemId)
        ref.setData(getItemDict(from: item)) { (error) in
            completion(error)
        }
    }
    
    static func deleteItemBackground(list: List, completion: @escaping (_ error: Error?) -> Void ) {
        
        reference(.Item).whereField(kLIST_ID, isEqualTo: list.listId).getDocuments { (snapshot, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {
                print("query snapshot is nil")
                return
            }
            if !snapshot.isEmpty {
                for doc in snapshot.documents {
                    doc.reference.delete(completion: { (error) in
                        completion(error)
                    })
                }
            } else {
                print("quary snapshot is empty")
            }
            
            
        }
        

        
    }
    
    
}
