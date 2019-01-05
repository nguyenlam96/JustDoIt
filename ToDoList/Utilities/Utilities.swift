//
//  Utilities.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation


private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    
    let formatter = DateFormatter()
    
    formatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    
    formatter.dateFormat = dateFormat
    
    return formatter
}
