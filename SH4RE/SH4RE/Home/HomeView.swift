//
//  HomeView.swift
//  SH4RE
//
//  Created by November on 2022-11-18.
//

import Foundation
import SwiftUI

//Remove once real listing is here
let empty_listing = Listing(id :"MNizNurWGrjm1sXNpl15", uid: "Cfr9BHVDUNSAL4xcm1mdOxjAuaG2", title:"", description: "Test Description", imagepath : ["path"], price: 10, category: "Camera", address: ["latitude": 43.66, "longitude": -79.37])

//This probably shouldnt go here but it will for now, allows for safe and easy bounds checking
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct HomeView: View {
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser : CurrentUser
    @ObservedObject var searchModel: SearchModel
    @ObservedObject var favouritesModel: FavouritesModel

    //Used to focus on the keyboard when the search icon is clicked
    @FocusState var isFocusOn: Bool
    let categories = getCategoriesAndImg()
    @State private var recentListings = [Listing]()
    @State private var recentListing1Image: UIImage = UIImage(named: "ProfilePhotoPlaceholder")!
    @State private var recentListing2Image: UIImage = UIImage(named: "ProfilePhotoPlaceholder")!
    @State private var chatLogViewModel1: ChatLogViewModel? = nil
    @State private var chatLogViewModel2: ChatLogViewModel? = nil

    fileprivate func homeSearchBar() -> some View {
        return TextField("What are you looking for?", text: $searchModel.searchQuery)
            .textFieldStyle(
                iconInputStyle(
                    button: Button(action:{
                        isFocusOn = true
                    }, label:{
                        Image(systemName: "magnifyingglass")
                    }),
                    colour: .gray,
                    clearFunc: searchModel.searchQuery == "" ? nil : {searchModel.searchQuery = ""}
                )
            )
            .focused($isFocusOn)
            .onSubmit {
                searchModel.searchReady = true
                tabSelection = 2
            }
    }
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                Color("BackgroundGrey").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 15) {
                    Text("Search")
                        .font(.title.bold())
                    homeSearchBar()
                    ScrollView (showsIndicators: false) {
                        //Body
                        VStack(alignment: .leading){
                            if(searchModel.recentSearchQueries.count > 1) {
                                //Recent Searches
                                VStack (alignment: .leading) {
                                    Text("Recent Searches")
                                        .font(.title2.bold())
                                    HStack {
                                        ForEach (searchModel.recentSearchQueries, id: \.self) { query in
                                            if (query != "") {
                                                Button(action: {
                                                    searchModel.searchQuery = query
                                                    searchModel.searchReady = true
                                                    tabSelection = 2
                                                }) {
                                                    RecentSearchCard(searchText: query)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            //Recent Posts
                            VStack (alignment: .leading) {
                                Text("Recent Posts")
                                    .font(.title2.bold())
                                HStack(){
                                    let listing1 = recentListings.count >= 1 ? recentListings[0] : empty_listing
                                    let listing2 = recentListings.count >= 2 ? recentListings[1] : empty_listing
                                    NavigationLink(destination: {
                                        ViewListingView(tabSelection: $tabSelection, favouritesModel: favouritesModel, listing: listing1, chatLogViewModel: chatLogViewModel1 ?? ChatLogViewModel(chatUser: ChatUser(id: listing1.uid, uid: listing1.uid, name: listing1.ownerName))).environmentObject(currentUser)
                                    }, label: {
                                        ProductCard(favouritesModel: favouritesModel, listing: listing1, image: recentListing1Image)
                                    })
                                    Spacer()
                                        .frame(width: screenSize.width * 0.05)
                                    NavigationLink(destination: {
                                        ViewListingView(tabSelection: $tabSelection, favouritesModel: favouritesModel, listing: listing2, chatLogViewModel: chatLogViewModel2 ?? ChatLogViewModel(chatUser: ChatUser(id: listing2.uid, uid: listing2.uid, name: listing2.ownerName))).environmentObject(currentUser)
                                    }, label: {
                                        ProductCard(favouritesModel: favouritesModel, listing: listing2, image: recentListing2Image)
                                    })
                                }
                            }
                            //Categories
                            VStack (alignment: .leading) {
                                Text("Categories")
                                    .font(.title2.bold())
                                VStack(spacing: 15){
                                    ForEach(categories) {category in
                                        CategoryCardView(tabSelection: $tabSelection, searchModel: searchModel, category: category)
                                    }
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .refreshable(action: {
                        fetchRecentListings(completion: { listings in
                            recentListings = listings
                            guard let listing1 = listings.count >= 1 ? listings[0] : nil else{
                                return
                            }
                            
                            fetchMainImage(listing: listing1, completion: { image1 in
                                recentListing1Image = image1
                            })
                            guard let listing2 = listings.count >= 2 ? listings[1] : nil else{
                                return
                            }
                            fetchMainImage(listing: listing2, completion: { image2 in
                                recentListing2Image = image2
                            })
                            
                            chatLogViewModel1 = ChatLogViewModel(chatUser: ChatUser(id:listing1.uid, uid: listing1.uid, name: listing1.ownerName))
                            getProfilePic(uid: listing1.uid, completion: { profilePic in
                                chatLogViewModel1?.profilePic = profilePic
                            })
                            chatLogViewModel2 = ChatLogViewModel(chatUser: ChatUser(id:listing2.uid, uid: listing2.uid, name: listing2.ownerName))
                            getProfilePic(uid: listing2.uid, completion: { profilePic in
                              chatLogViewModel2?.profilePic = profilePic
                            })
                        })
                    })
                }
                .padding(.horizontal)
            }
        }.onAppear(){
            fetchRecentListings(completion: { listings in
                recentListings = listings
                guard let listing1 = listings.count >= 1 ? listings[0] : nil else{
                    return
                }
                
                fetchMainImage(listing: listing1, completion: { image1 in
                    recentListing1Image = image1
                })
                guard let listing2 = listings.count >= 2 ? listings[1] : nil else{
                    return
                }
                fetchMainImage(listing: listing2, completion: { image2 in
                    recentListing2Image = image2
                })
                
                chatLogViewModel1 = ChatLogViewModel(chatUser: ChatUser(id:listing1.uid, uid: listing1.uid, name: listing1.ownerName))
                getProfilePic(uid: listing1.uid, completion: { profilePic in
                    chatLogViewModel1?.profilePic = profilePic
                })
                chatLogViewModel2 = ChatLogViewModel(chatUser: ChatUser(id:listing2.uid, uid: listing2.uid, name: listing2.ownerName))
                getProfilePic(uid: listing2.uid, completion: { profilePic in
                  chatLogViewModel2?.profilePic = profilePic
                })
            })
        }
    }
}


struct RecentSearchCard: View {
    var searchText: String = ""
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass.circle.fill")
                .tint(Color.primaryDark)
                .padding(.leading, 5)
            Text(searchText)
                .bold()
                .multilineTextAlignment(.leading)
                .frame(width: 80, height: 50, alignment: .leading)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.primaryBase, lineWidth: 1)
        )
        .background(.white)
    }
}

struct CategoryCardView: View {
    @Binding var tabSelection: Int
    @ObservedObject var searchModel: SearchModel
    var category: Category
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(uiImage: category.image)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .overlay(.gray.opacity(0.1))
                .cornerRadius(20)
                .clipped()
            Text(category.name)
                .font(.title.bold())
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2)
                .padding(25)
                .frame(width:300, alignment: .leading)
        }
        .onTapGesture {
            searchModel.searchQuery = ""
            searchModel.searchQuery = category.name
            // Not going to set the category filter because I think in this case, the user wants to browse the category, searching within the category is another story.
            searchModel.searchReady = true
            tabSelection = 2
        }
    }
}

struct Previews_HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tabSelection: .constant(1), searchModel: SearchModel(), favouritesModel: FavouritesModel())
    }
}
