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
    case Low
    case All
}
func getPriority(_ priority: Priority) -> String {
    return priority.rawValue
}
