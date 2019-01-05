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

    // MARK: - Helper Functions
    func bindData(list: List) {
        self.nameLabel.text = list.name
        self.priorityLabel.text = list.priority
        self.numberOfItemLabel.text = "1"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: list.createdAt)
        self.dateLabel.text = dateString
    }

}
