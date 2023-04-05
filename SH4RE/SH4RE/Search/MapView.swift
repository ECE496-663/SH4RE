//
//  MapView.swift
//  SH4RE
//
//  Created by March on 2023-03-24.
//

import SwiftUI
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let listing: Listing
    let productImage: UIImage
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var tabSelection: Int
    @Binding var chatLogViewModelDict:[String:ChatLogViewModel]
    @EnvironmentObject var currentUser: CurrentUser
    @ObservedObject var favouritesModel: FavouritesModel
    @Binding var region:MKCoordinateRegion
    @ObservedObject var listingsView:ListingViewModel
    @State var listingPins:[MapLocation] = []
    @State private var selectedListing:MapLocation? = nil
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $region,
                annotationItems: listingPins,
                annotationContent: { pin in
                    MapAnnotation(
                        coordinate: pin.coordinate,
                        content: {
                            VStack {
                                Button(action: {
                                    selectedListing = pin
                                }) {
                                    Image(systemName: "mappin.circle.fill")
                                        .tint(Color.primaryDark)
                                }
                            }
                            .scaleEffect((selectedListing != nil && selectedListing!.name == pin.name) ? 2.5 : 1.5)
                        }
                    )
                }
            )
            .edgesIgnoringSafeArea([.bottom, .top])

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .tint(Color.primaryDark)
                }
            }
            .position(x: 0, y: 0)
            .padding(.leading, 50)
            .padding(.top, 20)
            .buttonStyle(secondaryButtonStyle(width: screenSize.width * 0.1))

        }
        .onAppear {
            MKMapView.appearance().preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
            MKMapView.appearance().pointOfInterestFilter = .some(MKPointOfInterestFilter.excludingAll)
            
            for listing in listingsView.listings {
                listingPins.append(MapLocation(name: listing.id, listing: listing, productImage: listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!, latitude: listing.address["lat"]!, longitude: listing.address["lon"]!))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if (selectedListing != nil) {
                NavigationLink(destination: {
                    ViewListingView(tabSelection: $tabSelection, favouritesModel: favouritesModel, listing: selectedListing!.listing, chatLogViewModel: chatLogViewModelDict[selectedListing!.name] ?? ChatLogViewModel(chatUser: ChatUser(id: selectedListing?.listing.id,uid: (selectedListing?.listing.uid)!, name: (selectedListing?.listing.ownerName)!))).environmentObject(currentUser)
                }, label: {
                    LandscapeProductCard(listing: selectedListing!.listing, image: selectedListing!.productImage)
                })
                .frame(alignment: .bottom)
                .padding(.bottom)
            }
        }
        .navigationBarHidden(true)
    }
}
