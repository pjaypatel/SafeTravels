//
//  SecondViewController.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 7/13/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TripsViewController: UITableViewController {

    let db = Firestore.firestore()
    var trips: [Trip] = []
    
    @IBOutlet var tripsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripsTable.delegate = self
        tripsTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let user = Auth.auth().currentUser {
            print(user.uid)
            buildTripsArray(from: user)
            tripsTable.reloadData()
        } else {
            print("Not logged in!")
        }
    }
    
    
    func buildTripsArray(from user: User) {
        trips = []
        let docRef = db.collection(K.FStore.tripsCollection.name).document(user.uid).collection(K.FStore.tripsCollection.userSpecific)
        
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.internalizeTrip(from: document)
                }
            }
        }
    }
    
    func internalizeTrip(from document: DocumentSnapshot) {
        let trip = Trip()
        trip.setTripFields(from: document)
        trip.buildPassengersArray(from: document) { () in
            self.trips.append(trip)
            self.tripsTable.reloadData()
        }
    }
    
    func commaSeparatedPassengers(trip: Trip) -> String {
        var str = ""
        for passengerName in trip.passengers {
            str.append("\(passengerName) ")
        }
        return str
    }

}

//MARK: table view delegate methods
extension TripsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "ViewTripCell")
        cell.textLabel?.text = "\(trips[indexPath.row].destination)"
        cell.detailTextLabel?.text = "Passengers: \(commaSeparatedPassengers(trip: trips[indexPath.row]))"
        cell.imageView?.image = UIImage(systemName: "play.circle")
        return cell
    }
    
}

