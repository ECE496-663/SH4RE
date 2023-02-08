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
    @State private var searchQuery: String = ""

    @ObservedObject private var listingsView = ListingViewModel()
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    
    @State var showingFilterSheet = false
    
    @State var showFilterButton = true
    @State var scrollOffset: CGFloat = 0.00
    
    @State var dropDownSelection: String = ""
    @State var location: String = ""
    @State var minPrice: String = ""
    @State var maxPrice: String = ""
    @State var maxDistance: String = ""
    @State var minRating = 0.0

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20){
                    ForEach(listingsView.listings) { listing in
                        // If theres no image for a listing, just use the placeholder
                        let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                        NavigationLink(destination: {
                                ViewListingView(tabSelection: $tabSelection, listing: listing)
                            }, label: {
                                ProductCard(listing: listing, image: productImage)
                            }
                        )
                    }
                }
                .padding()
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
            .background(Color.backgroundGrey)
            // Top toolbar
            .toolbar {
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(textInputStyle())
                    .padding()
                    .frame(width: screenSize.width)
            }
            // Next two are for the floating filter button
            .coordinateSpace(name: "scroll")
            .overlay(
                showFilterButton ?
                createFilterButton()
                : nil
                , alignment: Alignment.bottom)
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
        SearchView(tabSelection: .constant(1))
    }
}
