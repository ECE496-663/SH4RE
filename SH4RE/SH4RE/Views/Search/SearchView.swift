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
    @Binding var tabSelection: Int
    @State private var searchQuery: String = ""
    
    @ObservedObject private var listingsView = ListingViewModel()
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20){
                    ForEach(listingsView.listings) { listing in
                        // If theres no image for a listing, just use the placeholder
                        let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                        NavigationLink(destination: {
                            ViewListingView(tabSelection: $tabSelection, listing: listing)
                        }, label: {
                            ProductCard(listing: listing, image: productImage)
                        })
                    }
                }.padding()
            }
            .background(Color("BackgroundGrey"))
            .toolbar {
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: screenSize.width * 0.9, height: 20)
                    .padding()
            }
        }
        .onAppear(){
            self.listingsView.fetchListings(completion: { success in
                if success{
                    self.listingsView.fetchProductMainImage( completion: { success in
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
        SearchView(tabSelection: .constant(1))
    }
}
