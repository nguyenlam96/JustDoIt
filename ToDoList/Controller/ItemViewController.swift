//
//  ItemViewController.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/5/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class ItemViewController: UIViewController {
    
    // MARK: - Properties
    var theList: List?
    var allItems: [Item] = []
    var isSwitchOn = true
    var highList: [Item] = []
    var lowList: [Item] = []
    // MARK: - IBOutlet
    @IBOutlet weak var filterPrioritySegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressHUD.dismiss()
        firstSetup()
        loadAllItems()
    }
    deinit {
        print("\(#file) is deinitialized")
    }
    
    // MARK: - Setup
    func firstSetup () {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        self.title = self.theList?.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        
    }
    
    
    func loadAllItems() {
        //let currentUserId = FirebaseUser.currentUserId
        let currentListId = theList!.listId
        reference(.Item).whereField(kLIST_ID, isEqualTo: currentListId).order(by: kCREATE_AT, descending: true).getDocuments {
            [unowned self](snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError("Fail to load data")
                print(error!.localizedDescription)
                return
            } else {
                guard let snapshot = snapshot else {
                    return
                }
                if !snapshot.isEmpty {
                    for item in snapshot.documents {
                        let itemDict = item.data()
                        let item = Item.init(from: itemDict)
                        self.allItems.append(item)
                        
                    }
                    self.allItems.sort(by: { (item1, item2) -> Bool in
                        item1.createdAt < item2.createdAt
                    })
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    // MARK: - IBAction
    @IBAction func filterPrioritySegmentDidChangeValue(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        switch sender.selectedSegmentIndex {
        case 0:
            filterItem(by: Priority.High)
        case 1:
            filterItem(by: Priority.Low)
        case 2:
            filterItem(by: Priority.All)
        default:
            break
        }
    }
    
    func filterItem(by priority: Priority) {
        
        switch priority {
        case .High:
            self.highList = self.allItems.filter({ (item) -> Bool in
                return item.priority == priority.rawValue
            })
            self.tableView.reloadData()
        case .Low:
            self.lowList = self.allItems.filter({ (item) -> Bool in
                return item.priority == priority.rawValue
            })
            self.tableView.reloadData()
        case .All:
            tableView.reloadData()
        }
    }

    
    @objc func addButtonPressed() {
        
        let ac = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { [unowned self] (action) in
            
            let itemContent = ac.textFields![0].text
            if itemContent == "" {
                return
            } else {
                var itemPriority = getPriority(.High)
                // check switch
                if !self.isSwitchOn {
                    itemPriority = getPriority(.Low)
                    // reset value of switch
                    self.isSwitchOn = true
                }
                // create Item
                let newItem = Item(itemId: UUID().uuidString,
                                   createdAt: Date(),
                                   content: itemContent!,
                                   isDone: false,
                                   listId: self.theList!.listId,
                                   priority: itemPriority,
                                   userId: FirebaseUser.currentUserId)
                
                // save to firestore
                Item.saveItemInBackground(item: newItem, completion: { [unowned self](error) in
                    if error != nil {
                        ProgressHUD.showError("Fail to save new item to FireStore")
                    } else {
                        self.allItems.append(newItem)
                        print(self.allItems[self.allItems.count - 1])
                        self.tableView.reloadData()
                        ProgressHUD.showSuccess()
                    }
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            return
        }
        ac.addTextField { (textfield) in
            textfield.placeholder = "item's name"
        }
        ac.view.addSubview(createSwichLabel())
        ac.view.addSubview(createSwitch())
        ac.addAction(doneAction)
        ac.addAction(cancelAction)
        
        self.present(ac, animated: true)
        
    }
    
    // MARK: - Helper Functions
    
    
    
    // MARK: - Creat Switch
    func createSwitch() -> UISwitch {
        let switchControl = UISwitch(frame: CGRect(x: 120, y: 5, width: 0, height: 0))
        switchControl.isOn = true
        switchControl.setOn(true, animated: true)
        switchControl.addTarget(self, action: #selector(switchValueDidChange(sender:)), for: UIControl.Event.valueChanged)
        return switchControl
    }
    @objc func switchValueDidChange(sender: UISwitch!) {
        self.isSwitchOn = sender.isOn
    }
    func createSwichLabel() -> UILabel {
        let switchLabel = UILabel(frame: CGRect(x: 20, y: 14, width: 100, height: 17))
        switchLabel.text = "High priority"
        return switchLabel
    }
    
}

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch filterPrioritySegment.selectedSegmentIndex {
        case 0:
            return self.highList.count
        case 1:
            return self.lowList.count
        case 2:
            return self.allItems.count
        default:
            return self.allItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        let item: Item
        switch filterPrioritySegment.selectedSegmentIndex {
        case 0:
            item = self.highList[indexPath.row]
        case 1:
            item = self.lowList[indexPath.row]
        case 2:
            item = self.allItems[indexPath.row]
        default:
            item = self.allItems[indexPath.row]
        }

        let cellView = UIView()
        cellView.alpha = 0.3
        cellView.backgroundColor = (item.isDone) ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.backgroundView = cellView
        cell.accessoryType = (item.isDone) ? .checkmark : .none
        cell.bindData(with: item)
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        var updateItem: Item
        switch filterPrioritySegment.selectedSegmentIndex {
        case 0:
            updateItem = self.highList[indexPath.row]
            self.highList[indexPath.row].isDone = !self.highList[indexPath.row].isDone
            // update item in allitems
            let index = self.allItems.firstIndex(where: {$0.itemId == updateItem.itemId})
            if let index = index  {
                self.allItems[index].isDone = !self.allItems[index].isDone
            }
            
        case 1:
            updateItem = self.lowList[indexPath.row]
            self.lowList[indexPath.row].isDone = !self.lowList[indexPath.row].isDone
            // update item in allItems
            let index = self.allItems.firstIndex(where: {$0.itemId == updateItem.itemId})
            if let index = index  {
                self.allItems[index].isDone = !self.allItems[index].isDone
            }
        case 2:
            updateItem = self.allItems[indexPath.row]
            self.allItems[indexPath.row].isDone = !self.allItems[indexPath.row].isDone
        default:
            updateItem = self.allItems[indexPath.row]
            self.allItems[indexPath.row].isDone = !self.allItems[indexPath.row].isDone
        }
        // update isDone
        //var item = (indexPath.section == 0 ) ? self.highList[indexPath.row] : self.lowList[indexPath.row]
        updateItem.isDone = !updateItem.isDone
        Item.updateItemInBackground(item: updateItem) { (error) in
            if (error != nil) {
                ProgressHUD.showError("Fail to update Item")
            }
        }
        self.tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let ac = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self](action) in
                let item = self.allItems[indexPath.row]
                Item.deleteItemBackground(item: item) { [unowned self](error) in
                    if error != nil {
                        ProgressHUD.showError("Fail to delete \(item.content)")
                    } else {
                        self.allItems.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                return
            }
            
            ac.addAction(deleteAction)
            ac.addAction(cancelAction)
            self.present(ac, animated: true)
        }
        
    }
    
    
   
    
    
    
    
}
