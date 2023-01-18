//
//  Account.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import Firebase

class Account: ObservableObject {
    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    
    var body: some Scene {
        WindowGroup {
            if (username.isEmpty) {
                GuestView()
            }
            else {
                AccountView()
            }
        }
    }
}
