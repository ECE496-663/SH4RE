//
//  MapView.swift
//  SH4RE
//
//  Created by Wasif Butt on 2023-03-09.
//
import GoogleMaps
import SwiftUI

/// The wrapper for `GMSMapView` so it can be used in SwiftUI
struct MapView: UIViewRepresentable {
    let listingsView : ListingViewModel
    
    private let mapID = GMSMapID(identifier: "6f8247d8ed876f54")
    private let gmsMapView = GMSMapView(frame: .zero, mapID: GMSMapID(identifier: "6f8247d8ed876f54"), camera: GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D(latitude: 0, longitude: 0), zoom: 10))
    private let defaultZoomLevel: Float = 4
    @State private var lat = 0.0
    @State private var lon = 0.0

    func forwardGeocoding(address: String) {
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
                lat = coordinate.latitude
                lon = coordinate.longitude
            }
            else
            {
                print("No Matching Location Found")
            }
        })
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        print("in func a")
        let location = CLLocationCoordinate2D(latitude: 43.660240, longitude: -79.370132)
        gmsMapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: 14)
        gmsMapView.delegate = context.coordinator
        gmsMapView.isUserInteractionEnabled = true
        gmsMapView.isMultipleTouchEnabled = true
        gmsMapView.settings.zoomGestures = true
        forwardGeocoding(address: "M5A2T6")
        print(listingsView.listings)
        for listing in listingsView.listings {
            print("here")
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(listing.address, completionHandler: { (placemarks, error) in
                print(listing.address)
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
                    let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let marker = GMSMarker(position: position)
                    marker.icon = GMSMarker.markerImage(with: UIColor(Color.primaryDark))
//                    marker.setValue(String(listing.id), forKeyPath: "ID")
//                    marker.setValue(String(listing.title), forKeyPath: "title")
//                    marker.setValue(String(listing.price), forKeyPath: "price")
                    marker.userData = listing
                    marker.map = gmsMapView
                }
                else
                {
                    print("No Matching Location Found")
                }
            })
            

        }
        return gmsMapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {

    }

    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(self)
    }


    final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
        var mapView: MapView

        init(_ mapView: MapView) {
          self.mapView = mapView
            print("in func b")
        }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            print("in func c")
        //      let marker = GMSMarker(position: coordinate)
        //      self.mapView.polygonPath.append(marker)
        }

        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            print("in func d")
        }
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
             print("Marker tapped")
//            mapView.selectedMarker = marker
//            listingsView
//            ViewListingView(tabSelection: .constant(2), listing:listing).environmentObject(CurrentUser())
             return false
        }
        
        @objc func buttonClicked(sender: UIButton!) {
            print("Button Clicked")
        }
        
        func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
            print("show window")
            let listing:Listing = marker.userData as! Listing
            print(listing.title)

            let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
            view.isUserInteractionEnabled = true
            view.backgroundColor = UIColor.white
            view.layer.borderColor = Color.primaryBase.cgColor
            view.layer.cornerRadius = 6
            
            let productImage = UIImage(named: "placeholder")!
            
            let listingButton = UIButton(type: .system)
            listingButton.frame = CGRectMake(5, 5, 90, 90);
            listingButton.setBackgroundImage(productImage, for: .normal)
            listingButton.setTitle(listing.title, for: .normal)
            listingButton.addTarget(self, action:#selector(buttonClicked), for: .touchUpInside)


//            let listingButton = NavigationLink(destination: {
//                ViewListingView(tabSelection: .constant(2), listing: listing).environmentObject(CurrentUser())
//            }, label: {
//                ProductCard(listing: listing, image: productImage)
//            })
            view.addSubview(listingButton)
//            let lbl1 = UILabel(frame: CGRect.init(x: 4, y: 85, width: listing.title.count + 16, height: 10))
//            lbl1.font = UIFont.systemFont(ofSize: 15)
//            lbl1.text = listing.title
//            view.addSubview(lbl1)
//
//            let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x + lbl1.frame.size.width + 3, y: lbl1.frame.origin.y, width: 16, height: 7))
//            lbl2.text = listing.price + "/day"
//            lbl2.font = UIFont.systemFont(ofSize: 12, weight: .light)
//            view.addSubview(lbl2)

            return view
        }

    }
}
