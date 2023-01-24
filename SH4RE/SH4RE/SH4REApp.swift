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
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
