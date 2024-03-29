//
//  ContentView.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import SwiftUI
import FirebaseAuth

let screenSize: CGRect = UIScreen.main.bounds

// custom colours
extension Color {
    static let primaryBase = Color("PrimaryBase")
    static let primaryDark = Color("PrimaryDark")
    static let primaryLight = Color("PrimaryLight")
    static let grey = Color("Grey")
    static let backgroundGrey = Color("BackgroundGrey")
    static let darkGrey = Color("DarkGrey")
    static let textfield = Color("TextFieldInputDefault")
    static let errorColour = Color("Error")
    static let yellow = Color("Yellow")
}

struct ContentView: View {
    @State private var tabSelection = 1
    @State var listing: Listing = Listing()
    @StateObject var currentUser = CurrentUser()
    @StateObject var searchModel = SearchModel()
    @StateObject var favouritesModel = FavouritesModel()
    init() {
        UITabBar.appearance().backgroundColor = UIColor(.backgroundGrey)
    }
    
    var body: some View {
        ZStack {
            if (currentUser.hasLoggedIn) {
                TabView(selection: $tabSelection) {
                    HomeView(tabSelection: $tabSelection, searchModel: searchModel, favouritesModel: favouritesModel)
                        .environmentObject(currentUser)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(1)
                    SearchView(tabSelection: $tabSelection, searchModel: searchModel, favouritesModel: favouritesModel)
                        .environmentObject(currentUser)
                        .tabItem {
                            Label("Search", systemImage: "safari.fill")
                        }
                        .tag(2)
                    CreateListingView(tabSelection: $tabSelection, editListing: $listing)
                        .environmentObject(currentUser)
                        .tabItem {
                            Label("Post", systemImage: "plus.square.fill")
                        }
                        .tag(3)
                    MessagesInboxView(tabSelection: $tabSelection, favouritesModel: favouritesModel)
                        .environmentObject(currentUser)
                        .tabItem {
                            Label("Messages", systemImage: "message.fill")
                        }
                        .tag(4)
                    AccountView(tabSelection: $tabSelection, searchModel: searchModel, favouritesModel: favouritesModel)
                        .environmentObject(currentUser)
                        .tabItem {
                            Label("Account", systemImage: "person.crop.circle.fill")
                        }
                        .tag(5)
                }
                .accentColor(.primaryDark)
            }
            else {
                LoginControlView(favouritesModel: favouritesModel).environmentObject(currentUser)
            }
        }
    }
}

struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
