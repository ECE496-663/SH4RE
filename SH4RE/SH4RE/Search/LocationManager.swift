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
    private static let locationDistance: CLLocationDistance = 10000
    @Published var location: CLLocation?

    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.66, longitude: -79.37), latitudinalMeters: LocationManager.locationDistance, longitudinalMeters: LocationManager.locationDistance)
    
    override init() {
        super.init()
        manager.activityType = .automotiveNavigation
        manager.delegate = self
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = CLLocation(latitude: (locations.first?.coordinate.latitude)!, longitude: (locations.first?.coordinate.longitude)!)
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!), latitudinalMeters: LocationManager.locationDistance, longitudinalMeters: LocationManager.locationDistance)
        guard let local_location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: local_location.coordinate, latitudinalMeters: Self.locationDistance, longitudinalMeters: Self.locationDistance)
        }
        
        print("\(local_location)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
