//
//  SearchView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import FirebaseStorage

struct SearchView: View {
    let screenSize: CGRect = UIScreen.main.bounds

    @ObservedObject private var listingsView = ListingViewModel()
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color("BackgroundGrey").ignoresSafeArea()
                List(listingsView.listings) { listing in
                    VStack(alignment: .leading){
                        NavigationLink(destination: ViewListingView(listing : listing)) {
                            Text(listing.title)
                        }
                    }
                    
                }
            }
        }
        .onAppear(){
            self.listingsView.fetchListings()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
