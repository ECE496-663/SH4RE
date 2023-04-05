//
//  MyListingsView.swift
//  SH4RE
//
//  Created by March on 2023-03-19.
//

import SwiftUI

struct MyListingsView: View {
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    @StateObject private var listingsView = ListingViewModel()
    @ObservedObject var favouritesModel: FavouritesModel
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 15)]

    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            if (listingsView.listings.isEmpty) {
                Text("You have no active listings")
                    .font(.system(size: 16))
                    .foregroundColor(.primaryDark)
                    .frame(maxWidth: screenSize.width * 0.8)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            ScrollView {
                NavigationStack {
                    LazyVGrid(columns: columns, spacing: 15){
                        ForEach(listingsView.listings) { listing in
                            // If theres no image for a listing, just use the placeholder
                            let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                            NavigationLink(destination: {
                                ViewListingView(tabSelection: $tabSelection, favouritesModel: favouritesModel, listing: listing, chatLogViewModel: ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: ""))).environmentObject(currentUser)
                            }, label: {
                                ProductCard(favouritesModel: favouritesModel, listing: listing, image: productImage)
                            })
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("My Listings")
        .onAppear(){
            fetchUsersListings(uid: getCurrentUserUid(), completion: { listings in
                if (listings.isEmpty) {
                    self.listingsView.listings.removeAll()
                    return
                }
                self.listingsView.listings = listings
                self.listingsView.fetchProductMainImage( completion: { success in
                    if !success {
                        print("Failed to load images")
                    }
                })
            })
        }
    }
}

struct MyListingsView_Previews: PreviewProvider {
    static var previews: some View {
        MyListingsView(tabSelection: .constant(5), favouritesModel: FavouritesModel())
            .environmentObject(CurrentUser())
    }
}
