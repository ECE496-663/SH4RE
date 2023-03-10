//
//  MapView.swift
//  SH4RE
//
//  Created by February on 2023-03-09.
//

import SwiftUI
import CoreLocation
import GoogleMaps

struct MapView2: View {
    private let zoom: Float = 15.0
        
    func makeUIView() -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView) {
        
    }
    func forwardGeocoding(address: String) {
        print("here")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print("Failed to retrieve location")
                return
            }
            
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                print("\nlat: \(coordinate.latitude), long: \(coordinate.longitude)")
            }
            else
            {
                print("No Matching Location Found")
            }
        })
    }
    var body: some View {
        
        Button(action: {
            print("here")
        }) {
            Text("Test")
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView2()
    }
}
