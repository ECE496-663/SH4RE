//
//  ProfileView.swift
//  SH4RE
//
//  Created by March on 2023-03-22.
//

import SwiftUI

struct ProfileView: View {
    @Binding var uid:String
    @Binding var profilePicture:UIImage
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    @State private var name:String = "" // if not name
    @State private var numberOfStars:Float = 4.0
    @StateObject private var listingsView = ListingViewModel()
    
    private var profile: some View {
        VStack {
            Image(uiImage: profilePicture)
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: screenSize.width * 0.1, maxHeight: screenSize.height * 0.1)
            Text(name)
                .font(.body)
            StarsView(numberOfStars: numberOfStars)
        }
    }
    
    private var moreListings: some View {
        VStack (alignment: .leading) {
            Text(name + "'s Listings")
                .font(.title2.bold())
            if (listingsView.listings.isEmpty) {
                Text(name + " has no listings")
                    .font(.body)
                    .padding()
            }
            else {
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(listingsView.listings) { listing in
                            // If theres no image for a listing, just use the placeholder
                            let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                            NavigationLink(destination: {
                                ViewListingView(tabSelection: $tabSelection, listing: listing, chatLogViewModel: ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: listing.title))).environmentObject(currentUser)
                            }, label: {
                                ProductCard(favouritesModel: FavouritesModel(), listing: listing, image: productImage)
                            })
                        }
                    }
                }
            }
        }
        .frame(width: screenSize.width)
        .padding(.leading)
    }
    
    private var reviews: some View {
        VStack (alignment: .leading) {
            Text(name + "'s Reviews")
                .font(.title2.bold())
        }
        .frame(width: screenSize.width)
    }
    
    var body: some View {
        ZStack (alignment: .top) {
            Color("BackgroundGrey").ignoresSafeArea()
            VStack {
                profile
                    .padding()
                moreListings
                    .padding()
                reviews
                    .padding()
            }
        }
        .onAppear() {
            getUserName(uid: uid, completion: { result in
                name = result // if not name
            })
            
            fetchUsersListings(uid: uid, completion: { listings in
                self.listingsView.listings = listings
                self.listingsView.fetchProductMainImage( completion: { success in
                    if !success {
                        print("Failed to load images")
                    }
                })
            })
            
            getUserRating(uid: uid, completion: { rating in
                numberOfStars = rating
            })
        }
    }
}
