//
//  UserSearchTable.swift
//  CleanSlate
//
//  Created by Pranay Jay Patel on 5/7/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol UserSearchCustomDelegate : class {
    func populateTripVC(with selectedUsers: Set<String>)
}

class UserSearchTable: UITableViewController {
    var users : [String] = []

    
    var selectedUsers = Set<String>()
    
    weak var customDelegateForDataReturn: UserSearchCustomDelegate?
    
    @IBOutlet var usersTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTable.dataSource = self
        usersTable.delegate = self
        
        if let user = Auth.auth().currentUser {
            print(user.uid)
            buildUsersArray(from: user) { () in
                self.usersTable.reloadData()
            }
        } else {
            print("No user is logged in!")
        }
    }
    
    func buildUsersArray(from user: User, completion: @escaping () -> Void) {
        let docRef = db.collection("following").document(user.uid).collection("userFollowing")
        
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion()
            } else {
                for document in querySnapshot!.documents {
                    print("friend: \(document.documentID) => \(document.data())")
                    self.users.append(document.documentID)
                }
                completion()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customDelegateForDataReturn?.populateTripVC(with: selectedUsers)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }

    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let curCell = tableView.cellForRow(at: indexPath)
        if curCell?.accessoryType == .checkmark {
            curCell?.accessoryType = .none
            selectedUsers.remove(users[indexPath.row])
        } else {
            curCell?.accessoryType = .checkmark
            selectedUsers.insert(users[indexPath.row])
        }
        tableView.reloadData()
    }
}
