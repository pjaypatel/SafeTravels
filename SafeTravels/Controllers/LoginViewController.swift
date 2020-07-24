//
//  LoginViewController.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 7/14/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @IBAction func googleSignInPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Login Successful.")
                //This is where you should add the functionality of successful login
                //i.e. dismissing this view or push the home view controller etc
                self.registerUser(with: authResult!)
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
            }
        }
    }
    
    func registerUser(with authResult: AuthDataResult) {
        let db = Firestore.firestore()
        let docRef = db.collection(K.FStore.usersCollection.name).document(authResult.user.uid)
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists{
                    print("Document data: \(String(describing: document.data()))")
                    print("user has already been registered!")
                } else {
                    print("Document does not exist")
                    db.collection(K.FStore.usersCollection.name).document(authResult.user.uid).setData([
                        K.FStore.userDocument.name: authResult.user.displayName ?? authResult.user.uid,
                        K.FStore.userDocument.email: authResult.user.email ?? "",
                        K.FStore.userDocument.phone: authResult.user.phoneNumber ?? ""
                    ])
                }
            }
        }
    }
}
