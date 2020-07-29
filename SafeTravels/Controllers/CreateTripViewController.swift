//
//  ViewController.swift
//  CleanSlate
//
//  Created by Pranay Jay Patel on 5/7/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

class CreateTripViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var currentPlace: CLPlacemark?
    private let completer = MKLocalSearchCompleter()
    private var editingTextField: UITextField?
    private var currentRegion: MKCoordinateRegion?
    
    var newTrip = Trip()

    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var usersView: UITableView!
    
    var userSearchTable : UserSearchTable?
    
    var passengers : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attemptLocationAccess()
        newTrip = Trip()
        usersView.dataSource = self
        usersView.delegate = self
        originTextField.delegate = self
        originTextField.addTarget(self, action: #selector(updateSuggestion(_:)), for: .editingChanged)
        destinationTextField.delegate = self
        destinationTextField.addTarget(self, action: #selector(updateSuggestion(_:)), for: .editingChanged)
        completer.delegate = self
        userSearchTable = storyboard!.instantiateViewController(identifier: "UserSearchTable")
        userSearchTable?.customDelegateForDataReturn = self
    }
    
    @objc private func updateSuggestion(_ field: UITextField) {
        if field == originTextField && currentPlace != nil {
          currentPlace = nil
          field.text = ""
        }
        editingTextField = field
        guard let query = field.text else {
//          hideSuggestionView(animated: true)

          if completer.isSearching {
            completer.cancel()
          }
          return
        }
        completer.queryFragment = query
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
        newTrip.passengers = passengers
        newTrip.time = NSDate()
        newTrip.writeTrip()
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        return
    }
}

//MARK: MKLocalSearchCompleter handling
extension CreateTripViewController : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        for result in completer.results {
            print("result: \(result)")
        }
        if let firstResult = completer.results.first {
            print("firstResult.title = \(firstResult.title)")
//            showSuggestion(firstResult.title)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error with autocompleter: \(error)")
    }
}

//MARK: TextField Delegate
extension CreateTripViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("update search results!")
    }
    
}

extension CreateTripViewController : CLLocationManagerDelegate {
    func attemptLocationAccess() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("requesting location")
            locationManager.requestLocation()
            print(locationManager.location.debugDescription)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
        
        let commonDelta: CLLocationDegrees = 25/111
        let span = MKCoordinateSpan(latitudeDelta: commonDelta, longitudeDelta: commonDelta)
        let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)
        currentRegion = region
        completer.region = region
        
        print(locations.first.debugDescription)
        CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
            guard let firstPlace = places?.first,
                self.originTextField.text == ""
            else {return}
            self.currentPlace = firstPlace
            print("changing originTextField to \(firstPlace.name ?? "unnamed")")
            self.originTextField.text = firstPlace.name
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error)")
    }
    
}

//MARK: Passengers handling
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
