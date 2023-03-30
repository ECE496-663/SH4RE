//
//  HomeView.swift
//  SH4RE
//
//  Created by November on 2022-11-18.
//

import Foundation
import SwiftUI

//Remove once real listing is here
<<<<<<< HEAD
let test_listing = Listing(id :"MNizNurWGrjm1sXNpl15", uid: "Cfr9BHVDUNSAL4xcm1mdOxjAuaG2", title:"Test Listing", description: "Test Description", imagepath : ["path"], price: "20.00", address: ["latitude": 43.66, "longitude": -79.37], ownerName: "name")
=======
let test_listing = Listing(id :"MNizNurWGrjm1sXNpl15", uid: "Cfr9BHVDUNSAL4xcm1mdOxjAuaG2", title:"Test Listing", description: "Test Description", imagepath : ["path"], price: 10, category: "Camera", address: ["latitude": 43.66, "longitude": -79.37])
>>>>>>> ca308d0d1864a39580475aa0a011f880505ae7b6

//This probably shouldnt go here but it will for now, allows for safe and easy bounds checking
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct HomeView: View {
    @Binding var tabSelection: Int
    @ObservedObject var searchModel: SearchModel
    @ObservedObject var favouritesModel: FavouritesModel
    let categories = getCategoriesAndImg()

    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                Color("BackgroundGrey").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 15) {
                    Text("Search")
                        .font(.title.bold())
                    TextField("What are you looking for?", text: $searchModel.searchQuery)
                        .textFieldStyle(textInputStyle())
                        .onSubmit {
                            searchModel.searchReady = true
                            tabSelection = 2
                        }
                    ScrollView {
                        //Body
                        VStack(alignment: .leading){
                            if(searchModel.recentSearchQueries.count > 1) {
                                //Recent Searches
                                VStack (alignment: .leading) {
                                    Text("Recent Searches")
                                        .font(.title2.bold())
                                    HStack(alignment: .center){
                                        if(searchModel.recentSearchQueries.count == 2){
                                            Spacer()
                                        }
                                        ForEach (searchModel.recentSearchQueries, id: \.self) { query in
                                            Button(action: {
                                                searchModel.searchQuery = query
                                                searchModel.searchReady = true
                                                tabSelection = 2
                                            }) {
                                                RecentSearchCard(searchText: query)
                                            }
                                            // match everything but the last
                                            if query != searchModel.recentSearchQueries.last {
                                                Spacer()
                                            }
                                        }
                                        if(searchModel.recentSearchQueries.count == 2){
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            //Recent Posts
                            VStack (alignment: .leading) {
                                Text("Recent Posts")
                                    .font(.title2.bold())
                                HStack(){
                                    ProductCard(favouritesModel: favouritesModel, listing: test_listing, image: UIImage(named: "ProfilePhotoPlaceholder")!)
                                    Spacer()
                                    ProductCard(favouritesModel: favouritesModel, listing: test_listing, image: UIImage(named: "ProfilePhotoPlaceholder")!)
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
