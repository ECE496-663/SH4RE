//
//  ContentView.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import SwiftUI

let screenSize: CGRect = UIScreen.main.bounds
let customColours = [
    "primaryBase": Color.init(UIColor(named: "PrimaryBase")!),
    "primaryDark": Color.init(UIColor(named: "PrimaryDark")!),
    "primaryLight": Color.init(UIColor(named: "PrimaryLight")!),
    "grey": Color.init(UIColor(named: "Grey")!),
    "darkGrey": Color.init(UIColor(named: "DarkGrey")!),
    "textfield": Color.init(UIColor(named: "TextFieldInputDefault")!),
    "error": Color.init(UIColor(named: "Error")!)
]

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("BackgroundGrey"))
    }
    
    var body: some View {
        ZStack {
            if (isLoggedIn) {
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
                .accentColor(customColours["primaryDark"])
            }
            else {
                LoginFlow()
            }
        }
    }
}

struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
