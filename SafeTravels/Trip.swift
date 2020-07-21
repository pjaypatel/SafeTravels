//
//  Trip.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 7/14/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import Foundation
import FirebaseFirestore

let db = Firestore.firestore()

class Trip {
    var destination: String = ""
    var host: String = ""
    var passengers: [String] = []
    var time: NSDate = NSDate(timeIntervalSince1970: 0)
    
    func setTripFields(from document: DocumentSnapshot) {
        let data = document.data()
        if let destination = data?["destination"] as? String,
            let host = data?["host"] as? String,
            let time = data?["time"] as? Timestamp {
            print(destination)
            self.destination = destination
            self.host = host
            self.time = Date(timeIntervalSince1970: TimeInterval(time.seconds)) as NSDate
        } else {
            print("error processing data")
        }
    }
    
    func buildPassengersArray(from document: DocumentSnapshot, completion: @escaping () -> Void) {
        let docRef = document.reference
        docRef.collection("passengers").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion()
            } else {
                for document in querySnapshot!.documents {
                    self.passengers.append(document.documentID)
                }
                completion()
            }
        }
    }
    
    func writeTrip() {
        let docRef = db.collection("trips").document(host).collection("userTrips").document()
        docRef.setData([
            "destination": destination,
            "host": host,
            "time": time
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        for person in passengers {
            docRef.collection("passengers").document(person).setData([:]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    
}
