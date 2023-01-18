//
//  Account.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import Firebase
import FirebaseAuth

class Account: ObservableObject {
    var body: some Scene {
        WindowGroup {
            if (CurrentUser().isGuest()) {
                GuestView()
            }
            else {
                AccountView()
            }
        }
    }
}
