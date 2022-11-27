//
//  SearchView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//
import SwiftUI
import FirebaseStorage

//Database stuff to know
//listingView.listings if a list of Listing structs defined in ListingViewModel
//from listing struct you can get id, title, description and cost
//listingView.image_dict is a dict of <String:UIImage> that maps listing ids to images
//needed this separate for now because of sychronous queries

struct SearchView: View {
    let screenSize: CGRect = UIScreen.main.bounds

    @ObservedObject private var listingsView = ListingViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundGrey").ignoresSafeArea()
                List(listingsView.listings) { listing in
                    VStack(alignment: .leading){
                        NavigationLink(destination: ViewListingView(listing : listing, image: listingsView.image_dict[listing.id] ?? UIImage())) {
                            Text(listing.title)
                        }
                    }
                }
            }
        }
        .onAppear(){
            self.listingsView.fetchListings(completion: { success in
                if success{
                    self.listingsView.fetchProductImages(completion: { success in
                        if !success {
                            print("Failed to load images")
                        }
                    })
                } else {
                    print("Failed to query database")
                }
                
            })
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
