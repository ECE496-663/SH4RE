//
//  SearchView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//
import SwiftUI
import FirebaseStorage
import Combine

//Database stuff to know
//listingView.listings if a list of Listing structs defined in ListingViewModel
//from listing struct you can get id, title, description and cost
//listingView.image_dict is a dict of <String:UIImage> that maps listing ids to images
//needed this separate for now because of sychronous queries

struct SearchView: View {
    @Binding var tabSelection: Int
    @ObservedObject var searchModel: SearchModel
    @ObservedObject var favouritesModel: FavouritesModel
    @EnvironmentObject var currentUser: CurrentUser
    
    @StateObject private var listingsView = ListingViewModel()
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 15)]
    
    @State var showingFilterSheet = false
    
    @State var showFilterButton = true
    @State var scrollOffset: CGFloat = 0.00
    
    //Used to focus on the keyboard when the search icon is clicked
    @FocusState var isFocusOn: Bool
    
    //Possibly move these to a FilterModel or just SearchModel, and add a function that is like FilterModel.reset()
    @State var dropDownSelection: String = ""
    @State var location: String = ""
    @State var minPrice: String = ""
    @State var maxPrice: String = ""
    @State var maxDistance: String = ""
    @State var minRating = 0.0

    // Manages the three most recent searches made by the user
    func addRecentSearch(searchQuery: String){
        if (searchQuery.isEmpty || searchQuery == ""){ return }
        var savedValues = UserDefaults.standard.stringArray(forKey: "RecentSearchQueries") ?? [""]
        if let index = savedValues.firstIndex(of: searchQuery) {
            savedValues.remove(at: index)
        }
        if savedValues.count == 3 {
            savedValues.removeLast()
        }
        savedValues.insert(searchQuery, at: 0)
        UserDefaults.standard.set(savedValues, forKey: "RecentSearchQueries")
        searchModel.recentSearchQueries = savedValues
    }

    fileprivate func searchBar() -> some View {
        return TextField("What are you looking for?", text: $searchModel.searchQuery)
            .textFieldStyle(
                iconInputStyle(
                    button: Button(action:{
                        isFocusOn = true
                    }, label:{
                        Image(systemName: "magnifyingglass")
                    }),
                    colour: .gray
                )
            )
            .focused($isFocusOn)
            .onSubmit {
                guard searchModel.searchQuery.isEmpty == false else{ return }
                addRecentSearch(searchQuery: searchModel.searchQuery)
                //doSearch()
            }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color("BackgroundGrey").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 15) {
                    Text("Search")
                        .font(.title.bold())
                    searchBar()
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15){
                            ForEach(listingsView.listings) { listing in
                                // If theres no image for a listing, just use the placeholder
                                let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                                NavigationLink(destination: {
                                    ViewListingView(tabSelection: $tabSelection, listing: listing, chatLogViewModel: ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: listing.title))).environmentObject(currentUser)
                                }, label: {
                                    ProductCard(favouritesModel: favouritesModel, listing: listing, image: productImage)
                                })
                            }
                        }
                        // Reader to find scroll position to disappear filter button
                        .background(GeometryReader {
                            return Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y
                            )
                        })
                        // Animating the filter button disappear
                        .onPreferenceChange(ViewOffsetKey.self) { offset in
                            withAnimation {
                                if offset > 50 {
                                    showFilterButton = offset < scrollOffset
                                } else  {
                                    showFilterButton = true
                                }
                            }
                            scrollOffset = offset
                        }
                    }
                    // Next two are for the floating filter button
                    .coordinateSpace(name: "scroll")
                    .overlay(
                        showFilterButton ?
                        createFilterButton()
                        : nil
                        , alignment: Alignment.bottom)
                }
                .padding(.horizontal)
            }
        }
        .onAppear(){
            if (searchModel.searchReady) {
                searchModel.searchReady = false;
                //resetFilter()
                //If search was completed from the homescreen, then when the user clicks enter, searchReady will be set to true, and the tabs will be changed to the search tab. Here, we must call the search function
                //I think that if someone does a search from the home screen, we can be pretty sure they dont want to keep the same filters they had before. So likely a resetFilter() funciton would be useful but depends how search works.
                addRecentSearch(searchQuery: searchModel.searchQuery)
                //doSearch(searchQuery)
            }
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
    
    fileprivate func createFilterButton() -> some View {
            return Button(action: {
                showingFilterSheet.toggle();
            }, label: {
                HStack {
                    Label("Filter", systemImage: "slider.horizontal.3")
                }
            })
            .buttonStyle(primaryButtonStyle(width: 120, tall: true))
            .padding(.bottom, 30)
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetView(dropDownSelection: $dropDownSelection, location: $location, minPrice: $minPrice, maxPrice:$maxPrice, maxDistance: $maxDistance, minRating:$minRating, showingFilterSheet: $showingFilterSheet)
                    .presentationDetents([.medium, .large])
            }
        }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(tabSelection: .constant(1), searchModel: SearchModel(), favouritesModel: FavouritesModel())
            .environmentObject(CurrentUser())
    }
}
//struct SearchView_Previews_Helper: View {
//    var body: some View {
//        SearchView(tabSelection: .constant(1), searchModel: SearchModel())
//            .environmentObject(CurrentUser())
//    }
//}
