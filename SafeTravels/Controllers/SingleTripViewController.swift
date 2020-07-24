//
//  SingleTripViewController.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 7/24/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SingleTripViewController: UIViewController {
    
    @IBOutlet weak var destinationLabel: UILabel?
    @IBOutlet weak var passengersLabel: UILabel?
    @IBOutlet weak var mapView: MKMapView?
    
    var trip : Trip?
    let locationManager = CLLocationManager()
    private var currentPlace: CLPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        setupLocationManager()
        updateFields()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func updateFields() {
        if let trip = trip {
            print("host: \(trip.host)")
            print("dest: \(trip.destination)")
            print("passengers: \(trip.stringifyPassengers())")
            destinationLabel?.text = "Destination: \(trip.destination)"
            passengersLabel?.text = "Passengers: \(trip.stringifyPassengers())"
        } else {
            print("trip doesn't have appropriate values????")
        }
    }
    
    
    @IBAction func startBtnClicked(_ sender: Any) {
        print("START!")
    }
    
}

extension SingleTripViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView?.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
}
