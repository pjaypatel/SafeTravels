//
//  YourTripsViewController.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 7/13/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class YourTripsViewController: UITableViewController {

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
        self.tabBarController?.tabBar.isHidden = false
        if let user = Auth.auth().currentUser {
            print(user.uid)
            buildTripsArray(from: user)
            self.trips.sort(by: {$0.time.compare($1.time as Date) == .orderedDescending})
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
            self.trips.sort(by: {$0.time.compare($1.time as Date) == .orderedDescending})
            self.tripsTable.reloadData()
        }
    }

}

//MARK: table view delegate methods
extension YourTripsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "ViewTripCell")
        cell.textLabel?.text = "\(trips[indexPath.row].originName) -> \(trips[indexPath.row].destinationName)"
        cell.detailTextLabel?.text = "Passengers: \(trips[indexPath.row].stringifyPassengers())"
        cell.imageView?.image = UIImage(systemName: "play.circle")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = (storyboard?.instantiateViewController(withIdentifier: "SingleTripView")) as! SingleTripViewController
        vc.trip = trips[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

