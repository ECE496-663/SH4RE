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
    @Binding var searchQuery: String
    @Binding var recentSearchQueries: [String]
    @EnvironmentObject var currentUser: CurrentUser

    @ObservedObject private var listingsView = ListingViewModel()
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 15)]
    
    @State var showingFilterSheet = false
    
    @State var showFilterButton = true
    @State var scrollOffset: CGFloat = 0.00
    
    @State var dropDownSelection: String = ""
    @State var location: String = ""
    @State var minPrice: String = ""
    @State var maxPrice: String = ""
    @State var maxDistance: String = ""
    @State var minRating = 0.0
    
    //This function is repeated and I dont like it but I also dont know how to solve it.
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
        NavigationStack {
            ZStack(alignment: .top) {
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
                        LazyVGrid(columns: columns, spacing: 15){
                            ForEach(listingsView.listings) { listing in
                                // If theres no image for a listing, just use the placeholder
                                let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                                NavigationLink(destination: {
                                    ViewListingView(tabSelection: $tabSelection, listing: listing).environmentObject(currentUser)
                                }, label: {
                                    ProductCard(listing: listing, image: productImage)
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
        SearchView_Previews_Helper()
    }
}
struct SearchView_Previews_Helper: View {
    @State var searchQuery = ""
    @State var recentSearchQueries = [""]
    var body: some View {
        SearchView(tabSelection: .constant(1), searchQuery: $searchQuery, recentSearchQueries: $recentSearchQueries)
            .environmentObject(CurrentUser())
    }
}
