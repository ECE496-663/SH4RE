//
//  HomeView.swift
//  SH4RE
//
//  Created by November on 2022-11-18.
//

import Foundation
import SwiftUI

//Remove once real listing is here
let test_listing = Listing(id :"MNizNurWGrjm1sXNpl15", uid: "Cfr9BHVDUNSAL4xcm1mdOxjAuaG2", title:"Test Listing", description: "Test Description", imagepath : ["path"], price: "20.00")

struct HomeView: View {
    @Binding var tabSelection: Int
    @Binding var searchQuery: String
    @Binding var recentSearchQueries: [String]

    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                Color("BackgroundGrey").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 10) {
                    Text("Search")
                        .font(.title.bold())
                    TextField("What are you looking for?", text: $searchQuery)
                        .textFieldStyle(textInputStyle())
                        .frame(width: .infinity)
                    ScrollView {
                        //Body
                        VStack(alignment: .leading){
                            //Recent Searches
                            VStack (alignment: .leading) {
                                Text("Recent Searches")
                                    .font(.title2.bold())
                                HStack(alignment: .center){
                                    Button(action: {
                                        searchQuery = recentSearchQueries[0]
                                        tabSelection = 2
                                    }) {
                                        RecentSearchCard(searchText: recentSearchQueries[0])
                                    }
                                    RecentSearchCard(searchText:"questionnnn dfasdfasdfcvxcvxfgdfgsdfsgsdfg")
                                        .frame(maxWidth: .infinity)
                                    RecentSearchCard(searchText:"questionnnn dfasdfasdfcvxcvxfgdfgsdfsgsdfg")
                                }
                            }
                            //Recent Posts
                            VStack (alignment: .leading) {
                                Text("Recent Posts")
                                    .font(.title2.bold())
                                HStack(){
                                    ProductCard(listing: test_listing, image: UIImage(named: "ProfilePhotoPlaceholder")!)
                                    Spacer()
                                    ProductCard(listing: test_listing, image: UIImage(named: "ProfilePhotoPlaceholder")!)
                                }
                            }
                            //Categories
                            VStack (alignment: .leading) {
                                Text("Categories")
                                    .font(.title2.bold())
                                VStack(spacing: 15){
                                    ZStack(alignment: .leading) {
                                        Image(uiImage: UIImage(named: "CreateListingBkgPic")!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 160)
                                            .cornerRadius(20)
                                            .clipped()
                                        Text("Tools")
                                            .font(.title.bold())
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)
                                            .padding(25)
                                    }
                                    ZStack(alignment: .leading) {
                                        Image(uiImage: UIImage(named: "CreateListingBkgPic")!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 160)
                                            .cornerRadius(20)
                                            .clipped()
                                        Text("Camping\nEquipment")
                                            .font(.title.bold())
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)
                                            .padding(25)
                                    }
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.horizontal)
            }
        }
    }
}


struct RecentSearchCard: View {
    var searchText: String = ""
    var body: some View {
        Text(searchText)
            .font(.headline)
            .foregroundColor(.black)
            .fixedSize(horizontal: false, vertical: false)
            .multilineTextAlignment(.leading)
            .padding()
            .frame(width: 110, height: 100, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.darkGrey))
    }
}

struct Previews_HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tabSelection: .constant(1), searchQuery: .constant(""), recentSearchQueries: .constant([""]))
    }
}
