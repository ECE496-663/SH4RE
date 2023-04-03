//
//  MapView.swift
//  SH4RE
//
//  Created by March on 2023-03-24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var userLat:Double
    @Binding var userLon:Double
    @Binding var distance:Int
    @Binding var region:MKCoordinateRegion
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onAppear {
                MKMapView.appearance().preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
                MKMapView.appearance().pointOfInterestFilter = .some(MKPointOfInterestFilter.excludingAll)
            }
    }
}
