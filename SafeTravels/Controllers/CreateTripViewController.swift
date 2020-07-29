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
import SearchTextField

class CreateTripViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var currentPlace: CLPlacemark?
    private let completer = MKLocalSearchCompleter()
    private var editingTextField: SearchTextField?
    private var currentRegion: MKCoordinateRegion?
    
    var newTrip = Trip()
    var passengers : [String] = []
    
    @IBOutlet weak var originTextField: SearchTextField!
    @IBOutlet weak var destinationTextField: SearchTextField!
    @IBOutlet weak var usersView: UITableView!
    
    var userSearchTable : UserSearchTable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attemptLocationAccess()
        newTrip = Trip()
        usersView.dataSource = self
        usersView.delegate = self
        configureSearchTextField(field: originTextField)
        configureSearchTextField(field: destinationTextField)
        completer.delegate = self
        userSearchTable = storyboard!.instantiateViewController(identifier: "UserSearchTable")
        userSearchTable?.customDelegateForDataReturn = self
    }
    
    func configureSearchTextField(field: SearchTextField) {
        field.delegate = self
        field.addTarget(self, action: #selector(updateSuggestion(_:)), for: .editingChanged)
        field.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            let completerResult = self.completer.results[itemPosition]
            print("item title: \(item.title)")
            print("completerResult title: \(completerResult.title)")
            field.text = item.title
        }
    }
    
    @objc private func updateSuggestion(_ field: UITextField) {
        if field == originTextField && currentPlace != nil {
          currentPlace = nil
          field.text = ""
        }
        if field is SearchTextField {
            editingTextField = field as? SearchTextField
        }
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
        let results = convertToSearchItems(from: completer.results)
        if let firstResult = completer.results.first {
            print("firstResult.title = \(firstResult.title)")
            editingTextField?.filterItems(results)
        }
    }
    
    func convertToSearchItems(from suggestions: [MKLocalSearchCompletion]) -> [SearchTextFieldItem] {
        var searchItems : [SearchTextFieldItem] = []
        for suggestion in suggestions {
            let item = SearchTextFieldItem(title: suggestion.title, subtitle: suggestion.subtitle)
            searchItems.append(item)
        }
        return searchItems
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
        if textField is SearchTextField {
            editingTextField = textField as? SearchTextField
        }
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
