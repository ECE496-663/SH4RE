//
//  SearchView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//
import SwiftUI
import FirebaseStorage
import Firebase
import Combine

extension View {
    func conditionalButtonStyleModifier<M1: ButtonStyle, M2: ButtonStyle>
        (on condition: Bool, trueCase: M1, falseCase: M2) -> some View {
        Group {
            if condition {
                self.buttonStyle(trueCase)
            } else {
                self.buttonStyle(falseCase)
            }
        }
    }
}

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
    
    @State var chatLogViewModelDict : [String:ChatLogViewModel] = [:]

    //Used to focus on the keyboard when the search icon is clicked
    @FocusState var isFocusOn: Bool
    
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
                    colour: .gray,
                    clearFunc: searchModel.searchQuery == "" ? nil : {searchModel.searchQuery = ""}
                )
            )
            .focused($isFocusOn)
            .onSubmit {
                addRecentSearch(searchQuery: searchModel.searchQuery)
                doSearch()
            }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color("BackgroundGrey").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Search")
                            .font(.title.bold())
                        Spacer()
                        if (searchModel.filtersAreApplied()) {
                            Text("Filtering is Enabled")
                                .foregroundColor(.primaryDark)
                        }
                    }
                    searchBar()
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15){
                            ForEach(listingsView.listings) { listing in
                                // If theres no image for a listing, just use the placeholder
                                let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                                NavigationLink(destination: {
                                    ViewListingView(tabSelection: $tabSelection, listing: listing, chatLogViewModel: chatLogViewModelDict[listing.id] ?? ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: listing.ownerName)) ).environmentObject(currentUser)
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
            if (searchModel.searchReady == true) {
                //If search was completed from the homescreen, then when the user clicks enter, searchReady will be set to true, and the tabs will be changed to the search tab. Here, we must call the search function
                searchModel.searchReady = false
                //If someone does a search from the home screen, we can be pretty sure they dont want to keep the same filters they had before. Also we can search the category by title, so no reason to set the filter
                searchModel.resetFilters()
                doSearch()
                addRecentSearch(searchQuery: searchModel.searchQuery)
            }
        }
    }
    
    func doSearch(){
        listingsView.listings = [Listing]()
        listingsView.searchListings(completedSearch: searchModel.getCompletedSearch()) { success in
            listingsView.fetchProductMainImage( completion: { success in
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
        }
    }
    
    fileprivate func createFilterButton() -> some View {
        return Button(action: {
            showingFilterSheet.toggle();
        }, label: {
            HStack {
                Label("Filters", systemImage: "slider.horizontal.3")
            }
        })
        .conditionalButtonStyleModifier(
            on: searchModel.filtersAreApplied(),
            trueCase: secondaryButtonStyle(width: 120, tall: true),
            falseCase: primaryButtonStyle(width: 120, tall: true))
        .padding(.bottom, 30)
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheetView(searchModel: searchModel, showingFilterSheet: $showingFilterSheet, doSearch: doSearch)
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(tabSelection: .constant(1), searchModel: SearchModel(), favouritesModel: FavouritesModel())
            .environmentObject(CurrentUser())
    }
}
