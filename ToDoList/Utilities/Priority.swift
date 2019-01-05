//
//  Priority.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation

enum  Priority: String {
    
    case High
    case Medium
    case Low
    
}
func getPriority(_ priority: Priority) -> String {
    return priority.rawValue
}
