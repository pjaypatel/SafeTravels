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
    var originName: String = ""
    var originLat: Double = 0.0
    var originLong: Double = 0.0
    var destinationLat: Double = 0.0
    var destinationLong: Double = 0.0
    var destinationName: String = ""
    var host: String = ""
    var passengers: [String] = []
    var time: NSDate = NSDate(timeIntervalSince1970: 0)
    
    func setTripFields(from document: DocumentSnapshot) {
        let data = document.data()

        if let originName = data?[K.FStore.tripDocument.originField] as? String,
            let originLat = data?[K.FStore.tripDocument.originLatField] as? Double,
            let originLong = data?[K.FStore.tripDocument.originLongField] as? Double,
            let destinationName = data?[K.FStore.tripDocument.destField] as? String,
            let destinationLat = data?[K.FStore.tripDocument.destLatField] as? Double,
            let destinationLong = data?[K.FStore.tripDocument.destLongField] as? Double,
            let host = data?[K.FStore.tripDocument.hostField] as? String,
            let time = data?[K.FStore.tripDocument.timeField] as? Timestamp {
            
            self.originName = originName
            self.originLat = originLat
            self.originLong = originLong
            self.destinationName = destinationName
            self.destinationLat = destinationLat
            self.destinationLong = destinationLong
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
            K.FStore.tripDocument.originField: originName,
            K.FStore.tripDocument.originLatField: originLat,
            K.FStore.tripDocument.originLongField: originLong,
            K.FStore.tripDocument.destField: destinationName,
            K.FStore.tripDocument.destLatField: destinationLat,
            K.FStore.tripDocument.destLongField: destinationLong,
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
    
    func getMapItem(lat: Double, long: Double) {
    }
    
    
}
