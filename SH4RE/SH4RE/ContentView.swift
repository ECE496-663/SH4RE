//
//  ContentView.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import SwiftUI

let screenSize: CGRect = UIScreen.main.bounds

// custom colours
let primaryBase = Color.init(UIColor(named: "PrimaryBase")!)
let primaryDark = Color.init(UIColor(named: "PrimaryDark")!)
let primaryLight = Color.init(UIColor(named: "PrimaryLight")!)
let grey = Color.init(UIColor(named: "Grey")!)
let backgroundGrey = Color.init(UIColor(named: "BackgroundGrey")!)
let darkGrey = Color.init(UIColor(named: "DarkGrey")!)
let textfield = Color.init(UIColor(named: "TextFieldInputDefault")!)
let errorColour = Color.init(UIColor(named: "Error")!)

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var tabSelection = 1
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(backgroundGrey)
    }
    
    var body: some View {
        ZStack {
            if (isLoggedIn) {
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
                .accentColor(primaryDark)
            }
            else {
                LoginControlView()
            }
        }
    }
}

struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
