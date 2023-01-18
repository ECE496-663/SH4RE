//
//  ContentView.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import SwiftUI
import FirebaseAuth

let screenSize: CGRect = UIScreen.main.bounds

struct ContentView: View {
    @ObservedObject var currentUser = CurrentUser()
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("BackgroundGrey"))
    }
    
    var body: some View {
        ZStack {
            if (currentUser.hasLoggedIn) {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "safari.fill")
                        }
                    CreateListingView().environmentObject(currentUser)
                        .tabItem {
                            Label("Post", systemImage: "plus.square.fill")
                        }
                    MessagesView().environmentObject(currentUser)
                        .tabItem {
                            Label("Messages", systemImage: "message.fill")
                        }
                    AccountView().environmentObject(currentUser)
                        .tabItem {
                            Label("Account", systemImage: "person.crop.circle.fill")
                        }
                }
                .accentColor(Color.init(UIColor(named: "PrimaryDark")!))
            }
            else {
                LoginFlow().environmentObject(currentUser)
            }
        }
    }
}

struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
