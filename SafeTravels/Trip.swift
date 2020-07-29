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
    var origin: String = ""
    var destination: String = ""
    var host: String = ""
    var passengers: [String] = []
    var time: NSDate = NSDate(timeIntervalSince1970: 0)
    
    func setTripFields(from document: DocumentSnapshot) {
        let data = document.data()
        if let destination = data?[K.FStore.tripDocument.destField] as? String,
            let host = data?[K.FStore.tripDocument.hostField] as? String,
            let time = data?[K.FStore.tripDocument.timeField] as? Timestamp {
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
        docRef.collection(K.FStore.tripDocument.passengers).getDocuments() { (querySnapshot, err) in
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
    
    func stringifyPassengers() -> String {
        var str = ""
        for passengerName in self.passengers {
            str.append("\(passengerName) ")
        }
        return str
    }
    
    func writeTrip() {
        let docRef = db.collection(K.FStore.tripsCollection.name).document(host).collection(K.FStore.tripsCollection.userSpecific).document()
        docRef.setData([
            K.FStore.tripDocument.destField: destination,
            K.FStore.tripDocument.hostField: host,
            K.FStore.tripDocument.timeField: time
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        for person in passengers {
            docRef.collection(K.FStore.tripDocument.passengers).document(person).setData([:]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    
}
