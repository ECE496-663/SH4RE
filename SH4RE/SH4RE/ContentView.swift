//
//  ContentView.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import SwiftUI

var screenSize: CGRect = UIScreen.main.bounds

struct ContentView: View {
    
    @State private var tabSelection = 1
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("BackgroundGrey"))
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $tabSelection) {
                HomeView(tabSelection: $tabSelection)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(1)
                SearchView(tabSelection: $tabSelection)
                    .tabItem {
                        Label("Search", systemImage: "safari.fill")
                    }
                    .tag(2)
                CreateListingView(tabSelection: $tabSelection)
                    .tabItem {
                        Label("Post", systemImage: "plus.square.fill")
                    }
                    .tag(3)
                MessagesView(tabSelection: $tabSelection)
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(4)
                AccountView(tabSelection: $tabSelection)
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle.fill")
                    }
                    .tag(5)
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
