//
//  ListReferences.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum Reference: String {
    
    case User
    case Item
    case List
    
}

func reference(_ collectionRef: Reference) -> CollectionReference {
    return Firestore.firestore().collection(collectionRef.rawValue)
}
