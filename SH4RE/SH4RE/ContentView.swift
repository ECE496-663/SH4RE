//
//  ContentView.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import SwiftUI

struct ContentView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("BackgroundGrey"))
    }
    
    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "safari.fill")
                    }
                CreateListingView()
                    .tabItem {
                        Label("Post", systemImage: "plus.square.fill")
                    }
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle.fill")
                    }
            }
            .accentColor(Color.init(UIColor(named: "PrimaryDark")!))
        }
    }
}

struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
