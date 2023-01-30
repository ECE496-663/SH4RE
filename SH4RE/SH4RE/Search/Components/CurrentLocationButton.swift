//
//  CurrentLocationButton.swift
//  SH4RE
//
//  Created by Americo on 2023-01-30.
//

import SwiftUI






// Code from https://www.hackingwithswift.com/quick-start/swiftui/how-to-read-the-users-location-using-locationbutton
// Probably need to change info.plst firt https://stackoverflow.com/questions/57681885/how-to-get-current-location-using-swiftui-without-viewcontrollers
//
//import CoreLocation
//import CoreLocationUI
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    let manager = CLLocationManager()
//
//    @Published var location: CLLocationCoordinate2D?
//
//    override init() {
//        super.init()
//        manager.delegate = self
//    }
//
//    func requestLocation() {
//        manager.requestLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        location = locations.first?.coordinate
//    }
//}
//
//struct CurrentLocationButton: View {
//    @StateObject var locationManager = LocationManager()
//
//    var body: some View {
//        VStack {
//                    if let location = locationManager.location {
//                        Text("Your location: \(location.latitude), \(location.longitude)")
//                    }
//
//                    LocationButton {
//                        locationManager.requestLocation()
//                    }
//                    .frame(height: 44)
//                    .padding()
//                }
//    }
//}
//
//struct CurrentLocationButton_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrentLocationButton()
//    }
//}
