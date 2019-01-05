//
//  ListViewController.swift
//  ToDoList
//
//  Created by Nguyen Lam on 1/4/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseFirestore
import FirebaseAuth

class ListViewController: UIViewController {
    
    // MARK: - Properties
    var allLists: [List] = []
    var isSwitchOn = true
    var highLists: [List] = []
    var lowLists: [List] = []
    // MARK: - IBOutlet

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewLifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstSetup()
        loadAllLists()
    }
    deinit {
        print("\(#file) is deinitialized")
    }
    // MARK: - Setup
    func firstSetup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }
    
    func loadAllLists() {
        let currentUserId = FirebaseUser.currentUserId
        reference(.List).whereField(kUSER_ID, isEqualTo: currentUserId).order(by: kCREATE_AT, descending: true).getDocuments {
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
                        let listDict = item.data()
                        let list = List.init(from: listDict)
                        (list.priority == getPriority(.High)) ? self.highLists.append(list) : self.lowLists.append(list)
                        //self.allLists.append(list)
                        self.tableView.reloadData()
                    }
                    // order list by priority and time
                    
                    
                }
            }
            
        }
        
    }
    
    // MARK: - IBAction
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "", message: "", preferredStyle: .alert)

        let doneAction = UIAlertAction(title: "Done", style: .default) { [unowned self] (action) in
            
            let listName = ac.textFields![0].text
            if listName == "" {
                return
            } else {
                var listPriority = getPriority(.High)
                // check switch
                if !self.isSwitchOn {
                    listPriority = getPriority(.Low)
                    self.isSwitchOn = true
                }
                let newList = List( listId: UUID().uuidString,
                                    createAt: Date(),
                                    name: listName!,
                                    priority: listPriority,
                                    userId: FirebaseUser.currentUserId)
                
                
                // save to firestore
                List.saveListInBackground(list: newList, completion: { [unowned self](error) in
                    if (error != nil ) {
                        ProgressHUD.showError("Fail to save list to FireStore")
                    } else {
                        //self.allLists.append(newList)
                        (newList.priority == getPriority(.High)) ? self.highLists.insert(newList, at: 0) : self.lowLists.insert(newList, at: 0)
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
            textfield.placeholder = "list's name"
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
        print("Switch value: \(sender.isOn)")
    }
    func createSwichLabel() -> UILabel {
        let switchLabel = UILabel(frame: CGRect(x: 20, y: 14, width: 100, height: 17))
        switchLabel.text = "High priority"
        return switchLabel
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "ShowItemSegue" {
            if let itemVC = segue.destination as? ItemViewController {
                let tappedIndex = self.tableView.indexPathForSelectedRow!
                let theList = (tappedIndex.section == 0) ? self.highLists[tappedIndex.row] : self.lowLists[tappedIndex.row]
                //let theList = self.allLists[self.tableView.indexPathForSelectedRow!.row]
                itemVC.theList = theList
            }
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return highLists.count
        } else {
            return lowLists.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableViewCell

        let list = (indexPath.section == 0) ? highLists[indexPath.row] : lowLists[indexPath.row]
        //let list = allLists[indexPath.row]
        cell.bindData(with: list)
        
        return cell
    }
    
    // MARK: - TableView Delegate
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
               // let list = self.allLists[indexPath.row]
                let list = (indexPath.section == 0) ? self.highLists[indexPath.row] : self.lowLists[indexPath.row]
                // delete the list
                List.deleteItemBackground(list: list) { [unowned self](error) in
                    if error != nil {
                        ProgressHUD.showError("Fail to delete \(list.name)")
                    } else {
                        (indexPath.section == 0) ? self.highLists.remove(at: indexPath.row) : self.lowLists.remove(at: indexPath.row)
                        //self.allLists.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                }
                // delete all items in this list
                Item.deleteItemBackground(list: list, completion: { (error) in
                    if error != nil {
                        ProgressHUD.showError("Fail to delete Items in this list")
                        print(error!.localizedDescription)
                    }
                })
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                return
            }
            
            ac.addAction(deleteAction)
            ac.addAction(cancelAction)
            self.present(ac, animated: true)
        }
        
    }// commit editing end here
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowItemSegue", sender: self)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
