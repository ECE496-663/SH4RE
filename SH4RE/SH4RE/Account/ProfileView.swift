//
//  ProfileView.swift
//  SH4RE
//
//  Created by March on 2023-03-22.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ProfileView: View {
    @Binding var uid:String
    @Binding var profilePicture:UIImage
    @Binding var tabSelection: Int
    @ObservedObject var favouritesModel: FavouritesModel
    @EnvironmentObject var currentUser: CurrentUser
    @State private var name:String = "" // if not name
    @State private var numberOfStars:Float = 4.0
    @StateObject private var listingsView = ListingViewModel()
    @State var allReviews = [Review]()
    @State var chatLogViewModelDict : [String:ChatLogViewModel] = [:]
    
    private var profile: some View {
        VStack {
            Image(uiImage: profilePicture)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: screenSize.width * 0.3, height: screenSize.width * 0.3)
                .clipShape(Circle())
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
                                ViewListingView(tabSelection: $tabSelection, favouritesModel: favouritesModel, listing: listing, chatLogViewModel: chatLogViewModelDict[listing.id] ?? ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: listing.ownerName))).environmentObject(currentUser)
                            }, label: {
                                ProductCard(favouritesModel: favouritesModel, listing: listing, image: productImage)
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
            if (allReviews.count != 0) {
                VStack(alignment: .leading) {
                    ForEach(allReviews) { review in
                        ReviewView(reviewName: review.name, reviewRating: review.rating as Float, reviewDescription: review.description, reviewUID: review.uid, reviewProfilePic:review.profilePic)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(name + " has no reviews")
                    .font(.body)
                    .padding()
            }
        }
        .frame(width: screenSize.width)
        .padding(.leading)
    }
    
    var body: some View {
        ZStack (alignment: .top) {
            Color("BackgroundGrey").ignoresSafeArea()
            ScrollView (.vertical, showsIndicators: false) {
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
                    for listing in self.listingsView.listings{
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
                    }
                })
            })
            
            getUserRating(uid: uid, completion: { rating in
                numberOfStars = rating
            })
            
            getUserReviews(uid: uid, completion: { reviews in
                allReviews = reviews
            })
        }
    }
}
