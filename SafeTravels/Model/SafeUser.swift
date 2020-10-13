//
//  SafeUser.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 8/8/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import Foundation
import FirebaseFirestore

class SafeUser {
    var username = ""
    var name = ""
    var email = ""
    var phone = ""
    var password = ""
    
    init(uname: String, name: String, email: String, phone: String, password: String) {
        self.username = uname
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
    }
    
    func writeUser() {
        let docRef = db.collection(K.FStore.usersCollection.name).document(self.username)
        docRef.setData([
            K.FStore.userDocument.name : self.name,
            K.FStore.userDocument.email : self.email,
            K.FStore.userDocument.phone : self.phone,
            K.FStore.userDocument.password : self.password,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
