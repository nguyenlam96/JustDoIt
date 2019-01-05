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
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
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
        reference(.List).whereField(kUSER_ID, isEqualTo: currentUserId).order(by: kCREATE_AT, descending: true).getDocuments { [unowned self](snapshot, error) in
            
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
                        self.allLists.append(list)
                        self.tableView.reloadData()
                    }
                }
            }
            
        }
        
    }
    
    // MARK: - IBAction
    @IBAction func newListButtonPressed(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Enter list name:", message: nil, preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { [unowned self] (action) in
            
            let listName = ac.textFields![0].text
            if listName == "" {
                return
            } else {
                // create new list
                let newList = List( listId: UUID().uuidString,
                                    createAt: Date(),
                                    name: listName!,
                                    priority: getPriority(.Low),
                                    userId: FirebaseUser.currentUserId)
                
                
                // save to firestore
                List.saveListInBackground(list: newList, completion: { (error) in
                    if (error != nil ) {
                        ProgressHUD.showError("Fail to save list to FireStore")
                    } else {
                        self.allLists.append(newList)
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
        
        ac.addAction(doneAction)
        ac.addAction(cancelAction)
        
        self.present(ac, animated: true)
        
    }
    
    // MARK: - Helper Functions
    
    // MARK: - Creat Switch
    func createSwitch() -> UISwitch {
        let switchControl = UISwitch(frame: CGRect(x: 200, y: 40, width: 0, height: 0))
        switchControl.isOn = false
        switchControl.setOn(true, animated: true)
        switchControl.addTarget(self, action: #selector(switchValueDidChange(sender:)), for: UIControl.Event.valueChanged)
        return switchControl
    }
    @objc func switchValueDidChange(sender: UISwitch!) {
        print("Switch value: \(sender.isOn)")
    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableViewCell
        
        let list = allLists[indexPath.row]
        cell.bindData(list: list)
        
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
                let list = self.allLists[indexPath.row]
                List.deleteItemBackground(list: list) { [unowned self](error) in
                    if error != nil {
                        ProgressHUD.showError("Fail to delete \(list.name)")
                    } else {
                        self.allLists.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [unowned self](action) in
                return
            }
            
            ac.addAction(deleteAction)
            ac.addAction(cancelAction)
            self.present(ac, animated: true)
        }
        
    }// commit editing end here
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
