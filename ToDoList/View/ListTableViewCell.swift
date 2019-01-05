//
//  ListTableViewCell.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var numberOfItemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func bindData(with list: List) {
        
        self.nameLabel.text = list.name
        self.priorityLabel.textColor = (list.priority == getPriority(.High) ) ? #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1) : #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        self.priorityLabel.text = (list.priority == getPriority(.High) ) ? "Urgent" : "Not urgent"
        //self.numberOfItemLabel.text = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: list.createdAt)
        self.dateLabel.text = dateString
    }

}
