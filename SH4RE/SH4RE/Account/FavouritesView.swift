//
//  FavouritesView.swift
//  SH4RE
//
//  Created by March on 2023-03-19.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct FavouritesView: View {
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    @StateObject private var listingsView = ListingViewModel()
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 15)]
    @ObservedObject var favouritesModel: FavouritesModel
    @State var chatLogViewModelDict : [String:ChatLogViewModel] = [:]
    
    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            if (listingsView.listings.isEmpty) {
                Text("You have no listings in your favourties list")
                    .font(.system(size: 16))
                    .foregroundColor(.primaryDark)
                    .frame(maxWidth: screenSize.width * 0.8)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            ScrollView (showsIndicators: false) {
                NavigationStack {
                    LazyVGrid(columns: columns, spacing: 15){
                        ForEach(listingsView.listings) { listing in
                            // If theres no image for a listing, just use the placeholder
                            let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                            NavigationLink(destination: {
                                ViewListingView(tabSelection: $tabSelection, favouritesModel: favouritesModel, listing: listing, chatLogViewModel: chatLogViewModelDict[listing.id] ?? ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: listing.ownerName))).environmentObject(currentUser)
                            }, label: {
                                ProductCard(favouritesModel: favouritesModel, listing: listing, image: productImage)
                            })
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Favourites")
        .onAppear(){
            for listingID in favouritesModel.favourites {
                fetchSingleListing(lid: listingID, completion: { listing in
                    listingsView.listings.append(listing)
                    self.listingsView.fetchProductMainImage( completion: { success in
                        if !success {
                            print("Failed to load images")
                        }
                    })
                    Firestore.firestore().collection("User Info").document(listing.uid).getDocument() { (document, error) in
                        guard let document = document else{
                            return
                        }
                        self.chatLogViewModelDict[listing.id] = ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: listing.ownerName))
                        let data = document.data()!
                        let imagePath = data["pfp_path"] as? String ?? ""
                        
                        if(imagePath != ""){
                            let storageRef = Storage.storage().reference(withPath: imagePath)
                            storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
                                
                                if let error = error {
                                    //Error:
                                    print (error)
                                    
                                } else {
                                    guard let image = UIImage(data: data!) else{
                                        return
                                    }
                                    
                                    self.chatLogViewModelDict[listing.id]?.profilePic = image
                                    
                                }
                            }
                        }
                    }
                    
                })
                
            }
        }

    }
}
