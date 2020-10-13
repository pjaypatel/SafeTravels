//
//  FirstViewController.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 7/13/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FeedViewController: UITableViewController {
    
    @IBOutlet var feedTable: UITableView!

    let db = Firestore.firestore()
    var trips : [Trip] = []
    var following: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedTable.delegate = self
        feedTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.trips = []
        refreshData()
    }
    
    func refreshData() {
        if let user = Auth.auth().currentUser {
            print(user.uid)
            buildFollowingArray(from: user) { () in
                for person in self.following {
                    self.buildTripsArray(from: person) { () in
                        print("finished building trips for \(person)")
                    }
                }
                //TODO: update this so it runs on completion handler at the correct time. currently not sorting properly
                self.trips.sort(by: {$0.time.compare($1.time as Date) == .orderedAscending})
                self.feedTable.reloadData()
            }
        } else {
            print("No user is logged in!")
        }
    }
    
    
    func buildTripsArray(from uid: String, completion: @escaping () -> Void) {
        self.trips = []
        let docRef = db.collection(K.FStore.tripsCollection.name).document(uid).collection(K.FStore.tripsCollection.userSpecific)
        print("building trips....")
        
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion()
            } else {
                for document in querySnapshot!.documents {
                    self.internalizeTrip(from: document)
                }
                completion()
            }
        }
    }
    
    func buildFollowingArray(from user: User, completion: @escaping () -> Void) {
        following = []
        let docRef = db.collection(K.FStore.followingCollection.name).document(user.uid).collection(K.FStore.followingCollection.userSpecific)
        
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion()
            } else {
                for document in querySnapshot!.documents {
                    self.following.append(document.documentID)
                }
                completion()
            }
        }
    }
    
    func internalizeTrip(from document: DocumentSnapshot) {
        let trip = Trip()
        trip.setTripFields(from: document)
        trip.buildPassengersArray(from: document) { () in
            self.trips.append(trip)
            self.feedTable.reloadData()
        }
    }
}

// MARK: table view methods
extension FeedViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trip = trips[indexPath.row]
        let time = DateFormatter.localizedString(from: trip.time as Date, dateStyle: .short, timeStyle: .short)
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "TripFeedCell")
        cell.textLabel?.text = "\(trip.host) made it to \(trip.destinationName) at \(time)"
        cell.detailTextLabel?.text = "Passengers: \(trip.passengers)"
        cell.imageView?.image = UIImage(systemName: "play.circle")
        return cell
    }
}
