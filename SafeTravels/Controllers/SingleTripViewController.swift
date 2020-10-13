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
    
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel?
    @IBOutlet weak var passengersLabel: UILabel?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tripStatusLabel: UILabel!
    
    var trip : Trip?
    var origin : MKMapItem?
    var destination : MKMapItem?
    var route : MKRoute?
    var directionsResponse : MKDirections.Response = MKDirections.Response()
    var currentRegion: MKCoordinateRegion?
    let locationManager = CLLocationManager()
    private var currentPlace: CLPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        mapView.delegate = self
        setupLocationManager()
        updateFields()
    }
    @IBAction func printLocationBtnClick(_ sender: UIButton) {
        if let location = locationManager.location {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.currentRegion = region
            print("Lat: \(region.center.latitude) Long: \(region.center.longitude)")
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    func updateFields() {
        if let trip = trip {
            print("host: \(trip.host)")
            print("dest: \(trip.destinationName)")
            print("passengers: \(trip.stringifyPassengers())")
            originLabel?.text = "Origin: \(trip.originName)"
            destinationLabel?.text = "Destination: \(trip.destinationName)"
            passengersLabel?.text = "Passengers: \(trip.stringifyPassengers())"
            setMapItem(latitude: trip.originLat, longitude: trip.originLong, isDestination: false)
            setMapItem(latitude: trip.destinationLat, longitude: trip.destinationLong, isDestination: true)
            if origin != nil && destination != nil {
                generateRoute()
            } else {
                print("Not ready yet!")
            }
            
            
        } else {
            print("trip doesn't have appropriate values????")
        }
    }
    
    @IBAction func startBtnClicked(_ sender: UIButton) {
        print("START!")
        sender.isHidden = true
        tripStatusLabel.isHidden = false
    }
    
}

//MARK: Map Item Handling
extension SingleTripViewController {
    func setMapItem(latitude: Double, longitude: Double, isDestination: Bool) {
        if let lat = CLLocationDegrees(exactly: latitude),
            let long = CLLocationDegrees(exactly: longitude) {
            let coords = CLLocationCoordinate2D(latitude: lat, longitude: long)
            if isDestination {
                self.destination = MKMapItem(placemark: MKPlacemark(coordinate: coords))
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude), radius: 200, identifier: "dest")
                region.notifyOnEntry = true
                locationManager.startMonitoring(for: region)
                print("Done with dest")
            } else {
                self.origin = MKMapItem(placemark: MKPlacemark(coordinate: coords))
                print("Done with origin")
            }
        }
    }
    
    func generateRoute() {
        let request : MKDirections.Request = MKDirections.Request()

        // source and destination are the relevant MKMapItems
        request.source = origin
        request.destination = destination

        // Specify the transportation type
        request.transportType = MKDirectionsTransportType.automobile

        // If you're open to getting more than one route,
        // requestsAlternateRoutes = true; else requestsAlternateRoutes = false;
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }

                return
            }

            let route = response.routes[0]

            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            var region = MKCoordinateRegion(route.polyline.boundingMapRect)
            var span = region.span
            span.latitudeDelta *= 1.2
            span.longitudeDelta *= 1.2
            region.span = span
            self.mapView.setRegion(region, animated: true)
        }

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
            self.currentRegion = region
            print("Lat: \(region.center.latitude) Long: \(region.center.longitude)")
        }
        if destination?.isCurrentLocation == true {
            print("Made it!")
            tripStatusLabel.text = "Made it!"
            tripStatusLabel.textColor = UIColor.green
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Made it!")
        tripStatusLabel.text = "Made it"
        tripStatusLabel.textColor = UIColor.green
    }
}

extension SingleTripViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
}
