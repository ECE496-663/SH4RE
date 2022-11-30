//
//  ContentView.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import SwiftUI

struct ContentView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        ZStack {            
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                CreateListingView()
                    .tabItem {
                        Label("Post", systemImage: "plus.square.fill")
                    }
                HomeView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                HomeView()
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle.fill")
                    }
                
            }
            .accentColor(Color.init(UIColor(named: "PrimaryDark")!))
        }
    }
}
