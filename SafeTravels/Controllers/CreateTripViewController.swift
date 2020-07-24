//
//  ViewController.swift
//  CleanSlate
//
//  Created by Pranay Jay Patel on 5/7/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

class CreateTripViewController: UIViewController {
    
    var newTrip = Trip()

    @IBOutlet weak var destAddress: UILabel!
    @IBOutlet weak var usersView: UITableView!
    
    var userSearchTable : UserSearchTable?
    
    var passengers : [String] = []
    var addressString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTrip = Trip()
        usersView.dataSource = self
        usersView.delegate = self
        destAddress.text = addressString
        userSearchTable = storyboard!.instantiateViewController(identifier: "UserSearchTable")
        userSearchTable?.customDelegateForDataReturn = self
    }
    
    @IBAction func searchUsersPressed(_ sender: UIButton) {
        present(userSearchTable!, animated: true, completion: nil)
    }
    
    @IBAction func startTrip(_ sender: Any) {
        //TODO: need to handle the case of required fields not being filled in here
        if let uid = Auth.auth().currentUser?.uid {
            newTrip.host = uid
        } else {
            print("no user logged in!")
        }
        newTrip.destination = addressString
        newTrip.passengers = passengers
        newTrip.time = NSDate()
        newTrip.writeTrip()
        //TODO: save trip to firebase
        navigationController?.popToRootViewController(animated: true)
    }
}

extension CreateTripViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // do nothing
        return
    }
}

extension CreateTripViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        cell.textLabel?.text = passengers[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passengers.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension CreateTripViewController : UserSearchCustomDelegate {
    func populateTripVC(with selectedUsers: Set<String>) {
        // empty current array and write new selectedUsers to current users array
        passengers.removeAll()
        for user in selectedUsers {
            passengers.append(user)
        }
        usersView.reloadData()
    }
}
