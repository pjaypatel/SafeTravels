//
//  RegisterViewController.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 8/8/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checkUsernameAvailable(username: String) -> Bool {
        var retVal = false
        let docRef = db.collection(K.FStore.usersCollection.name).document(username)
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    print("Document data: \(document.data())")
                    let alertController = UIAlertController(title: "Username Taken", message:
                        "Please choose a different username", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    retVal = false
                } else {
                    print("Document does not exist")
                    retVal = true
                }
            }
        }
        return retVal
    }
    
    @IBAction func registerBtnClicked(_ sender: Any) {
        
        if let name = nameField.text,
            let email = emailField.text,
            let phone = phoneField.text,
            let username = usernameField.text,
            let password = passwordField.text {
            
            let newUser = SafeUser(uname: username, name: name, email: email, phone: phone, password: password)
            newUser.writeUser()
        }
        
    }
}
