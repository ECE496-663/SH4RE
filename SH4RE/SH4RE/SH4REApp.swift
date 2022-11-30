//
//  SH4REApp.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import SwiftUI
import Firebase

@main
struct SH4REApp: App {
    @StateObject var create_listing = CreateListing()
    @StateObject var home = Home()
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
