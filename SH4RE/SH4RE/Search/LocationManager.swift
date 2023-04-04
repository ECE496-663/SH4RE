//
//  LocationManager.swift
//  AutocompleteSearch
//
//  Created by Mohammad Azam on 12/13/21.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var locationDistance: CLLocationDistance = 3000
    @Published var location: CLLocation = CLLocation(latitude: 43.66, longitude: -79.39)

    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.66, longitude: -79.39), latitudinalMeters: 3000, longitudinalMeters: 3000)
    
    override init() {
        super.init()
        manager.activityType = .automotiveNavigation
        manager.delegate = self
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func updateDistance(distance: Double) {
        locationDistance = distance * 1000
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude)), latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
    }
    
    func updateLocation(lat: Double, lon: Double) {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = CLLocation(latitude: (locations.first?.coordinate.latitude)!, longitude: (locations.first?.coordinate.longitude)!)
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude)), latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
        guard let local_location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: local_location.coordinate, latitudinalMeters: self.locationDistance, longitudinalMeters: self.locationDistance)
        }
        
        print("\(local_location)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
