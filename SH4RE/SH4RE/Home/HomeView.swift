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

//This probably shouldnt go here but it will for now, allows for safe and easy bounds checking
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct HomeView: View {
    @Binding var tabSelection: Int
    @Binding var searchQuery: String
    @Binding var recentSearchQueries: [String]
    
    // Manages the three most recent searches made by the user
    func addRecentSearch(searchQuery: String){
        if (searchQuery.isEmpty || searchQuery == ""){ return }
        var savedValues = UserDefaults.standard.stringArray(forKey: "RecentSearchQueries") ?? []
        if let index = savedValues.firstIndex(of: searchQuery) {
            savedValues.remove(at: index)
        }
        if savedValues.count == 3 {
            savedValues.removeLast()
        }
        savedValues.insert(searchQuery, at: 0)
        UserDefaults.standard.set(savedValues, forKey: "RecentSearchQueries")
        recentSearchQueries = savedValues
        print(recentSearchQueries)
    }

    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                Color("BackgroundGrey").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 15) {
                    Text("Search")
                        .font(.title.bold())
                    TextField("What are you looking for?", text: $searchQuery)
                        .textFieldStyle(textInputStyle())
                        .onSubmit {
                            guard searchQuery.isEmpty == false else{ return }
                            addRecentSearch(searchQuery: searchQuery)
                        }
                    ScrollView {
                        //Body
                        VStack(alignment: .leading){
                            //Recent Searches
                            VStack (alignment: .leading) {
                                Text("Recent Searches")
                                    .font(.title2.bold())
                                HStack(alignment: .center){
                                    ForEach (recentSearchQueries, id: \.self) { query in
                                        Button(action: {
                                            searchQuery = query
                                            tabSelection = 2
                                            addRecentSearch(searchQuery: query)
                                        }) {
                                            RecentSearchCard(searchText: query)
                                            // match everything but the last
                                            if query != recentSearchQueries.last {
                                                Spacer()
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
